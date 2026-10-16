# Gate and interview questions

Load at Step 2 (Gate) and Step 3 (Interview). Ask only what Preflight and
Describe left open, in this order; each answer narrows the approach or fills a
section of the design document.

## Gate: should this be an agent?

An agent is open-ended, model-driven tool use. Check all four; one "no" keeps
the task at a simpler tier.

| Criterion | Question | "No" looks like |
| --- | --- | --- |
| Complexity | Is the task multi-step and hard to fully specify in advance? | Fixed steps per item: extract, classify, summarize |
| Value | Does the outcome justify the cost and latency of a loop? | Cheap, high-volume, latency-sensitive route |
| Viability | Is the model capable at this task type today? | Needs judgment the model demonstrably lacks |
| Cost of error | Can errors be caught and recovered (review, tests, rollback)? | Irreversible actions with no checkpoint |

Tiers below "agent":

| Tier | Shape | Pick when |
| --- | --- | --- |
| Single call | One request, one response; structured output for JSON | Per-item classification, extraction, summary, Q&A |
| Batch | Batches API, results matched by your custom id, asynchronous (first-party API and Claude Platform on AWS only) | Same single call over many items, no latency need |
| Code-driven workflow | Your code sequences the steps and may call tools between them | Multi-step but the order is known in advance |
| Agent | The model decides the next tool call until done | All four criteria pass |

A user who says "agent" for a single-call job still gets the single-call
answer, stated as such.

## Questions

Each entry: the question, why it changes the design, options to offer, and
what lets you infer it instead of asking.

### 1. Trigger

What kicks a run off: a person in a conversation, an event or API call per
job, or a schedule?

- Why: decides the kickoff shape (conversation turns, one deliverable per
  run, or an unattended scheduled run), and whether anyone is present to
  answer approval prompts.
- Options: person / interactive; event per job; cron schedule.
- Infer from: Describe usually answers this; a `schedule:` workflow in the
  repo implies cron.

### 2. Deliverable

Is the result one checkable thing (artifact, report, PR, dataset), a change
to records in an outside system (tickets, labels, messages), or an ongoing
stream of answers?

- Why: one deliverable gets an outcome rubric and an iterate-until-satisfied
  loop; record changes and conversations get a plain message loop with no
  per-answer grader. When both apply, the artifact decides.
- Options: one artifact; record changes; conversation or answer stream.
- Infer from: the nouns in Describe.

### 3. Tool surface

Which actions does the task need: shell and file breadth, typed dedicated
tools, web search or fetch, code execution, third-party systems through MCP,
or tools your own app must answer?

- Why: every verb in the task must map to a tool. Hard-to-reverse actions
  (send, post, delete, close, push) become dedicated tools so they can be
  gated; breadth stays in bash. Each third-party system implies a credential.
- Options: bash and files; dedicated typed tools; web search or fetch; MCP
  servers; custom tools answered by the host app.
- Infer from: the verbs in Describe and the systems named.

### 4. Done condition

How does the run know it is finished, and what happens if it never is?

- Why: the stop gate differs by approach (model stops calling tools, rubric
  satisfied, session idle, hard cap). A loop with no cap is the common
  failure.
- Options: model stops calling tools; rubric satisfied or max iterations;
  session idle or terminated; hard cap on turns, tokens, or dollars.
- Infer from: Deliverable. Always add a hard cap regardless of the answer.

### 5. State and context

Does a run need to carry state within a long session, across sessions, or
fan out across many sub-tasks?

- Why: within-session needs context editing or compaction; cross-session
  needs a memory tool or store; fan-out needs subagents or a roster; stateless
  runs need none of it.
- Options: stateless per run; within-session only; cross-session memory;
  fan-out across sub-tasks.
- Infer from: "every night" with history to compare implies cross-session;
  "look into N things" implies fan-out.

### 6. Hosting and secrets

Where may tool execution and secrets live: Anthropic's cloud sandbox, a
sandbox worker on your infrastructure, your own process, or a third-party
cloud platform (Bedrock, Vertex, Foundry)?

- Why: this axis alone can rule out Managed Agents and the Batch tier
  (both unsupported on the third-party platforms) or force a self-hosted
  sandbox (secrets must not leave the infrastructure).
- Options: Anthropic cloud sandbox with vault credentials; self-hosted
  sandbox; own process hosts the tools; third-party platform.
- Infer from: existing SDK client class or platform config in the repo;
  company policy the user mentions.

### 7. Budget

What is the spend ceiling per run, and who enforces it?

- Why: a count cap is not a budget. Token budgets on the API are advisory;
  Managed Agents session budgets are hard dollar caps that pause the session;
  Agent SDK has a max-turns and a max-dollar option. Fan-out multiplies spend.
- Options: none beyond per-response max tokens; advisory token budget; hard
  dollar budget; turn cap plus effort tuning.
- Infer from: never. Ask, or propose a number and get it confirmed.

### 8. Approval gates

Which actions need a human before they run, and is a human present when they
would run?

- Why: an interactive run can pause for confirmation; an unattended run
  cannot, so a gated action needs an auto rule, a webhook handler, or a
  downgrade to "report it, a person acts". Gates belong on dedicated tools,
  not on bash strings.
- Options: none (read-only tools); gate in the tool handler; pause for
  confirmation while a client is attached; auto rule or webhook for
  unattended runs.
- Infer from: Trigger plus the hard-to-reverse verbs in Tool surface.

### 9. Failure handling

What happens on a tool error, a dropped connection, a refusal, or a budget
pause?

- Why: tool errors should go back to the model as error results, not crash
  the loop; a dropped stream needs reconnect with event consolidation; a
  budget pause is not terminal; a refusal needs a fallback or a report.
- Options: model-visible errors and retry; harness caps plus fallbacks;
  reconnect and replay pending confirmations; webhook-driven recovery.
- Infer from: Trigger (unattended runs need the stronger options).

### 10. Language and runtime

Which language will the implementation use, if not already fixed?

- Why: Agent SDK supports Python and TypeScript natively; the Anthropic SDK
  covers Python, TypeScript, Java, Go, Ruby, C#, PHP; Managed Agents is REST
  plus those SDKs. An unsupported language pushes toward REST or a
  subprocess.
- Options: the detected project language; Python; TypeScript; other.
- Infer from: Preflight detection. Ask only in an empty project.
