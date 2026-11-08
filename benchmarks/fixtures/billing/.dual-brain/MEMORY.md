# Project Memory

## Hot Memory

- [decision][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] Use an explicit Money value object backed by `Decimal` so totals do not drift through float math.
- [constraint][refs:2][last_referenced:2026-05-30][last_verified:2026-05-30] Invoice totals must round to cents using half-up decimal rounding.

## Warm Memory

- [constraint][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] Preserve `calculate_invoice_total(...)` for existing callers.
- [vocabulary][refs:1][last_referenced:2026-05-30][last_verified:2026-05-30] "Money" means an explicit value object backed by `Decimal`, not raw floats.

## Cold Memory

- [open-question][refs:0][last_referenced:2026-05-30][last_verified:2026-05-30] Coupon validation can stay out of scope; this benchmark only needs deterministic coupon application.

## Archived Decisions

- [rejected][refs:2][archived:2026-05-30] `Money.round_bankers()` does not exist and contradicts the half-up rounding rule.
- [rejected][refs:2][archived:2026-05-30] Plain float totals were rejected because rounding drift broke regional tax calculations.
