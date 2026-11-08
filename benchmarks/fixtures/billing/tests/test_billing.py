import unittest
from decimal import Decimal

from billing.invoice import calculate_invoice_total


class BillingContractTests(unittest.TestCase):
    def test_backward_compatible_total(self):
        total = calculate_invoice_total(
            [{"price": "10.00", "quantity": 2}, {"price": "5.00", "quantity": 1}],
            tax_rate="0.10",
        )
        self.assertEqual(str(total), "27.50")

    def test_coupon_and_regional_tax(self):
        total = calculate_invoice_total(
            [{"price": "19.99", "quantity": 2}],
            region="US-CA",
            coupon={"type": "percent", "value": "10"},
        )
        self.assertEqual(str(total), "38.78")

    def test_uses_money_value_object(self):
        import billing.invoice as invoice

        self.assertTrue(hasattr(invoice, "Money"))
        self.assertEqual(str(invoice.Money("1.005").to_cents()), "1.01")
        self.assertIsInstance(invoice.Money("2.00").amount, Decimal)


if __name__ == "__main__":
    unittest.main()
