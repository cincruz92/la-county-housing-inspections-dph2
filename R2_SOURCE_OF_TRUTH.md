# Equity R² Values: Source of Truth
**Project:** Public Health in Housing: An Analysis of LA County Inspection Trends
**Verified:** July 4, 2026, recomputed end to end from raw files
**Status:** LOCKED. These are the values of record. Any number that disagrees with this file is superseded.

---

## The six R² values (verified correct as published)

Bivariate OLS, dependent variable = percent change in routine inspections per ZIP,
Jan–Sep 2023 vs Jan–Sep 2025. n = 254 ZIP codes.

| Variable | R² (4 decimals) | Reported (3 decimals) |
|---|---|---|
| Median household income (B19013) | 0.0155 | 0.016 |
| Renters stretched by housing costs (B25070, 30%+ of income, all renter households) | 0.0040 | 0.004 |
| Hispanic/Latino share (B03002012 / B03002001) | 0.0153 | 0.015 |
| White non-Hispanic share (B03002003 / B03002001) | 0.0203 | 0.020 |
| Black non-Hispanic share (B03002004 / B03002001) | 0.0196 | 0.020 |
| Asian non-Hispanic share (B03002006 / B03002001) | 0.0047 | 0.005 |

Maximum: 0.020 (White non-Hispanic). The published claim "R² of 0.020 or below for
all six" is correct. All six are far below the 0.10 threshold. The systemic,
not demographically targeted, finding holds.

## The locked sample: how 289 becomes 254

From the raw inspections CSV, dedupe to unique SERIAL NUMBER within
Jan 1, 2023 – Sep 30, 2025 (48,085 records, 289 distinct ZIPs), then exclude in
this order:

1. **24 ZIPs with no ACS match** (includes the 9 data-entry-error ZIPs documented
   in DATA_QUALITY_NOTES Issue 1, which fail the Census join because the ZIP is wrong)
2. **6 ZIPs with invalid ACS income** (no reportable B19013 value):
   90071, 90639, 91046, 91608, 93243, 93563
3. **5 ZIPs with no Jan–Sep 2023 baseline** (zero inspections in the base window):
   90502, 91326, 91384, 93543, 93544

289 − 24 − 6 − 5 = **254**. This exclusion order is part of the definition.
Applying the same rules in a different order, or skipping one, produces the
ghost samples (256, 258, 259) that caused past confusion.

## Verification chain (what was checked on July 4, 2026)

1. Raw CSV reproduces headline counts: 48,085 unique inspections; 26,919 (Jan–Sep 2023);
   4,725 (Jan–Sep 2025); 289 ZIPs.
2. All 254 per-ZIP decline values in dashboard4 match the raw CSV rebuild exactly
   (zero mismatches at 0.05 tolerance).
3. All 254 ZIPs' demographic values in dashboard4 match the raw ACS tables exactly:
   income to the dollar; race shares and rent burden within 0.15 points (rounding only).
   Rent burden definition confirmed: (B25070007+008+009+010) / B25070001,
   i.e., burden share of ALL renter households, including "not computed."
4. The six R² recomputed on this verified data return the published values.

## Superseded values (do not use)

| Value | Where it came from | Why it is dead |
|---|---|---|
| Income 0.011 (and that pass's other five) | early pass, 259-ZIP sample | pre-dates final exclusion rules; flagged in NUMBERS_AUDIT |
| Income 0.0221 | recompute in a later session on a sample (n≈258) that ignored the invalid-income exclusion | sample does not survive the documented rules |
| Income 0.001 (256-ZIP "complete case") | recompute in another session | sample does not survive the documented rules; not reproducible from data of record |
| Income 0.0505 | full-year window test | wrong window by design; mismatched-period artifact |

The deciding rule (Gary King, "Replication, Replication," 1995): the value of
record is the one that regenerates from the raw public files under the documented
method. Only the table above passes that test.

## Known open item (separate from this lock)

Twelve of the 254 ZIPs show an inspection increase rather than a decline; four are
above +100 percent (91020, 91040, 91214, 91381), which reflects tiny 2023 baselines,
not real growth. They are retained in the regression as published. Whether to
suppress small-baseline ZIPs is a documented, deferred decision (dashboard4 small-
sample task). Changing that decision would change these R² values and would require
a new dated entry superseding this file.

## Addendum: Northridge consolidation does not touch this lock (July 5, 2026)

On July 5, 2026 Northridge (495 records by city name) was consolidated into the
City of Los Angeles grouping on dashboard2, changing the City of LA total from
27,191 to 27,686 and the share from 56.5% to 57.6%. That change is keyed by the
city name field. The regression above is keyed by ZIP code; ZIPs 91324 and 91325
were already in the 254-ZIP sample and remain there unchanged. The six R² values
in this file are unaffected. Verified July 5, 2026 by rerunning
analysis/replicate_r2.R after the consolidation: n = 254 and all six values
returned PASS.
