# Plot altmetric data ####

library(ggplot2)
library(stringr)
library(dplyr)
library(tidyr)
library(RColorBrewer)

# Function to shorten BibRef names (extract first word & year)
shorten_bibref <- function(bibref) {
  parts <- unlist(str_split(bibref, "_"))  # Split by underscore
  paste0(str_to_title(parts[1]), " et al. ", parts[length(parts)])  # First word + "et al." + Year
}

# get data_final ####
# Takes a minute to run and requires internet
# source("functions/get_altmetric_data.R")

# Apply function to shorten paper names
data_altmetric <- data_final  # Preserve original data
data_altmetric$ShortName <- sapply(data_altmetric$BibRef, shorten_bibref)

# Detect duplicate author-year pairs and assign 'a', 'b', etc.
data_altmetric <- data_altmetric %>%
  group_by(ShortName) %>%
  mutate(dup_count = row_number(),
         total_dups = n()) %>%
  ungroup() %>%
  mutate(ShortName = ifelse(total_dups > 1, paste0(ShortName, letters[dup_count]), ShortName)) %>%
  select(-dup_count, -total_dups)  # Remove temporary columns

# Assign thematic area categories
thematic_mapping <- c(
  "Biodiversity Conservation" = "Biodiversity\nConservation",
  "Climate Change Mitigation/Adaptation" = "Climate Change Mitigation\nAdaptation",
  "Livelihoods and Socio-Economic Impact" = "Livelihoods &\nSocio-Economic Impact",
  "Stakeholder and Community Engagement" = "Stakeholder &\nCommunity Engagement",
  "Sustainability" = "Sustainability"
)

source("functions/create_bibtex_data.R")

data_altmetric <- data_altmetric %>%
  left_join(bibtex_data %>% select(BibRef, ThematicAreas) %>% rename(ThematicArea = ThematicAreas), by = "BibRef") %>%
  mutate(ThematicArea = recode(ThematicArea, !!!thematic_mapping))

# Count number of papers per thematic area
thematic_counts <- data_altmetric %>%
  count(ThematicArea, name = "ThematicCount")

data_altmetric <- data_altmetric %>%
  left_join(thematic_counts, by = "ThematicArea")

# Arrange papers by Thematic Area, then Altmetric Percentile, then Citations
data_altmetric <- data_altmetric %>% arrange(ThematicArea, desc(Context_Pct), desc(Citations))

# Select relevant metrics and rename columns for clarity
plot_data <- data_altmetric %>%
  select(ShortName, ThematicArea, ThematicCount, Context_Pct, Citations, Mentions, Readers_Count) %>%
  pivot_longer(cols = -c(ShortName, ThematicArea, ThematicCount), names_to = "Metric", values_to = "Value") %>%
  mutate(Metric = case_when(
    Metric == "Context_Pct" ~ "Altmetric Percentile",
    Metric == "Mentions" ~ "Mentions",
    Metric == "Readers_Count" ~ "Readers",
    Metric == "Citations" ~ "Citations",
    TRUE ~ Metric
  ))

# Generate the plot
plot_altmetric_data <- ggplot(plot_data, aes(x = Metric, y = ShortName, label = Value)) +
  geom_hline(yintercept = unique(plot_data$ShortName), linetype = "dotted", color = "lightgrey") +  # Add horizontal lines
  geom_text(aes(color = Value), size = 3) +  # Display values as colored text
  scale_color_gradientn(colors = c(brewer.pal(8, "Dark2")), na.value = "black") +  # Emphasize value differences
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),  # Rotate x-axis labels
    axis.text.y = element_text(size = 7),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    strip.text.y.left = element_text(angle = 0, vjust = 0.5, hjust = 0.5, size = 9),  # Rotate facet labels
    strip.placement = "outside",  # Keeps facet labels positioned at the top
    legend.position = "none",  # Remove legend
    axis.title = element_blank()  # Remove axis titles
  ) +
  facet_grid(ThematicArea ~ ., scales = "free", space = "free", switch = "y")


ggsave("figures/plot_altmetric_data.png", plot_altmetric_data, width = 7, height = 5, dpi = 300, bg = "white")
