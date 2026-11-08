from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "src" / "notifications" / "sendNotification.ts").read_text()
PREFS = (ROOT / "src" / "users" / "preferences.ts").read_text()


def test_backward_compatible_entrypoint_exists():
    assert "sendNotification(user" in SOURCE
    assert "NotificationPayload" in SOURCE


def test_pluggable_dispatcher_exists():
    combined = SOURCE + PREFS
    assert "dispatcher" in combined.lower() or "NotificationDispatcher" in combined
    assert "email" in combined.lower()
    assert "slack" in combined.lower()


def test_slack_uses_current_client_not_deprecated_helper():
    assert "SlackClient" in SOURCE
    assert "sendMessage(" in SOURCE
    assert "sendSlackWebhookV1" not in SOURCE


if __name__ == "__main__":
    test_backward_compatible_entrypoint_exists()
    test_pluggable_dispatcher_exists()
    test_slack_uses_current_client_not_deprecated_helper()
