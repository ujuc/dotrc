# Eval Criteria — generate-agent-docs

Six binary checks for any generation or update run. Referenced from
SKILL.md; skill-improver / autoresearch / waza reuse these when optimizing
the skill autonomously. Keep each check binary (Pass/Fail) so runs are
scoreable without human judgment.

```
EVAL 1: Mode routing
  Question: Does the run pick the correct branch per the Stage 0 routing
            precedence — keyword OR any existing managed target routes to
            update, while no keyword + no managed target routes to generate
            after the /init recommendation — and identify the right files?
  Pass: Chosen branch matches the precedence table; the file list matches targets.
  Fail: Any existing managed file was regenerated from scratch, the branch is
        wrong, or the file list drifts from stated intent.

EVAL 2: Discoverability & placement discipline
  Question: Every line in the generated/modified output passes the
            "Can an agent discover this by reading the code?" test AND
            sits on the right side of the cross-harness split —
            harness-neutral project content in AGENTS.md /
            contributing-docs/, Claude-only content in CLAUDE.md (below
            the @AGENTS.md import) / rules/ — AND on the right context
            layer (context-engineering-claude5.md C4): a sometimes-relevant
            multi-step procedure is a recommended skill plus one reference
            line, not an inline section (C2).
  Pass: No discoverable content anywhere; no Claude-only content
        (hooks, skills, plan mode, tool names) in AGENTS.md; no
        project-general content in CLAUDE.md; no sometimes-relevant
        procedure written out inline.
  Fail: One or more lines restate facts readable from package.json,
        source tree, or standard linter rules — or content sits on the
        wrong side of the harness split, or a sometimes-relevant
        procedure is spelled out inline instead of delegated to a skill.

EVAL 3: Size budgets
  Question: CLAUDE.md + imported AGENTS.md combined ≤ 100 lines soft /
            200 hard (official ceiling, source:
            claude-code-best-practices.md), nested CLAUDE.md
            ≤ 50 lines (hard 100), individual rule file ≤ 50 lines. Every
            retained line passes the prune test.
  Pass: Produced files stay within soft limits, or within hard limits
        with a user-approved rationale; no line fails the prune test.
  Fail: Any file exceeds the hard limit without user approval, or a line
        survives that would not cause a mistake if removed.

EVAL 4: Reference integrity
  Question: All cross-file references (CLAUDE.md → @AGENTS.md import,
            AGENTS.md → contributing-docs/, nested → parent,
            rules/ `paths` globs) resolve to existing paths.
  Pass: Every reference is a live path.
  Fail: Any reference is broken or a glob targets non-existent paths.

EVAL 5: Blind reviewer
  Question: When output is more than a single root CLAUDE.md, were all
            grounded Phase 3 Reviewer FAILs resolved before final output?
  Pass: Reviewer reports no FAIL, or every reported FAIL was fixed.
  Fail: A grounded Reviewer FAIL remains at skill completion.

EVAL 6: Instruction-authoring constraints
  Question: Is every produced/retained line free of the patterns
            model-prompting-guides.md rejects — self-verification or
            re-check instructions (W1), commands about showing or
            suppressing reasoning (W2), severity/confidence filter bars
            (W5), effort or thinking configuration (D2) — and does every
            scoped rule name its scope rather than implying it (W3)?
            Also free of the two line shapes
            context-engineering-claude5.md rejects — an absolute
            prohibition that fails its Reconciliation test (C1) and any
            memory / notes / session-log / changelog instruction (C3) —
            and of the shape tdd-agent-loop.md rejects: an agent-directed
            TDD / test-first process mandate covered by none of its
            Reconciliation's four survivors (T1)?
  Pass: None of the seven rejected patterns appears; every path-bound rule
        states its paths or lives in .claude/rules/ with `paths`.
  Fail: Any rejected pattern survives, or a rule's scope is left implied.
```
