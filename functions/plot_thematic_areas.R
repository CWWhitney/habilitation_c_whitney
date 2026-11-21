# Load required libraries
library(ggplot2)
library(ggrepel) # For labels
library(dplyr)
library(stringr)  # For text processing
library(RColorBrewer)

source("functions/create_bibtex_data.R")

# Ensure Year is numeric
bibtex_data$Year <- as.numeric(bibtex_data$Year)

table(bibtex_data$ThematicAreas)
# Biodiversity Conservation 7 Climate Change Mitigation/Adaptation 8 
# Livelihoods and Socio-Economic Impact 4 Stakeholder and Community Engagement 5
# Sustainability 8

source("functions/group_bibrefs_for_markdown.R")

group_bibrefs_for_markdown(bibtex_data, "ThematicAreas", "Biodiversity Conservation")
# "@do_decision_2020, @kuyah_agroforestry_2019, @oluoch_integrated_2022,
# @oluoch_predicted_2024, @oluoch_indigenous_2023, @nyamukuru_allometric_2023,
# @tabuti_priority_2022"
group_bibrefs_for_markdown(bibtex_data, "ThematicAreas", "Climate Change Mitigation/Adaptation")
# "@whitney_balancing_2025, @netter_agroforestry_2022, @yigzaw_stochastic_2019,
# @luedeling_limitations_2022, @rojas_adapting_2021, @tamba_stochastic_2021,
# @ruett_model-based_2020, @fernandez_prospects_2020"
group_bibrefs_for_markdown(bibtex_data, "ThematicAreas", "Livelihoods and Socio-Economic Impact")
# "@whitney_probabilistic_2018, @do_adapting_2024, @liman_harou_crop_2021,
# @burbano-figueroa_profitability_2022"
group_bibrefs_for_markdown(bibtex_data, "ThematicAreas", "Stakeholder and Community Engagement")
# "@luu_how_2024, @luu_decision_2022, @luu_stakeholder_2024,
# @mcgonigle_knowledge_2020, @sulaiman_socio-cultural_2021"
group_bibrefs_for_markdown(bibtex_data, "ThematicAreas", "Sustainability")
# "@whitney_decision_2023, @fernandez_prioritizing_2022,
# @lanzanova_improving_2019, @liman_harou_mapping_2020,
# @burbano-figueroa_farm-planning_2022, @ruett_assessing_2022,
# @ruett_hyperspectral_2022, @kamau_holistic_2021"


# Define ThematicAreas categories
thematic_groups <- c(
  "Biodiversity Conservation" = "Biodiversity Conservation",
  "Climate Change Mitigation/Adaptation" = "Climate Change Mitigation/Adaptation",
  "Livelihoods and Socio-Economic Impact" = "Livelihoods & Socio-Economic Impact",
  "Stakeholder and Community Engagement" = "Stakeholder & Community Engagement",
  "Sustainability" = "Sustainability"
)

# Modify y-axis labels to include line breaks
thematic_labels <- c(
  "Biodiversity Conservation" = "Biodiversity\nConservation",
  "Climate Change Mitigation/Adaptation" = "Climate Change\nMitigation & Adaptation",
  "Livelihoods & Socio-Economic Impact" = "Livelihoods &\nSocio-Economic Impact",
  "Stakeholder & Community Engagement" = "Stakeholder &\nCommunity Engagement",
  "Sustainability" = "Sustainability"
)

# Apply thematic area groupings
bibtex_thematic <- bibtex_data %>%
  select(BibRef, Year, ThematicAreas) %>%
  drop_na() %>%
  mutate(GroupedThematicAreas = recode(ThematicAreas, !!!thematic_groups))

# Function to shorten BibRef names (extract first word & year)
shorten_bibref <- function(bibref) {
  parts <- unlist(str_split(bibref, "_"))  # Split by underscore
  paste0(str_to_title(parts[1]), " et al. ", parts[length(parts)])  # First word + "et al." + Year
}

# Apply function to shorten paper names
bibtex_thematic$ShortName <- sapply(bibtex_thematic$BibRef, shorten_bibref)

# Detect duplicate author-year pairs and assign 'a', 'b', etc.
bibtex_thematic <- bibtex_thematic %>%
  group_by(ShortName, Year) %>%
  mutate(dup_count = row_number(),
         total_dups = n()) %>%
  ungroup() %>%
  mutate(ShortName = ifelse(total_dups > 1, paste0(ShortName, letters[dup_count]), ShortName)) %>%
  select(-dup_count, -total_dups)  # Remove temporary columns

# Assign colors for each thematic area
thematic_list <- unique(bibtex_thematic$GroupedThematicAreas)
thematic_colors <- setNames(brewer.pal(length(thematic_list), "Dark2"), thematic_list)

# Make the year numeric again
bibtex_data$Year <- as.numeric(bibtex_data$Year)
bibtex_thematic$Year <- as.numeric(bibtex_thematic$Year)
# Generate plot with Thematic Areas as y-axis
thematic_plot <- ggplot(bibtex_thematic, aes(x = Year, y = fct_rev(GroupedThematicAreas), 
                                             color = GroupedThematicAreas)) +
  geom_hline(yintercept = as.numeric(fct_rev(factor(unique(bibtex_thematic$GroupedThematicAreas)))), 
             color = "gray80", linetype = "dashed") +
  geom_text_repel(aes(label = ShortName), 
                  max.overlaps = 20, segment.color = 'transparent') + 
  scale_x_continuous(
    breaks = seq(min(bibtex_data$Year), max(bibtex_data$Year), 1),
    expand = expansion(mult = c(0.1, 0.1))  
  ) +  
  labs(x = "Year of Publication", y = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(0, 0, 0, 180, "pt")
  ) +
  coord_cartesian(clip = "off") +
  scale_color_manual(values = thematic_colors)

# Add custom-colored y-axis labels
for (i in seq_along(thematic_list)) {
  thematic_plot <- thematic_plot + annotate("text", 
                                            x = min(bibtex_data$Year) - 1,  
                                            y = thematic_list[i], 
                                            label = thematic_labels[thematic_list[i]],  
                                            color = thematic_colors[thematic_list[i]], 
                                            size = 5, hjust = 1)
}


# Save the figure
ggsave("figures/plot_thematic_areas.png", thematic_plot, width = 12, height = 5, dpi = 300, bg = "white")
