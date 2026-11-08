import type { User } from "../notifications/sendNotification";

export type ChannelPreference = "email" | "slack";

export function getPreferredChannels(user: User): ChannelPreference[] {
  if (user.slackId) {
    return ["email", "slack"];
  }
  return ["email"];
}
