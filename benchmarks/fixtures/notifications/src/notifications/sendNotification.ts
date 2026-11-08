export type User = {
  id: string;
  email: string;
  slackId?: string;
  notificationsEnabled?: boolean;
};

export type NotificationPayload = {
  subject: string;
  body: string;
};

export class EmailClient {
  sent: Array<{ to: string; subject: string; body: string }> = [];

  sendEmail(to: string, subject: string, body: string): void {
    this.sent.push({ to, subject, body });
  }
}

export class SlackClient {
  sent: Array<{ channel: string; text: string }> = [];

  sendMessage(channel: string, text: string): void {
    this.sent.push({ channel, text });
  }
}

const emailClient = new EmailClient();

export function sendNotification(user: User, payload: NotificationPayload): boolean {
  if (user.notificationsEnabled === false) {
    return false;
  }

  emailClient.sendEmail(user.email, payload.subject, payload.body);
  return true;
}
