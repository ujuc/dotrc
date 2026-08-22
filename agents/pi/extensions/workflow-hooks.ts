import type { ExtensionAPI } from '@earendil-works/pi-coding-agent'
import { spawn } from 'node:child_process'
import { homedir } from 'node:os'
import { join } from 'node:path'

type HookAction = 'cadence' | 'clarify' | 'annotation' | 'context' | 'typecheck'
type HookResult = {
  message?: string
  block?: boolean
}

const core = process.env.WORKFLOW_HOOKS_BIN ?? join(homedir(), '.local/bin/workflow-hooks')

function runHook(action: HookAction, input: Record<string, unknown>): Promise<HookResult> {
  return new Promise((resolve) => {
    const child = spawn(core, [action], { stdio: ['pipe', 'pipe', 'pipe'] })
    const stdout: Buffer[] = []
    const stderr: Buffer[] = []

    child.stdout.on('data', (chunk: Buffer) => stdout.push(chunk))
    child.stderr.on('data', (chunk: Buffer) => stderr.push(chunk))
    child.on('error', (error) => {
      console.error(`workflow hook ${action} failed`, error)
      resolve({})
    })
    child.on('close', (code) => {
      if (code !== 0) {
        console.error(`workflow hook ${action} failed: ${Buffer.concat(stderr).toString().trim()}`)
        resolve({})
        return
      }
      try {
        resolve(JSON.parse(Buffer.concat(stdout).toString()) as HookResult)
      } catch (error) {
        console.error(`workflow hook ${action} returned invalid JSON`, error)
        resolve({})
      }
    })
    child.stdin.end(JSON.stringify(input))
  })
}

export default function (pi: ExtensionAPI) {
  let cadenceMessage: string | undefined
  let restoreContext = false

  pi.on('resources_discover', () => ({
    skillPaths: [join(homedir(), '.claude/skills')],
  }))

  pi.on('session_start', async () => {
    cadenceMessage = (await runHook('cadence', {})).message
    restoreContext = false
  })

  pi.on('before_agent_start', async (event, ctx) => {
    const messages: string[] = []
    if (cadenceMessage) {
      messages.push(cadenceMessage)
      cadenceMessage = undefined
    }

    const clarification = await runHook('clarify', { prompt: event.prompt })
    if (clarification.message) messages.push(clarification.message)
    if (messages.length === 0) return

    return {
      message: {
        customType: 'workflow-hooks',
        content: messages.join('\n\n'),
        display: false,
      },
    }
  })

  pi.on('tool_result', async (event, ctx) => {
    if (event.isError || (event.toolName !== 'write' && event.toolName !== 'edit')) return
    const path = typeof event.input.path === 'string' ? event.input.path : undefined
    if (!path) return

    const normalized = { cwd: ctx.cwd, files: [path] }
    const [annotation, typecheck] = await Promise.all([
      runHook('annotation', normalized),
      runHook('typecheck', normalized),
    ])
    const feedback = [annotation.message, typecheck.message].filter(Boolean).join('\n\n')
    if (!feedback) return

    return {
      content: [...event.content, { type: 'text' as const, text: `[Workflow hook]\n${feedback}` }],
      isError: typecheck.block === true,
    }
  })

  pi.on('session_compact', () => {
    restoreContext = true
  })

  pi.on('context', async (event, ctx) => {
    if (!restoreContext) return
    restoreContext = false
    const result = await runHook('context', { cwd: ctx.cwd })
    if (!result.message) return

    return {
      messages: [
        ...event.messages,
        {
          role: 'custom' as const,
          customType: 'workflow-hooks',
          content: result.message,
          display: false,
          timestamp: Date.now(),
        },
      ],
    }
  })
}
