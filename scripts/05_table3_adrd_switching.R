library(dplyr)
library(readr)

# Load cleaned dataset
df <- read_csv("temp/cleaned_2021.csv")

# ---- Step 1: Create binary indicators for switching types ----
df <- df %>%
  mutate(
    ffs_stay   = switch_type == "FFS_stay",
    ffs_to_ma  = switch_type == "FFS_to_MA",
    ma_stay    = switch_type == "MA_stay",
    ma_switch  = switch_type == "MA_switch",
    ma_to_ffs  = switch_type == "MA_to_FFS",
    died       = switch_type == "Died"
  )

# ---- Step 2: Chi-square tests: ADRD status vs. various outcomes ----
cat("Chi-square: ADRD vs. Dementia-Licensed AL\n")
print(chisq.test(table(df$adrd_present, df$dementia)))

cat("Chi-square: ADRD vs. FFS stay\n")
print(chisq.test(table(df$adrd_present, df$ffs_stay)))

cat("Chi-square: ADRD vs. FFS to MA\n")
print(chisq.test(table(df$adrd_present, df$ffs_to_ma)))

cat("Chi-square: ADRD vs. MA stay\n")
print(chisq.test(table(df$adrd_present, df$ma_stay)))

cat("Chi-square: ADRD vs. MA switch\n")
print(chisq.test(table(df$adrd_present, df$ma_switch)))

cat("Chi-square: ADRD vs. MA to FFS\n")
print(chisq.test(table(df$adrd_present, df$ma_to_ffs)))

cat("Chi-square: ADRD vs. Died\n")
print(chisq.test(table(df$adrd_present, df$died)))

# ---- Step 3: Summary counts and proportions ----
table3_summary <- df %>%
  count(adrd_present, dementia, name = "count") %>%
  group_by(adrd_present) %>%
  mutate(total_adrd_group = sum(count),
         pct = 100 * count / total_adrd_group) %>%
  ungroup()

write_csv(table3_summary, "output/table3_adrd_dementia_AL.csv")