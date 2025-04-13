# Set up renv for package management
renv::restore()

# Load libraries (used in scripts)
library(haven)
library(dplyr)
library(lubridate)
library(stringr)
library(readr)


# ---- Step 1: Data Cleaning ----
source("scripts/01_clean_data.R")