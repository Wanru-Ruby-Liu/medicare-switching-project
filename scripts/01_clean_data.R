library(haven)
library(dplyr)
library(lubridate)
library(stringr)
library(readr)

# Define file paths
data_dir <- "data/"
temp_dir <- "temp/"
output_dir <- "output/"

# Step 1: Import AL dementia licensing info
new_al <- read_sas(file.path(data_dir, "new_al21.sas7bdat")) %>%
  select(FacilityID, dementia)

# Step 2: Import 2020 MBSF data for 2021 AL admission cohort (.dta version)
mbsf_2020 <- read_dta(file.path(data_dir, "allmbsf20vars_coh21.dta"))

# Step 3: Import 2021 MBSF + HMO data + dementia indicators (.dta version)
mbsf_2021 <- read_dta(file.path(data_dir, "all_hmo_mbsf21.dta"))

# Step 4: Suffix all variables in 2020 data except bene_id_18900
mbsf_2020_renamed <- mbsf_2020 %>%
  rename_with(~ ifelse(.x == "bene_id_18900", .x, paste0(.x, "_20")))

# Step 5: Merge 2020 MBSF into 2021 MBSF by bene_id
merged <- mbsf_2021 %>%
  left_join(mbsf_2020_renamed, by = "bene_id_18900")

# Step 6: Merge in dementia licensing info by FacilityID
merged <- merged %>%
  left_join(new_al, by = "FacilityID") %>%
  filter(!is.na(dementia))

# Step 7: Filter to selected states
selected_states <- c(2, 1, 4, 6, 10, 16, 13, 14, 15, 22, 20, 23, 24, 26, 25, 
                     27, 34, 28, 31, 29, 33, 36, 37, 38, 39, 41, 42, 44, 45, 
                     49, 47, 50, 52, 53)

merged <- merged %>%
  mutate(hkstate = as.numeric(hkstate)) %>%
  filter(hkstate %in% selected_states)

# Step 8: Define Jan 1 2021 and Jan 1 2022 Medicare enrollment statuses 
# (MA or FFS)
merged <- merged %>%
  mutate(
    status_2021 = case_when(
      hkhmo1 == "C" ~ "MA",
      hkhmo1 == "0" ~ "FFS",
      TRUE ~ NA_character_
    ),
    status_2022 = case_when(
      hkhmo1_22 == "C" ~ "MA",
      hkhmo1_22 == "0" ~ "FFS",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(status_2021))

# Step 9: Create a death indicator for beneficiaries who died between 
# 01-01-2021 and 12-31-2021
merged <- merged %>%
  mutate(
    death_2021 = if_else(!is.na(hkdod) & hkdod <= mdy("12-31-2021"), 1, 0),
    missing_2022 = is.na(status_2022)
  )

# Step 10: Save a version for deaths
died_2021 <- merged %>%
  filter(death_2021 == 1 & missing_2022 == TRUE)

write_csv(died_2021, file.path(temp_dir, "died_2021.csv"))

# Step 11: Exclude those missing 2022 unless they died
cleaned <- merged %>%
  filter(!(missing_2022 == TRUE & death_2021 == 0))

# Step 12: Append back the died group
cleaned <- bind_rows(cleaned, died_2021)

# Step 13: Final status and switching types
cleaned <- cleaned %>%
  mutate(
    status_2022_final = case_when(
      death_2021 == 1 & missing_2022 == TRUE ~ "Died",
      TRUE ~ status_2022
    ),
    switch_type = case_when(
      status_2022_final == "Died" ~ "Died",
      status_2021 == "MA" & status_2022_final == "FFS" ~ "MA_to_FFS",
      status_2021 == "FFS" & status_2022_final == "MA" ~ "FFS_to_MA",
      status_2021 == "MA" & status_2022_final == "MA" & hkcptype01 != hkcptype01_22 ~ "MA_switch",
      status_2021 == "MA" & status_2022_final == "MA" & hkcptype01 == hkcptype01_22 ~ "MA_stay",
      status_2021 == "FFS" & status_2022_final == "FFS" ~ "FFS_stay"
    ),
    from_plan_type = if_else(switch_type == "MA_switch", hkcptype01, NA_character_),
    to_plan_type   = if_else(switch_type == "MA_switch", hkcptype01_22, NA_character_),
    plan_type_change = if_else(
      switch_type == "MA_switch",
      paste0(from_plan_type, "_to_", to_plan_type),
      NA_character_
    )
  )

# Step 14: Save final cleaned dataset for analysis
write_csv(cleaned, file.path(temp_dir, "cleaned_2021.csv"))