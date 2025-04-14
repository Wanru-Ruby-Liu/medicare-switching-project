library(dplyr)
library(readr)
library(scales)
options(readr.show_col_types = FALSE)

df <- read_csv("temp/cleaned_2021.csv")

total_count <- nrow(df)

# Create base variables
df <- df %>%
  mutate(
    facility = if_else(dementia == 1, "Memory Care-Licensed AL", "General AL"),
    enrollment = case_when(
      status_2021 == "MA" ~ paste(facility, "MA"),
      status_2021 == "FFS" ~ paste(facility, "FFS")
    ),
    final_status = case_when(
      switch_type == "FFS_stay" ~ "Stay in FFS",
      switch_type == "MA_stay" ~ "Stay in MA",
      switch_type == "MA_switch" ~ "Switching within MA",
      switch_type == "FFS_to_MA" ~ "FFS to MA",
      switch_type == "MA_to_FFS" ~ "MA to FFS",
      switch_type == "Died" ~ "Died"
    )
  )

# Level 1 → 2
facility_counts <- df %>%
  count(facility) %>%
  mutate(
    source = "Total Beneficiaries",
    target = facility,
    label = paste0(facility, " (", n, " - ", percent(n / total_count, accuracy = 0.01), ")"),
    value = n
  )

# Level 2 → 3
enrollment_counts <- df %>%
  count(facility, enrollment) %>%
  mutate(
    source = facility,
    target = enrollment,
    value = n
  )

# Level 3 → 4
final_counts <- df %>%
  count(enrollment, final_status) %>%
  mutate(
    source = enrollment,
    target = final_status,
    value = n
  )

# Combine all edges
links <- bind_rows(
  facility_counts %>% select(source, target, value),
  enrollment_counts,
  final_counts
)

# Create unique node list with readable names
node_names <- unique(c(links$source, links$target))

# Enhance node labels (only at final mapping stage)
node_df <- data.frame(name = node_names) %>%
  left_join(
    df %>% count(facility) %>%
      mutate(label = paste0(facility, " (", n, " - ", percent(n / total_count, accuracy = 0.01), ")")) %>%
      select(name = facility, label),
    by = "name"
  ) %>%
  left_join(
    df %>% count(enrollment) %>%
      mutate(label = paste0(enrollment, " (", n, " - ", percent(n / total_count, accuracy = 0.01), ")")) %>%
      select(name = enrollment, label),
    by = "name",
    suffix = c("", ".enroll")
  ) %>%
  left_join(
    df %>% count(final_status) %>%
      mutate(label = paste0(final_status, " (", n, " - ", percent(n / total_count, accuracy = 0.01), ")")) %>%
      select(name = final_status, label),
    by = "name",
    suffix = c("", ".final")
  ) %>%
  mutate(
    label_final = coalesce(label, label.enroll, label.final),
    label_final = if_else(is.na(label_final), name, label_final)
  ) %>%
  select(name, label = label_final)

# Save
write_csv(links, "temp/figure1_sankey_links.csv")
write_csv(node_df, "temp/figure1_sankey_nodes.csv")





## Draw the Sankey Diagram
library(networkD3)

# Load data
links <- read_csv("temp/figure1_sankey_links.csv")
nodes <- read_csv("temp/figure1_sankey_nodes.csv")

# Map node names to indices
links <- links %>%
  mutate(
    source = match(source, nodes$name) - 1,
    target = match(target, nodes$name) - 1
  )

# Create plot
sankey <- sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = "source",
  Target = "target",
  Value = "value",
  NodeID = "label",
  fontSize = 12,
  nodeWidth = 30,
  sinksRight = FALSE
)

htmlwidgets::saveWidget(sankey, "output/figure1_sankey.html", selfcontained = FALSE)

sankey