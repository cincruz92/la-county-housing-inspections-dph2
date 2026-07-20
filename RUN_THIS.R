# RUN_THIS.R
# The single command that reproduces the six equity R-squared values.
#
# How to use this file:
#   1. Open la-county-housing-inspections-dph.Rproj first (double-click it).
#      This sets the working directory correctly, on any computer.
#   2. Open this file (RUN_THIS.R) if it is not already open.
#   3. Click anywhere on the line below, then click the "Run" button
#      at the top of this pane (or press Ctrl+Enter / Cmd+Enter).
#
# That's it. No typing required. Six PASS lines in the Console below
# mean the published values regenerate from the raw data.
# Full explanation: REPRODUCE.md

source("analysis/replicate_r2.R")
