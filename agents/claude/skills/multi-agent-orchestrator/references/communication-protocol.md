# Communication Protocol

## Overview

All inter-agent communication in the pipeline is **file-based**. One agent writes a file to the `.harness/` directory; the next agent reads it. There is no direct message passing, no shared memory, and no function return values between agents.

This design ensures:
- Durability: pipeline state survives context resets.
- Transparency: every agent decision is recorded in a human-readable file.
- Debuggability: inspect `.harness/` to understand what happened at each stage.

## File Exchange Protocol

```
1. product-spec.md     (Planner → Generator, Contract)
2. contract.md         (Contract → Generator, Evaluator)
3. evaluation-report.md (Evaluator → Generator)
4. handoff.md          (Any agent → Next session)
```

## Standard File Header

Every file in `.harness/` must include this header at the top:

```markdown
---
agent: [authoring agent/skill name]
timestamp: [ISO 8601, e.g., 2026-04-02T14:30:00Z]
phase: [planning|contracting|building|evaluating]
round: [integer, starting at 1]
---
```

## Directory Structure

```
.harness/
├── product-spec.md          # Planner output
├── contract.md              # Contract negotiation result
├── evaluation-report.md     # Latest evaluation report
├── evaluation-report-1.md   # First round evaluation (archived)
├── evaluation-report-2.md   # Second round evaluation (archived)
├── handoff.md               # Context reset state transfer
└── logs/                    # Optional: agent execution logs
    ├── planner.log
    ├── generator.log
    └── evaluator.log
```

## File Specifications

### product-spec.md

**Writer:** Planner (spec-planner skill)
**Readers:** Contract, Generator

Contents:
- Product vision and goals.
- Feature list with descriptions.
- User stories or scenarios.
- Non-functional product requirements (performance, accessibility).

Out-of-scope items belong to the negotiated contract, not the product spec.

Must NOT include:
- Implementation details or tech stack decisions.
- Code examples or architecture diagrams.
- Database schemas or API specifications.

### contract.md

**Writer:** Contract (sprint-contract-negotiator skill)
**Readers:** Generator, Evaluator

Contents:
- Testable acceptance criteria for each feature.
- Definition of done for the overall task (or per sprint).
- Explicitly excluded items (will not be evaluated).
- Evaluation methodology (how each criterion will be tested).

Must include:
- At least one externally testable criterion per feature.
- Clear PASS/FAIL conditions (no ambiguity).

### evaluation-report.md

**Writer:** Evaluator (qa-evaluator and/or frontend-design-evaluator skill)
**Readers:** Generator (for feedback loop)

Contents:
- Overall verdict: PASS or FAIL.
- Per-criterion assessment (from contract.md).
- Specific issues found with reproduction steps.
- Severity classification: critical / major / minor / cosmetic.
- Actionable feedback for the Generator.

Versioning:
- The latest report is always `evaluation-report.md`.
- Previous rounds are archived as `evaluation-report-N.md`.
- Round number in the header must match the filename suffix.

### handoff.md

**Writer:** Any agent before context reset
**Readers:** Next session's first agent

Contents:
- Current pipeline phase and round number.
- Summary of completed work.
- Remaining work items.
- All relevant file paths in `.harness/`.
- Known issues or blockers.
- Tech stack and configuration details.
- Running service URLs and ports.

This file must contain enough state for a fresh agent to continue the pipeline without access to previous context.

## File Naming Conventions

| Pattern | Example | Purpose |
|---------|---------|---------|
| `product-spec.md` | `.harness/product-spec.md` | Always singular, one per pipeline run |
| `contract.md` | `.harness/contract.md` | Single contract for current scope |
| `contract-sprint-N.md` | `.harness/contract-sprint-2.md` | Published copy of immutable `.harness/sprint-N/contract.md` |
| `evaluation-report.md` | `.harness/evaluation-report.md` | Latest evaluation |
| `evaluation-report-N.md` | `.harness/evaluation-report-1.md` | Archived evaluation round N |
| `handoff.md` | `.harness/handoff.md` | Context reset state |

## Error Handling

### Missing File

If an agent expects a file that does not exist:

1. **Do not hallucinate content.** Never proceed with assumed data.
2. Check if the file was written to a different location (common mistake: project root instead of `.harness/`).
3. If the file is genuinely missing, report the error and halt the pipeline stage.
4. Suggest which previous stage needs to be re-run.

### Malformed File

If a file exists but is missing the standard header or required sections:

1. Log a warning but attempt to parse what is available.
2. If critical information is missing (e.g., contract has no acceptance criteria), halt and request re-generation.
3. Do not attempt to "fix" another agent's output — request the authoring agent to regenerate.

### Stale File

If a file's timestamp is from a previous pipeline run:

1. Warn the user that artifacts may be from a previous session.
2. Ask whether to proceed with existing artifacts or re-run from the beginning.
3. Never silently use stale artifacts — the user must confirm.

## Protocol Invariants

1. **Write before read.** An agent must write its output file before the next agent is invoked.
2. **One writer per file.** Only the designated agent writes a given file type. Others only read.
3. **Header is mandatory.** Every file must have the standard header. No exceptions.
4. **Latest file wins.** When multiple versions exist, the un-numbered file is the current version.
5. **Archive, do not overwrite.** Before writing a new evaluation report, archive the previous one with a round number suffix.
