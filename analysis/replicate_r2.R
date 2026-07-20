# replicate_r2.R
# Reproduces the six equity R-squared values in the case study
# "Public Health in Housing: An Analysis of LA County Inspection Trends"
# from the raw public files, using base R only. No packages required.
#
# Expected inputs (paths relative to the repository root):
#   data/county/Environmental_Health_Housing_Routine_and_Complaint_Inspections.csv
#   data/acs/Table_1_Median_Household_Income.csv
#   data/acs/Table_2_Race_Or_Ethnicity.csv
#   data/acs/Table_3_Rent_Burden.csv
# See REPRODUCE.md for details. The three ACS CSVs are included directly in the
# repository alongside the original xlsx files, which remain the version of record.
#
# Run from the repository root:
#   Rscript analysis/replicate_r2.R
#
# Expected output: n = 254 and the six R-squared values
# income 0.0155, rent burden 0.0040, Hispanic 0.0153,
# White 0.0203, Black 0.0196, Asian 0.0047.

# ---- 1. Read the raw inspections file ----
# The raw file is not valid UTF-8 (it contains Windows-encoded characters
# in facility names), so it is read as raw lines in latin1 first and then
# parsed. Reading it directly with read.csv(fileEncoding=...) silently
# truncates the file on some systems.
raw_lines <- readLines(
  "data/county/Environmental_Health_Housing_Routine_and_Complaint_Inspections.csv",
  encoding = "latin1"
)
insp <- read.csv(text = raw_lines, stringsAsFactors = FALSE)

# Column headers in the raw file contain line breaks; read.csv converts
# them to dots. The three columns used here are ACTIVITY.DATE,
# SERIAL.NUMBER, and ZIP.

insp$ACTIVITY.DATE <- as.Date(trimws(insp$ACTIVITY.DATE), format = "%m/%d/%Y")

# ---- 2. Dedupe and apply the analysis window ----
# One record per inspection: keep the first row for each SERIAL NUMBER.
insp <- insp[!duplicated(insp$SERIAL.NUMBER), ]

# Analysis window: January 1, 2023 through September 30, 2025.
insp <- insp[insp$ACTIVITY.DATE >= as.Date("2023-01-01") &
             insp$ACTIVITY.DATE <= as.Date("2025-09-30"), ]

cat("Unique inspections in window:", nrow(insp), "(expected 48085)\n")

# ---- 3. Per-ZIP counts on matched nine-month windows ----
insp$ZIP5 <- substr(trimws(as.character(insp$ZIP)), 1, 5)
all_zips <- sort(unique(insp$ZIP5))
cat("Distinct ZIPs:", length(all_zips), "(expected 289)\n")

in_2023 <- insp$ACTIVITY.DATE <= as.Date("2023-09-30")
in_2025 <- insp$ACTIVITY.DATE >= as.Date("2025-01-01")

n2023 <- table(factor(insp$ZIP5[in_2023], levels = all_zips))
n2025 <- table(factor(insp$ZIP5[in_2025], levels = all_zips))

zips <- data.frame(
  ZIP5  = all_zips,
  n2023 = as.integer(n2023),
  n2025 = as.integer(n2025),
  stringsAsFactors = FALSE
)

# ---- 4. Read the ACS tables and join by ZIP ----
inc  <- read.csv("data/acs/Table_1_Median_Household_Income.csv", stringsAsFactors = FALSE)
race <- read.csv("data/acs/Table_2_Race_Or_Ethnicity.csv",        stringsAsFactors = FALSE)
rent <- read.csv("data/acs/Table_3_Rent_Burden.csv",              stringsAsFactors = FALSE)

inc$ZIP5  <- trimws(as.character(inc$name))
race$ZIP5 <- trimws(as.character(race$name))
rent$ZIP5 <- trimws(as.character(rent$name))

acs <- merge(inc[,  c("ZIP5", "B19013001")],
             race[, c("ZIP5", "B03002001", "B03002003", "B03002004",
                      "B03002006", "B03002012")], by = "ZIP5")
acs <- merge(acs,
             rent[, c("ZIP5", "B25070001", "B25070007", "B25070008",
                      "B25070009", "B25070010")], by = "ZIP5")

d <- merge(zips, acs, by = "ZIP5", all.x = TRUE)

# ---- 5. Exclusions, applied in the documented order ----
# The order is part of the sample definition. Changing it changes n.

# Step 1: drop ZIPs with no ACS match (includes data-entry-error ZIPs
# that fail the Census join because the ZIP itself is wrong).
step1 <- d[!is.na(d$B03002001), ]
cat("Excluded, no ACS match:", nrow(d) - nrow(step1), "(expected 24)\n")

# Step 2: drop ZIPs with no reportable median income. Census Reporter
# exports use a large negative placeholder for suppressed estimates.
step2 <- step1[!is.na(step1$B19013001) & step1$B19013001 >= 0, ]
cat("Excluded, invalid income:", nrow(step1) - nrow(step2), "(expected 6)\n")

# Step 3: drop ZIPs with zero inspections in the Jan-Sep 2023 baseline.
step3 <- step2[step2$n2023 > 0, ]
cat("Excluded, no 2023 baseline:", nrow(step2) - nrow(step3), "(expected 5)\n")

cat("Final sample n =", nrow(step3), "(expected 254)\n\n")

# ---- 6. Derived variables ----
s <- step3
s$decline <- (s$n2025 - s$n2023) / s$n2023 * 100
s$income  <- s$B19013001
s$burden  <- (s$B25070007 + s$B25070008 + s$B25070009 + s$B25070010) /
             s$B25070001 * 100
s$hispanic <- s$B03002012 / s$B03002001 * 100
s$white    <- s$B03002003 / s$B03002001 * 100
s$black    <- s$B03002004 / s$B03002001 * 100
s$asian    <- s$B03002006 / s$B03002001 * 100

# ---- 7. Six bivariate regressions ----
vars <- c(income = "income", burden = "burden", hispanic = "hispanic",
          white = "white", black = "black", asian = "asian")
expected <- c(income = 0.0155, burden = 0.0040, hispanic = 0.0153,
              white = 0.0203, black = 0.0196, asian = 0.0047)

cat(sprintf("%-10s %-8s %-8s %s\n", "variable", "R2", "expected", "match"))
for (v in names(vars)) {
  fit <- lm(reformulate(vars[v], response = "decline"), data = s)
  r2  <- round(summary(fit)$r.squared, 4)
  ok  <- if (r2 == expected[v]) "PASS" else "FAIL"
  cat(sprintf("%-10s %-8.4f %-8.4f %s\n", v, r2, expected[v], ok))
}
