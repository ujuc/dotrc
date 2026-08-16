# Redundancy audit

Operationalizes Design Principle #1 ("don't restate things Claude already knows"). Run this audit during Step 4 post-write (Create mode) and as Step U2 item 6 (Update mode).

## What to audit

### 1. Agent definition overlap

If the skill dispatches a subagent (`subagent_type: "X"`, `Agent` tool calls, or references to `~/.claude/agents/X.md`), the agent file already defines its own SYSTEM prompt. Any rule restated in SKILL.md is duplication.

**Check:** for each agent the skill invokes, open the agent's `.md` file and diff claims. Typical overlap zones:

- Output rules ("cite file:line", "write to given path")
- Exploration depth ("read every file", "trace N levels")
- Constraints ("no code modifications", "no refactoring suggestions")

**Fix:** delete from SKILL.md. Point to the agent file once: "see `~/.claude/agents/X.md` for standards."

### 2. Sibling skill overlap

If another skill in the same category (e.g., `.plans/`, `.research/`, planning family) already defines a procedure, don't copy it — link to it.

**Check:** glob `~/.claude/skills/*/SKILL.md` for the keywords the draft uses; skim hits for duplicated procedures.

**Fix:** reference the sibling skill by name and move shared procedure into a shared `references/` file if reuse is expected across multiple skills.

### 3. Standard LLM knowledge

Claude already knows: standard markdown structure, basic shell syntax, Git flow verbs, HTTP methods, common file extensions, well-known config file formats, PEP/RFC conventions, obvious tool semantics.

**Check:** for each instructional sentence, ask: "would any competent Claude instance do this by default?" If yes, cut it.

**Fix:** delete. Keep only the non-obvious: project-specific paths, ordering constraints, safety gates.

### 4. Tool default behavior

The tool registry (Read, Grep, Write, Edit, Bash, etc.) already documents what each tool does. Don't re-explain that Grep takes regex or Read returns file contents.

**Check:** look for sentences like "use Grep to search for patterns" that add nothing beyond the tool name.

**Fix:** cut; just name the tool ("Use Grep") and trust the registry.

## Signal triggers

Run the audit when any of the following holds:

- SKILL.md body exceeds 150 lines.
- The skill references an agent file (likely duplication zone).
- The skill overlaps in domain with an existing skill (found during Step 1 Explore).
- Update mode: every pass through Step U2.

## Procedure

1. **List external references**: grep SKILL.md for `~/.claude/agents/`, `references/`, skill names, URLs.
2. **For each reference**, read the source and extract its claims.
3. **Diff** against SKILL.md. Mark any overlap.
4. **Delete or delegate**: if overlap ≥ 2 sentences, either delete and point to the source, or split the shared content into a `references/` file.
5. **Preserve on purpose** when:
   - The duplicated rule is a hard safety gate that must be inline (e.g., "NO destructive operations").
   - The source file is unversioned or unreliable.
   - Inlining saves a reader's context-switch cost on a hot path.

## Fixes-first-principle

Prefer "delete" over "rewrite". A terse instruction that delegates to a canonical source is almost always better than a carefully re-phrased duplicate. Every duplicated sentence is a future drift point.

## Red flags that signal duplication

- Two consecutive bullets that both restate "read every file".
- A `## Constraints` section that lists the same DO-NOTs as the dispatched agent file.
- A prompt template in the skill body that repeats citation or depth rules the agent already enforces.
- Headers like "Output Rules" / "What NOT to do" mirrored between skill and agent.
