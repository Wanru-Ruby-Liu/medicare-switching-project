# Set up renv for package management
renv::restore()

# Load libraries (used in scripts)
library(haven)
library(dplyr)
library(lubridate)
library(stringr)
library(readr)
library(scales)
library(networkD3)

# ---- Step 1: Data Cleaning ----
source("scripts/01_clean_data.R")

# ---- Step 2: Table 1: Switching Patterns by Dementia Licensing ----
source("scripts/02_table1_switching_patterns.R")

# ---- Step 3: Figure 1 – Sankey Diagram of Medicare Switching Paths ----
source("scripts/03_figure1_sankey.R")