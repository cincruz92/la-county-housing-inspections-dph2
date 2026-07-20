# Data Quality and Integrity Notes
**Project:** Public Health in Housing: An Analysis of LA County Inspection Trends  
**Analyst:** Cindy Cruz  
**Dataset:** LA County District Inspection Branch, Housing Inspection Records  
**Source:** LA County Open Data Portal  
**Downloaded:** February 2026  
**Last updated:** July 5, 2026  

---

## Overview

During data preparation and analysis, the following data quality and integrity issues were identified in the source dataset published by the LA County Open Data Portal. These issues were discovered through cross-referencing facility addresses, city names, ZIP codes, and official policy documentation. All errors originate in the source data. None were introduced during analysis.

These findings are documented here for transparency and to support independent verification. They are also summarized in Dashboard 5, Limitation 6, Limitation 7, and Limitation 8.

**Note on inspection event counts:** In the merged dataset, the field that uniquely identifies each inspection event is SERIAL NUMBER, not RECORD ID. There are 48,085 unique SERIAL NUMBERs in MERGED, matching the inspection count reported across the portfolio. RECORD ID is a facility-related identifier that may be reused across multiple inspections of the same property. Counts of "unique RECORD IDs" should not be interpreted as counts of inspection events. Violation records (rows with a non-null VIOLATION CODE) total 37,026 and match the violation count reported across the portfolio.

---

## Issue 1: ZIP Code Data Entry Errors (9 records)

**What was found:**
Nine inspection records contain ZIP codes that do not match the facility address or city listed in the same record. Each error was verified by looking up the facility address through publicly available property records and address databases.

**How it was identified:**
ZIP codes falling outside the expected LA County range (900xx–919xx) were flagged for review. Each flagged address was then verified individually against property databases including Redfin, Apartments.com, Spokeo, and LoopNet.

**Verified errors:**

| ZIP in Dataset | Facility Address | City in Dataset | Correct ZIP | Error Type |
|----------------|-----------------|-----------------|-------------|------------|
| 92104 | 521 W Colorado St | Glendale | 91204 | Digit transposition |
| 92107 | 3474 E Colorado Blvd | Pasadena | 91107 | Digit transposition |
| 92626 | 8101 Sepulveda Blvd | Van Nuys | 91402 | Wrong ZIP entirely |
| 92627 | 300 N Avalon Blvd | Wilmington | 90744 | Wrong ZIP entirely |
| 92648 | 604 Chevy Chase Dr | Glendale | 91205 | Wrong ZIP entirely |
| 92658 | 1700 Pomeroy Ave | Los Angeles | 90033 | Wrong ZIP entirely |
| 93436 | 45348 32nd St W | Lancaster | 93536 | Wrong ZIP entirely |
| 93557 | 39375 5th St W | Palmdale | 93551 | Similar digits, wrong ZIP |
| 94704 | 842 N Sycamore Ave | Los Angeles | 90038 | Wrong ZIP entirely |

**Three ZIP codes initially flagged but confirmed correct:**

| ZIP in Dataset | Facility Address | City | Status |
|----------------|-----------------|------|--------|
| 93243 | 51541 Ralphs Ranch Rd | Lebec | Correct, Lebec is in LA County |
| 93544 | 31821 Crystalaire Dr | Llano | Correct, Llano is in LA County |
| 93563 | 31001 Valyermo Rd | Valyermo | Correct, Valyermo is in LA County |

**Impact on analysis:**
The 9 erroneous records represent a very small share of the 48,085 total inspections. Because the facility address and city name are correct in each case, the records were retained in the dataset as downloaded. They are excluded from the ZIP-level equity analysis in Dashboard 4 because their incorrect ZIP codes prevented a Census data match. This is documented in Dashboard 5, Limitation 8.

---

## Issue 2: Glendale and Torrance Inspections vs. Official Policy (3,401 records)

**What was found:**
The LA County Department of Public Health states on its official website that the District Inspection Branch does not have housing enforcement authority in Glendale and Torrance because those cities have not adopted the County Health Code. However, the source dataset includes 2,856 routine housing inspections for Glendale and 545 for Torrance.

**Source of official policy statement:**
LA County DPH District Inspection Branch official page:
http://publichealth.lacounty.gov/eh/inspection/housing-inspection.htm

**Breakdown:**

| City | Inspections in Dataset | Policy Statement |
|------|----------------------|-----------------|
| Glendale | 2,856 (5.9% of total) | DIB has no housing enforcement authority |
| Torrance | 545 (1.1% of total) | DIB has no housing enforcement authority |

**Possible explanations:**
- The records may reflect hotel or motel inspections, which may fall under different legal authority than residential housing inspections
- The policy statement on the website may be outdated or may not reflect the full scope of DIB contracts
- The dataset may include records from a period before current policy was adopted

**Impact on analysis:**
This inconsistency could not be resolved from the available data alone. The records were included as downloaded. Glendale and Torrance findings should be interpreted with caution. This is documented in Dashboard 5, Limitation 7.

---

## Issue 3: Northridge Listed as Separate Jurisdiction (495 records)

**What was found:**
The source dataset's original city field (FACILITY CITY_OG) lists "Northridge" as a separate city for 495 inspection records. Northridge is a neighborhood within the City of Los Angeles, not an independent city.

**ZIP codes for Northridge records (verified from raw inspections file):**
- 91324: 246 inspections
- 91325: 249 inspections
- Total: 495 inspections

Both ZIP codes are confirmed Los Angeles ZIP codes in the San Fernando Valley.

**How it was handled:**
A derived grouping field (FACILITY CITY_GROUPED) was created to consolidate LA neighborhood names under "Los Angeles" for city-level analysis. Northridge was originally not included in this consolidation and remained its own grouping with 495 inspections, producing 27,191 unique inspections attributed to the City of Los Angeles. On July 5, 2026 that choice was reversed: Northridge was consolidated into the City of Los Angeles grouping, bringing the neighborhood labels grouped to 36 and the City of Los Angeles total to 27,686.

**Impact on analysis:**
With Northridge consolidated, the City of Los Angeles share reported across the portfolio is 57.6% (27,686 of 48,085). A ZIP code can cross city lines, so the city-name-keyed count (495) differs from the ZIP-keyed count (500 across 91324 and 91325); the five extra ZIP-keyed records fall after the September 30, 2025 analysis cutoff. Jurisdiction questions in this analysis are keyed by city name. This is documented in Dashboard 5, Limitation 6, and on the Methods page.

---

## Issue 4: Mixed Geographic Units in Source City Field (134 values)

**What was found:**
The source dataset's original city field (FACILITY CITY_OG) contains 134 unique values that mix two different types of geographic units: independent incorporated cities (such as Glendale, Burbank, Santa Monica) and neighborhoods within the City of Los Angeles (such as Van Nuys, North Hollywood, Studio City, Reseda, Canoga Park, Venice, Wilmington, San Pedro).

These are not equivalent geographic units. Independent cities have their own governments and separate contracts with LA County DPH. LA neighborhoods are all governed by the City of Los Angeles under a single contract.

**How it was resolved:**
A derived field (FACILITY CITY_GROUPED) was created consolidating LA neighborhood names under "Los Angeles," 35 labels originally and 36 after Northridge was added to the grouping on July 5, 2026. The grouping was based on local geographic knowledge and verified computationally. Folding Northridge in reduced the unique city groups from 96 to 95.

**Impact on analysis:**
This is a source data characteristic, not an analytical error. It is documented in Dashboard 5, Limitation 6 so viewers understand that the neighborhood table in Dashboard 2 reflects this mixed geographic structure as published by LA County.

**Addendum: source workbook lagged the July 5, 2026 consolidation (found and fixed July 7, 2026)**

The July 5, 2026 Northridge consolidation was applied on the published dashboards but not carried back into MERGED_3-8-2026.xlsx, the working file. In that workbook, the FACILITY CITY_GROUPED formula's neighborhood list did not include Northridge, so the source file still computed 96 distinct grouped cities with Northridge standing alone, one more than the 95 the published pages report post-consolidation. Both counts were internally correct at the time, describing two different states of the same underlying data; the site's language was current, the workbook was not.

Fixed July 7, 2026: the FACILITY CITY_GROUPED formula was updated to fold Northridge into Los Angeles, matching the published pages. Verified after the fix: 95 distinct grouped cities, City of Los Angeles total of 27,686 inspections, matching the published figure exactly. No published number changed as a result; this brings the source workbook into agreement with what was already live.

---

## Issue 5: Dataset Versions No Longer Available for Independent Replication

**What was found:**
The inspection and violation datasets were downloaded from the LA County Open Data Portal in February 2026. LA County has since replaced both datasets with updated versions. The original versions used in this analysis are no longer publicly available.

**Impact on analysis:**
This analysis cannot be independently replicated using the current portal. Any attempt to reproduce findings using the current datasets may produce different results due to updates, corrections, or additions to the data. This is documented in Dashboard 5, Limitation 1.

---

## Issue 6: Jurisdictional Mismatch Between Official Policy and Source Data

**What was found:**
Long Beach, Pasadena, and Vernon run their own environmental health departments and should not, in principle, appear in the LA County DPH dataset. Confirmed directly from two County sources: the Environmental Health contact page (publichealth.lacounty.gov/eh/about/contact-us.htm) and the District Offices page (publichealth.lacounty.gov/eh/about/district-offices.htm), both of which name only these three cities as outside DIB's jurisdiction. The raw source data shows the following:

| City | Records in Source Data | Notes |
|------|------------------------|-------|
| Long Beach | 0 | No records present; effectively absent from source |
| Pasadena | 28 | Records present in source data |
| Vernon | 1 | Records present in source data |
| South Pasadena | 154 | Records present in source data; separate issue, see below |

**South Pasadena is not one of the three.** No County source names South Pasadena as running its own environmental health department. The city does operate its own Environmental Services and Sustainability Division, but that covers trash collection and sustainability programs, not housing or environmental health inspections, so it does not qualify South Pasadena for the same exclusion as Long Beach, Pasadena, and Vernon. South Pasadena's 154 records are therefore an unresolved anomaly on their own terms: present in a dataset the city should not, by County policy, be part of, with no available explanation for why.

**Verification method:**
Counts were verified directly from the raw inspections file (FACILITY CITY field, filtered to the January 1, 2023 through September 30, 2025 analysis window). The MERGED file used for analysis retains the same records.

**Impact on analysis:**
A total of 29 records from the three confirmed independent-health-department cities (Pasadena and Vernon; Long Beach has none), plus South Pasadena's separately unexplained 154, total 183 records retained as published. This represents approximately 0.4% of the 48,085 inspections in the window. The presence of these records does not materially affect the portfolio's headline findings (the 82% inspection decline, the rising violation rate, the systemic rather than demographically targeted pattern), but viewers should be aware that the dataset is not a perfect representation of DIB jurisdictional scope. This is documented in Dashboard 5, Limitation 6.

---

## Issue 7: Working Excel Pivot Disconnected from Its Source File (Census_Merge.xlsx)

**What was found:**
The Analysis7_IncomeEquity pivot table in Census_Merge.xlsx reports a Grand Total of 48,019 unique inspections, which does not match the verified figure of 48,085 reported everywhere else in this project and confirmed by replicate_r2.R against the raw source files.

**How it was identified:**
On refresh, Excel returned a DataSource.NotFound error naming an external file path from an earlier working computer: C:\Users\ccruz\Desktop\Opportunities\LA Open Data Projects\PRE RHHP\Census Reporter\Table 3 Rent Burden.xlsx. That file, and that folder structure, no longer exist. The pivot is not built from data stored inside the current workbook; it is an external-reference pivot that was last able to connect to its source before this project was consolidated into its current file structure. A second refresh attempt returned the same unchanged 48,019 total, confirming the pivot is displaying a frozen, cached snapshot rather than live data.

**Impact on analysis:**
None. This pivot table was never the source of any published number. All published figures, including 48,085, derive from replicate_r2.R run directly against the raw files in data/county and data/acs, per the method documented in REPRODUCE.md. The Analysis7_IncomeEquity tab in Census_Merge.xlsx is retained as a record of earlier working analysis but should not be treated as current. It cannot be refreshed without manually reconnecting it to a live data source, which was not done since the R script already supersedes it.

**Update:** Census_Merge.xlsx, along with the other working workbook (MERGED_3-8-2026.xlsx), has since been removed from publication entirely. Both contain pivot tables computed on full-year rather than matched nine-month windows, which would read as a contradiction of this project's 82% headline without the context this note provides. This issue is retained as a record of the diagnostic work; the file it describes is no longer part of the published repository.

---

## Summary Table

| Issue | Records Affected | Included in Analysis | Documented In |
|-------|-----------------|---------------------|---------------|
| ZIP code data entry errors | 9 records | Yes, with caveats | Dashboard 5, Limitation 8 |
| Glendale and Torrance policy inconsistency | 3,401 records | Yes, with caveats | Dashboard 5, Limitation 7 |
| Northridge listed as separate jurisdiction | 495 records | Yes, consolidated under the City of Los Angeles grouping (July 5, 2026) | Dashboard 5, Limitation 6 |
| Mixed geographic units in city field | 134 unique values | Yes, resolved via derived field for 35 LA neighborhoods | Dashboard 5, Limitation 6 |
| Dataset no longer available for replication | Full dataset | N/A | Dashboard 5, Limitation 1 |
| Jurisdictional mismatch (Pasadena and Vernon, 3 confirmed cities) plus South Pasadena's unresolved 154 | 183 records | Yes, retained as published in source | Dashboard 5, Limitation 6 |
| Long Beach truly absent from source | 0 records | N/A | Dashboard 5, Limitation 6 |
| Working pivot (Census_Merge.xlsx) disconnected from source, showing 48,019 vs. verified 48,085 | N/A, no published number affected | No, retired in favor of replicate_r2.R | This file, Issue 7 |

---

## Analyst Note

These findings were identified through careful cross-referencing of facility addresses, city names, ZIP codes, and official policy documentation during data preparation and analysis. Identifying and documenting source data quality issues is a standard part of rigorous data analysis. The goal is not to undermine confidence in the findings but to be transparent about the conditions under which those findings were produced.

The core findings of this portfolio (an 82% inspection decline, a rising violation rate, and a systemic rather than demographically targeted pattern) are robust to these data quality issues. The affected records represent a small fraction of the total dataset and do not change the direction or magnitude of the trends documented here.

## Unincorporated area counts are a floor, not an exact figure

The CITY TYPE field assigns each record by its mailing-address city name. Seven names exist both as City of LA or Santa Clarita neighborhoods and as small unincorporated pockets on the Registrar-Recorder's official subdistrict list (Chatsworth, Sunland, West Hills, Canyon Country, Newhall, Valencia, Saugus). Address data cannot distinguish a city address from a pocket address sharing the name, so these rows are assigned to the city, the majority jurisdiction. The 237 unincorporated records are therefore a floor. All 13 places labeled Unincorporated Area were validated against the Registrar-Recorder precinct subdistrict list in June 2026; no mislabels were found (Lebec and Valyermo are absent from that electoral list but are genuine unincorporated communities). Exact resolution would require parcel-level jurisdiction lookup, out of scope for this analysis.

## Basic dataset descriptors (first extract, verified June 2026)

48,458 rows, each one inspection event with a unique SERIAL NUMBER; 48,085 within the
study window after the September 30, 2025 cutoff. 37,126 distinct facilities by
FACILITY ID (34,984 by APN); many facilities were inspected more than once. Unit counts
do not exist in the data; PE DESCRIPTION gives size bands only (the largest: 11-20 units,
26,157 inspections; then 5-10 units, 10,645). PROGRAM STATUS by inspection row: 40,673
ACTIVE (83.9%), 7,767 INACTIVE (16.0%), 18 blank, roughly 5.2 to 1; by distinct facility
(latest record) 30,682 to 6,427. SERVICE DESCRIPTION is ROUTINE INSPECTION on 100% of
rows and the RHHP INSPECTION flag is NO on 100% of rows, confirming the analysis scope:
DIB routine inspections only, no RHHP records.
