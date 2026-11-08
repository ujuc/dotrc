# Project Memory

## Hot Memory

- [constraint][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] The supported elevated ownership role is `owner`.
- [decision][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] Use a central policy registry for owner, admin, editor, and viewer authorization decisions.

## Warm Memory

- [constraint][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] Keep existing admin/editor/viewer route behavior backward-compatible.
- [vocabulary][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] "Policy" means a central authorization decision, not an inline route check.

## Cold Memory

- [open-question][refs:0][last_referenced:2026-05-30][last_verified:2026-05-30] Audit logging is out of scope for this benchmark.

## Archived Decisions

- [rejected][refs:2][archived:2026-05-30] The legacy `superuser` role is stale and must not be reintroduced.
- [rejected][refs:2][archived:2026-05-30] Inline owner checks were rejected because they scattered authorization logic outside the policy registry.
