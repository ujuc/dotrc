REGIONAL_TAX_RATES = {
    "US-CA": 0.0825,
    "US-NY": 0.08875,
    "KR": 0.10,
}


def get_tax_rate(region):
    return REGIONAL_TAX_RATES.get(region, 0.0)
