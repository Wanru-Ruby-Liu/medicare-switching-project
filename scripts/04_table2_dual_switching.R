library(dplyr)
library(readr)

# Load data
df <- read_csv("temp/cleaned_2021.csv")

# Define dual eligibility
dual_codes <- c("01", "02", "03", "04", "05", "06", "08")
df <- df %>%
  mutate(dual = if_else(
    rowSums(across(starts_with("hkdual"), ~ .x %in% dual_codes)) > 0,
    1, 0
  ))

# --- Table 2: Switching by Dual Status (Full Sample) ---

prepare_dual_table <- function(data, dual_val, outpath) {
  data %>%
    filter(dual == dual_val) %>%
    mutate(
      status_2022_final = case_when(
        status_2021 == "MA" & status_2022_final == "MA" & switch_type == "MA_stay" ~ "MA_stay",
        status_2021 == "MA" & status_2022_final == "MA" & switch_type == "MA_switch" ~ "MA_switch",
        TRUE ~ status_2022_final
      )
    ) %>%
    count(status_2021, status_2022_final, switch_type, name = "count") %>%
    group_by(status_2021) %>%
    mutate(row_total = sum(count), row_pct = 100 * count / row_total) %>%
    ungroup() %>%
    write_csv(outpath)
}

prepare_dual_table(df, dual_val = 1, outpath = "output/table2_dual_switching.csv")
prepare_dual_table(df, dual_val = 0, outpath = "output/table2_nondual_switching.csv")

# --- Table 2b: Switching by Dual Status (Switchers Only) ---

df_switchers <- df %>%
  mutate(switcher = case_when(
    switch_type %in% c("MA_to_FFS", "FFS_to_MA", "MA_switch") ~ 1,
    !(switch_type %in% c("MA_to_FFS", "FFS_to_MA", "MA_switch")) & death_2021 != 1 ~ 0,
    TRUE ~ NA_real_
  )) %>%
  filter(switcher == 1)

prepare_dual_switchers <- function(data, dual_val, outpath) {
  data %>%
    filter(dual == dual_val) %>%
    count(status_2021, switch_type, name = "count") %>%
    group_by(status_2021) %>%
    mutate(row_total = sum(count), row_pct = 100 * count / row_total) %>%
    ungroup() %>%
    write_csv(outpath)
}

prepare_dual_switchers(df_switchers, dual_val = 1, outpath = "output/table2b_switcher_dual_switching.csv")
prepare_dual_switchers(df_switchers, dual_val = 0, outpath = "output/table2b_switcher_nondual_switching.csv")