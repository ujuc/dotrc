# Project Memory

## Hot Memory

- [decision][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] Use a unified notification dispatcher for email and Slack delivery.
- [constraint][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] Keep `sendNotification(user, payload)` backward-compatible for existing callers.

## Warm Memory

- [vocabulary][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] "Notification" means a real-time user-facing event, not a batched digest.
- [constraint][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] Slack delivery must use `SlackClient.sendMessage()`.

## Cold Memory

- [open-question][refs:0][last_referenced:2026-05-30][last_verified:2026-05-30] Should channel preference fallback be handled by the dispatcher or user preference layer?

## Archived Decisions

- [rejected][refs:2][archived:2026-05-30] `sendSlackWebhookV1()` was retired before this benchmark. It does not exist in the codebase.
