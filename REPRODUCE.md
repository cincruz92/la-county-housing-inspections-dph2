# How to reproduce the six equity R² values

The deciding rule for every number on this site comes from Gary King, "Replication, Replication" (PS: Political Science and Politics, 1995): the value of record is the one that regenerates from the raw public files under the documented method. This file shows how to run that test yourself for the equity analysis. It takes one script and about a minute.

## What you need

- R (any recent version). The script uses base R only, no packages.
- This repository, with the raw data files in place:
  - `data/county/Environmental_Health_Housing_Routine_and_Complaint_Inspections.csv` (raw County download, February 2026, unaltered)
  - `data/acs/Table_1_Median_Household_Income.csv`
  - `data/acs/Table_2_Race_Or_Ethnicity.csv`
  - `data/acs/Table_3_Rent_Burden.csv`

The three ACS tables were downloaded from Census Reporter as xlsx; the original xlsx files are kept in `data/acs/` alongside the CSVs as the version of record. The CSVs are a straight, unedited export of each xlsx file's first sheet, base R does not read xlsx directly, so the CSV is what the script actually opens. No conversion step is needed, both formats are already in the repository.

## Run the script

**Easiest: two clicks, no typing.**
1. Double-click **la-county-housing-inspections-dph.Rproj** in the repository root. This opens RStudio with the working directory already set to this repository, on any computer, no setup required.
2. Open **RUN_THIS.R**, click anywhere on its one line of code, then click the **Run** button at the top of that pane (or press Ctrl+Enter / Cmd+Enter).

**Alternative: type the command yourself.** After opening the `.Rproj` file, in the Console:

```
source("analysis/replicate_r2.R")
```

**Alternative: from a terminal**, from the repository root:

```
Rscript analysis/replicate_r2.R
```

## Expected output

The script prints its checks as it goes, with the expected value beside each one:

```
Unique inspections in window: 48085 (expected 48085)
Distinct ZIPs: 289 (expected 289)
Excluded, no ACS match: 24 (expected 24)
Excluded, invalid income: 6 (expected 6)
Excluded, no 2023 baseline: 5 (expected 5)
Final sample n = 254 (expected 254)

variable   R2       expected match
income     0.0155   0.0155   PASS
burden     0.0040   0.0040   PASS
hispanic   0.0153   0.0153   PASS
white      0.0203   0.0203   PASS
black      0.0196   0.0196   PASS
asian      0.0047   0.0047   PASS
```

Six PASS lines mean the published values regenerate from raw.

## What the script does, in order

1. Reads the raw inspections file, deduplicates to one record per SERIAL NUMBER, and keeps the analysis window, January 1, 2023 through September 30, 2025. This yields 48,085 inspections across 289 ZIP codes.
2. Counts inspections per ZIP on matched nine-month windows, January through September of 2023 and of 2025, and computes the percent change per ZIP.
3. Joins the three ACS tables by ZIP code.
4. Applies three exclusions in a fixed order, which is part of the sample definition: 24 ZIPs with no ACS match, then 6 ZIPs where the Census reports no valid median income (the export marks these with a large negative placeholder), then 5 ZIPs with zero inspections in the 2023 baseline window. 289 minus 24 minus 6 minus 5 leaves 254.
5. Runs six separate bivariate regressions with `lm()`, percent change in inspections on each demographic variable, and reports the R² for each.

The exclusion order matters. Applying the same rules in a different order, or skipping one, produces a different sample and different values. The script prints each step's count so a mismatch is visible immediately rather than surfacing later as an unexplained number.

## Notes

- The raw inspections file contains Windows-encoded characters in some facility names and is not valid UTF-8. The script reads it as latin1 raw lines first and then parses. Reading it directly with `read.csv(fileEncoding = ...)` silently truncates the file on some systems, which is exactly the kind of quiet failure this replication exists to catch.
- Rent burden is defined as (B25070007 + B25070008 + B25070009 + B25070010) / B25070001, the share of all renter households paying 30 percent or more of income toward rent, with "not computed" households included in the denominator.
- Twelve of the 254 ZIPs show an inspection increase rather than a decline, and four exceed +100 percent because of very small 2023 baselines. All are retained in the regression as published and disclosed on the Equity page.
