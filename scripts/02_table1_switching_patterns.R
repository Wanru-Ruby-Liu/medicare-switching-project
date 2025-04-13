# scripts/02_table1_switching_patterns.R

library(dplyr)
library(readr)

# Load cleaned dataset
df <- read_csv("temp/cleaned_2021.csv")

# Step 1: Label MA switching subtypes
df <- df %>%
  mutate(
    status_2022_final = case_when(
      status_2021 == "MA" & status_2022_final == "MA" & switch_type == "MA_stay"   ~ "MA_stay",
      status_2021 == "MA" & status_2022_final == "MA" & switch_type == "MA_switch" ~ "MA_switch",
      TRUE ~ status_2022_final
    )
  )

# Step 2: Function to generate dementia vs non-dementia switching summaries
generate_switch_table <- function(data, dementia_val, outpath) {
  data %>%
    filter(dementia == dementia_val) %>%
    count(status_2021, status_2022_final, switch_type, name = "count") %>%
    group_by(status_2021) %>%
    mutate(row_total = sum(count), row_pct = 100 * count / row_total) %>%
    ungroup() %>%
    write_csv(outpath)
}

# Step 3: Table 1 outputs
generate_switch_table(df, dementia_val = 0, outpath = "output/table1_nondementia_switching.csv")
generate_switch_table(df, dementia_val = 1, outpath = "output/table1_dementia_switching.csv")

# Step 4: Chi-square test results
df_chi <- df %>%
  mutate(
    ffs_to_ma = switch_type == "FFS_to_MA",
    ma_to_ffs = switch_type == "MA_to_FFS",
    ma_switch = switch_type == "MA_switch"
  )

cat("Chi-square tests (by dementia licensing):\n")
print(chisq.test(table(df_chi$dementia, df_chi$ffs_to_ma)))
print(chisq.test(table(df_chi$dementia, df_chi$ma_to_ffs)))
print(chisq.test(table(df_chi$dementia, df_chi$ma_switch)))

# Step 5: Table 1b — switchers only
df_switchers <- df %>%
  mutate(switcher = case_when(
    switch_type %in% c("MA_to_FFS", "FFS_to_MA", "MA_switch") ~ 1,
    !(switch_type %in% c("MA_to_FFS", "FFS_to_MA", "MA_switch")) & death_2021 != 1 ~ 0,
    TRUE ~ NA_real_
  )) %>%
  filter(switcher == 1)

# Table 1b — MC AL switchers
df_switchers %>%
  filter(dementia == 1) %>%
  count(status_2021, switch_type, name = "count") %>%
  group_by(status_2021) %>%
  mutate(row_total = sum(count), row_pct = 100 * count / row_total) %>%
  ungroup() %>%
  write_csv("output/table1b_switcher_mc_switching.csv")

# Table 1b — General AL switchers
df_switchers %>%
  filter(dementia == 0) %>%
  count(status_2021, switch_type, name = "count") %>%
  group_by(status_2021) %>%
  mutate(row_total = sum(count), row_pct = 100 * count / row_total) %>%
  ungroup() %>%
  write_csv("output/table1b_switcher_general_switching.csv")
