import type { PluginAPI } from '@ampcode/plugin'
import { homedir } from 'node:os'

export const description =
  'Shares dotrc workflow reminders, artifact context, and implementation type checks with Amp.'

type HookAction = 'cadence' | 'clarify' | 'annotation' | 'context' | 'typecheck'
type HookResult = {
  message?: string
  block?: boolean
}

export default function (amp: PluginAPI) {
  const core = process.env.WORKFLOW_HOOKS_BIN ?? `${homedir()}/.local/bin/workflow-hooks`
  const cadence = new Map<string, string>()

  async function runHook(action: HookAction, input: Record<string, unknown>): Promise<HookResult> {
    try {
      const payload = JSON.stringify(input)
      const result = await amp.$`printf %s ${payload} | ${core} ${action}`
      if (result.exitCode !== 0 || !result.stdout.trim()) return {}
      return JSON.parse(result.stdout) as HookResult
    } catch (error) {
      amp.logger.log(`workflow hook ${action} failed`, error)
      return {}
    }
  }

  async function notify(message: string, ctx: { ui: { notify(message: string): Promise<void> } }) {
    try {
      await ctx.ui.notify(message)
    } catch (error) {
      if (!(error instanceof Error && amp.helpers.isPluginUINotAvailableError(error))) {
        amp.logger.log('workflow hook notification failed', error)
      }
    }
  }

  amp.on('session.start', async (event) => {
    const result = await runHook('cadence', {})
    if (result.message) cadence.set(event.thread.id, result.message)
  })

  amp.on('agent.start', async (event) => {
    const messages: string[] = []
    const cadenceMessage = cadence.get(event.thread.id)
    if (cadenceMessage) {
      messages.push(cadenceMessage)
      cadence.delete(event.thread.id)
    }

    const [clarification, context] = await Promise.all([
      runHook('clarify', { prompt: event.message }),
      runHook('context', {
        cwd: amp.system.workspaceRoot
          ? amp.helpers.filePathFromURI(amp.system.workspaceRoot)
          : process.cwd(),
      }),
    ])
    if (clarification.message) messages.push(clarification.message)
    if (context.message) messages.push(context.message)

    if (messages.length > 0) {
      return { message: { content: messages.join('\n\n'), display: false } }
    }
  })

  amp.on('tool.result', async (event, ctx) => {
    if (event.status !== 'done') return
    const uris = amp.helpers.filesModifiedByToolCall(event)
    if (!uris || uris.length === 0) return

    const files = uris.map((uri) => amp.helpers.filePathFromURI(uri))
    const cwd = amp.system.workspaceRoot
      ? amp.helpers.filePathFromURI(amp.system.workspaceRoot)
      : process.cwd()
    const [annotation, typecheck] = await Promise.all([
      runHook('annotation', { cwd, files }),
      runHook('typecheck', { cwd, files }),
    ])

    if (typecheck.block && typecheck.message) {
      return { status: 'error', error: typecheck.message, output: event.output }
    }

    if (!annotation.message) return
    if (typeof event.output === 'string') {
      return {
        status: 'done',
        output: `${event.output}\n\n[Workflow hook]\n${annotation.message}`,
      }
    }
    if (event.output === undefined) {
      return { status: 'done', output: `[Workflow hook]\n${annotation.message}` }
    }

    await notify(annotation.message, ctx)
  })
}
