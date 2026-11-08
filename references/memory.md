# Project memory contract

Use `.dual-brain/MEMORY.md` at the active project root. Memory captures durable decisions and their rationale, not transcripts or operational logs. The orchestrator alone writes it after synthesis. Respect read-only scope and explicit user opt-outs.

If the host has no accessible project filesystem, use only memory supplied in the conversation. Do not promise persistence across chats or silently write to account-wide memory. When a durable decision changes, provide a short suggested memory update for the user to retain if useful, clearly labeled as unsaved.

## Read and verify

Read Hot first, relevant Warm next; search Cold/Archived for specific conflicts or historical decisions. For a large file, use section-bounded reads and targeted searches instead of loading everything. Tiers affect attention, not truth. High reference counts cannot validate a claim.

Treat legacy untiered entries as Warm candidates. Verify before relying on them, and migrate only relevant entries during a warranted save. Preserve unrelated entries and user edits. A current explicit user decision can supersede memory; distinguish that from an accidental contradiction or ambiguous shortcut, and do not use stale memory to veto an authorized change.

## Save and compact

- Save a decision, constraint, vocabulary definition, rejected alternative, or open question only if it will affect future work. Include a short rationale and a file/test/document reference when available.
- Increment `refs` at most once per completed task for each materially influential item during a save justified by durable changes or requested memory maintenance. Do not write merely to increment counters after a repeated clean review. Set `last_referenced` to the actual current date for those items.
- Set `last_verified` only after checking evidence for the saved claim's current wording. A date supporting an earlier version does not verify a revised claim; recheck it or mark it `unknown`. Distinguish a user-approved decision from an implementation still pending. Do not fabricate historical dates; state disputed or uncertain status explicitly.
- Keep essential active constraints Hot. Promote based on current relevance and evidence; demote useful but inactive material to Warm/Cold. Archive superseded decisions with the reason and replacement. Age alone is not proof that a decision is obsolete.
- During a warranted save, merge duplicates or shorten repetition when noise materially hinders recall. Preserve rationale and unresolved conflicts; do not run housekeeping after every invocation or rewrite the file merely to touch metadata. Re-read before applying a save if concurrent user edits are possible.
- Store no credentials, secrets, sensitive personal data, runtime handles, or incidental session versions. Do not forward sensitive values to reviewers. If found in writable project memory, redact only the sensitive material and report its category; in read-only scope report the category without modifying the file. Redacting a file does not erase version history or revoke a credential.

## Format

Keep the existing four tiers and metadata compatible with earlier versions. Evidence and status can be plain prose; no database or custom parser is required.

```md
# Project Memory

## Hot Memory

- [decision][refs:1][last_referenced:2026-10-11][last_verified:2026-10-11] Routes delegate authorization to the central policy registry so permission changes have one owner. Evidence: auth/policy.py and tests/test_auth.py.

## Warm Memory

- [constraint][refs:0][last_referenced:unknown][last_verified:unknown] Proposed API compatibility window is unconfirmed; check the release plan before relying on it.

## Cold Memory

## Archived Decisions

- [superseded][refs:1][archived:2026-10-11] Inline role checks were replaced by the registry to prevent route drift.
```

After saving, briefly say what changed. Invite corrections only when useful; saving does not create a mandatory question or another approval step. Do not claim memory was saved until the write succeeds.
