def calculate_invoice_total(items, tax_rate=0.0):
    subtotal = 0.0
    for item in items:
        subtotal += item["price"] * item.get("quantity", 1)
    return round(subtotal * (1 + tax_rate), 2)
