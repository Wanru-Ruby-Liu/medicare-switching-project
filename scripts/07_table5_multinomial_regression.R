library(dplyr)
library(readr)
library(nnet)
library(broom)
library(janitor)
options(readr.show_col_types = FALSE)

# Load data
df <- read_csv("temp/cleaned_2021.csv")

# Step 1: Remove those who died
df <- df %>%
  filter(switch_type != "Died")

# Step 2: Create outcome variable for regression
df <- df %>%
  mutate(
    switching_outcome = case_when(
      switch_type %in% c("MA_stay", "FFS_stay") ~ 1,
      switch_type == "MA_to_FFS" ~ 2,
      switch_type == "FFS_to_MA" ~ 3,
      switch_type == "MA_switch" ~ 4
    ) %>% factor()
  )
# Define age group
df <- df %>%
  mutate(age_group = case_when(
    hkcalcage < 65 ~ "<65",
    hkcalcage >= 65 & hkcalcage < 75 ~ "65–74",
    hkcalcage >= 75 & hkcalcage < 85 ~ "75–84",
    hkcalcage >= 85 ~ "85+"
  ))

# Define dual eligibility
dual_codes <- c("01", "02", "03", "04", "05", "06", "08")
df <- df %>%
  mutate(dual = if_else(
    rowSums(across(starts_with("hkdual"), ~ .x %in% dual_codes)) > 0,
    1, 0
  ))

# Step 3: Run multinomial logistic regression
model <- multinom(
  switching_outcome ~ factor(age_group) + hksex + dual + dementia +
    adrd_present + copd_present + diabetes_present +
    hkcu_acute_covdy_20 + hkcu_snf_covdy_20,
  data = df,
  base = 1
)

# Step 4: Extract and tidy results
tidy_mlogit <- tidy(model, conf.int = TRUE, exponentiate = TRUE) %>%
  clean_names()

# Step 5: Save results to CSV
write_csv(tidy_mlogit, "output/table5_mlogit_results.csv")
