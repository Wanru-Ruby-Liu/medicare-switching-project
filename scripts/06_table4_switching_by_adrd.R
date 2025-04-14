library(dplyr)
library(readr)
options(readr.show_col_types = FALSE)

# Load cleaned dataset
df <- read_csv("temp/cleaned_2021.csv")

# ---- Function to summarize switching types by ADRD group ----
summarize_adrd_switching <- function(data, adrd_value, out_csv) {
  data %>%
    filter(adrd_present == adrd_value) %>%
    count(status_2022_final, switch_type, name = "count") %>%
    group_by(status_2022_final) %>%
    mutate(
      row_total = sum(count),
      row_pct = 100 * count / row_total
    ) %>%
    ungroup() %>%
    write_csv(out_csv)
}

# ---- ADRD group ----
summarize_adrd_switching(
  df,
  adrd_value = 1,
  out_csv = "output/table4_adrd_switching.csv"
)

# ---- Non-ADRD group ----
summarize_adrd_switching(
  df,
  adrd_value = 0,
  out_csv = "output/table4_nonadrd_switching.csv"
)