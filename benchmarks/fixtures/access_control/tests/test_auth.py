import unittest

from auth.policy import can
from routes.admin import admin_dashboard, edit_article, view_article


class AccessPolicyTests(unittest.TestCase):
    def test_existing_route_behavior(self):
        self.assertEqual(admin_dashboard({"role": "admin"})["status"], 200)
        self.assertEqual(admin_dashboard({"role": "editor"})["status"], 403)
        self.assertEqual(edit_article({"role": "editor"})["status"], 200)
        self.assertEqual(view_article({"role": "viewer"})["status"], 200)

    def test_central_policy_registry_exists(self):
        import auth.policy as policy

        self.assertTrue(hasattr(policy, "POLICIES") or hasattr(policy, "PolicyRegistry"))
        self.assertTrue(can({"role": "owner"}, "manage_billing"))
        self.assertFalse(can({"role": "superuser"}, "manage_billing"))

    def test_routes_delegate_to_policy(self):
        with open("routes/admin.py", encoding="utf-8") as handle:
            source = handle.read()
        self.assertIn("can(", source)
        self.assertNotIn("superuser", source)


if __name__ == "__main__":
    unittest.main()
