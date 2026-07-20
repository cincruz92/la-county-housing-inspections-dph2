# Public Health in Housing: An Analysis of LA County Inspection Trends

A case study on the collapse of routine housing inspections in Los Angeles County, 2023–2025. It analyzes 48,085 LA County Department of Public Health inspection records, asks who is affected and why, and tests whether the decline fell harder by income, housing cost, or race across ZIP codes.

**Live site:** https://ccruz92.github.io/la-county-housing-inspections-dph2/ *(hosted on GitHub Pages)*

## What this is

Los Angeles County's routine housing inspections fell 82 percent between 2023 and 2025. Where inspections still happened, violations turned up more often, not less. This case study measures that decline across 48,085 records and tests whether it fell harder based on income, the share of renters stretched by housing costs, or race/ethnicity across ZIP codes. It did not. The loss was systemic, so the fix is policy, not targeting. Each page makes one argument from the data, and every number was checked against the raw records before it went on a page.

## The findings

1. **Routine inspections fell 82%.** Comparing the same nine months in each year, inspections dropped from 26,919 (January–September 2023) to 4,725 (January–September 2025). Over the same period the share of inspections that found a violation rose from 32% to 42%, and the average number of violations per inspection rose 17%. Fewer inspections, worse conditions where they still happened.

2. **The decline was systemic, not targeted.** Across 254 ZIP codes, six demographic variables (income, renters stretched by housing costs, and the Hispanic, White, Black, and Asian shares of the population) each explained essentially none of the variation in the decline (R² of 0.020 or below for all six). The loss was broad, not concentrated by income, housing cost, or race across ZIP codes.

3. **The City of LA shapes the countywide trend.** 57.6% of all inspections are in the City of Los Angeles, so County-wide numbers are driven heavily by one jurisdiction.

4. **No inspection frequency is mandated for incorporated cities.** The District Inspection Branch (DIB) guide describes annual routine inspection as program practice, but no statute, ordinance, or contract requires any frequency for incorporated cities. The Los Angeles metro area has the highest rentership rate of any major U.S. metro, 53% of households rent, versus a 34.4% national average (Redfin analysis of U.S. Census Bureau data, Q2 2024). Renters generally have no direct way to require an inspection of their own home the way an owner controls their property; this dataset shows that for multi-family buildings under DIB's jurisdiction, no inspection frequency is mandated at all.

5. **Two programs inspect in parallel under different law.** In the City of LA, DIB (County Health Code, a public-health lens) and the Systematic Code Enforcement Program (SCEP, LA Housing Code, a housing lens) operate separately. This dataset is DIB routine inspections only.

## The pages

- **Home:** the landing page with the headline findings and table of contents.
- **Start Here:** who inspects what, the agencies and programs, key terms, and the legal timeline.
- **The Decline:** the headline 82% finding, the rising violation rate, and the cross-extract validation.
- **Violations by Area:** city-level patterns and where inspections fell hardest.
- **Property Types:** what gets inspected and what inspectors find.
- **Equity:** the R² analysis across 254 ZIP codes.
- **Methods:** data, scope, joins, derived fields, calculations, and how to reproduce any number.
- **Limitations:** sixteen documented limitations.
- **Look Up a Property:** a searchable database of inspected addresses.

## Data

- **Inspections and violations:** LA County Open Data Portal, Department of Public Health, Environmental Health Division. Downloaded February 2026. The County has since replaced the source, so the originals are no longer publicly available; the copies in this repository are the version of record.
- **Demographics:** American Community Survey 5-year estimates (2020–2024), pulled from Census Reporter in March 2026: median household income (B19013), race and ethnicity (B03002), and renters stretched by housing costs (B25070).
- **Scope:** 48,085 routine DIB inspections, January 2023 through September 2025, at 37,009 distinct facilities, with 37,026 matched violations. Routine inspections only; no complaint records.

## Methods and reproducibility

Every figure is reproducible from the raw files. The equity analysis has a one-command replication script: double-click **la-county-housing-inspections-dph.Rproj** in the repository root to open RStudio with the working directory already set correctly, then run `source("analysis/replicate_r2.R")`. See **REPRODUCE.md** and `analysis/replicate_r2.R` for full detail; the script rebuilds the 254-ZIP sample from the raw files and returns the six R² values. The full method is on the **Methods** page; in short:

- **Matched time windows.** Any comparison of two periods uses equal-length windows. An earlier draft compared full-year 2023 to a partial 2025 and overstated the decline at 86%; the matched nine-month comparison is 82%.
- **Rates from raw counts.** Pooled rates are computed from raw counts, not averaged percentages.
- **Verified before publishing.** Every number was checked against the raw records before it appeared on a page.
- **Cross-checked.** The decline was confirmed against a second, independent extract of the same County data: identical records across all 30 shared months, and an 81.6% decline on the overlap.

## Limitations

Limitations are documented in two categories: what the data itself constrains, and what conclusions the analysis can reasonably support. Sixteen are listed on the **Limitations** page, including excluded records, geographic and property-type scope, Census timing, and the jurisdiction-label audit (validated against three official County sources; the one anomaly, Northridge, was resolved by consolidating it into the City of Los Angeles grouping in July 2026, documented on the Methods page).

## Repository structure

Raw files are kept exactly as downloaded. The `Excel/` folder holds PROJECT_SUMMARY.xlsx, a values summary with a Source column naming exactly where each figure comes from (the R script, a specific dashboard, or DATA_QUALITY_NOTES.md). The exploratory working workbooks used during analysis are not published: their pivot tables compute percentages on full-year, not matched nine-month, windows, which would read as a contradiction of this project's 82% headline if seen without that context. PROJECT_SUMMARY.xlsx reports sourced values rather than live formulas; cross-workbook formulas break the moment a file is moved or renamed, so every number there is checked against the raw records and cited rather than recalculated on open. Everything in it can be independently rebuilt from raw using the steps on the Methods page. County and ACS raw files are kept separate.

```
.
├── index.html              Landing page: findings and contents
├── dashboard0.html         Start Here
├── dashboard1.html         The Decline
├── dashboard2.html         Violations by Area
├── dashboard3.html         Property Types
├── dashboard4.html         Equity
├── dashboard5.html         Limitations
├── dashboard6.html         Look Up a Property
├── la-county-housing-inspections-dph.Rproj   Double-click to open with the working directory set correctly
├── methods.html            Methods
├── REPRODUCE.md            How to rerun the equity analysis from raw
├── R2_SOURCE_OF_TRUTH.md   Locked equity values: exact and display precision, superseded values, and why
├── DATA_QUALITY_NOTES.md   Every data quality issue found, how it was verified, and how it was resolved
├── CHANGELOG.md            Dated log of every correction and revision to the published analysis
├── analysis/
│   └── replicate_r2.R      Base-R replication script (lm), no packages
├── Excel/
│   └── PROJECT_SUMMARY.xlsx      Sourced values summary, not formula-driven; see Source column per figure
└── data/
    ├── county/             Raw County downloads (Feb 2026), unaltered
    ├── acs/                Raw ACS tables from Census Reporter (Mar 2026): xlsx as downloaded (version of record) plus a matching csv for each, since base R does not read xlsx
    └── source-context/     Official LA County and City of LA reference documents (incorporated cities list, unincorporated areas list, 2024 contract board letter, RHHP flyer, SCEP brochure)
```

## About

I work in quality assurance and compliance at a nonprofit homeless services organization serving Los Angeles County and the San Fernando Valley. Day to day, I build the tracking systems that catch data errors before they affect funding and audit the records that decide who gets housed. Much of this work is the kind that only gets noticed when it is missing, the upstream checks that keep downstream decisions sound. That is why I noticed this analysis. I read housing data every day, and a drop this size is not a line on a chart to me, it is the system I work inside quietly stepping back. I built this to make that visible, and to be exact about what the data does and does not prove. The dataset construction, analysis, findings, and visualization design decisions are mine. The front-end code was written by Claude (Anthropic) to my direction. The R replication script was developed the same way, to my specification, and independently verified by rerunning it against the raw data before publishing.

- LinkedIn: https://www.linkedin.com/in/cindy-c-85b312114/
- GitHub: https://github.com/ccruz92

## Data use and disclaimer

This analysis uses public data from the LA County Open Data Portal and the U.S. Census Bureau for informational purposes. The LA County Open Data Terms of Use function as a liability disclaimer rather than a restriction on analysis or publication. This project is independent and is not affiliated with or endorsed by Los Angeles County or any agency named here.
