# Load required libraries
library(tidyverse)
library(ggthemes)

# Load world map data
world_map <- map_data("world") %>% 
  filter(!long > 180)  # Ensure longitude is within bounds

# Define a lookup table for country highlights
highlight_countries <- c(
  "Uganda", "Europe", "South Africa", "Chile", "Vietnam", "Costa Rica",
  "Kenya", "Burkina Faso", "Ethiopia", "Colombia", "Germany", "Syria"
)

# Assign colors: blue for highlights, gray for others
highlight_colors <- c(
  "Uganda" = "#377eb8",
  "Europe" = "#6a9ae2",
  "South Africa" = "#4f83cc",
  "Chile" = "#265dab",
  "Vietnam" = "#1e468c",
  "Costa Rica" = "#0b2d5a",
  "Kenya" = "#0c3c78",
  "Burkina Faso" = "#6c8cd5",
  "Ethiopia" = "#3d6fb6",
  "Colombia" = "#2c5399",
  "Germany" = "#184075",
  "Syria" = "#0f2a57"
)

# Create `world_map_focus` to include the necessary regions
world_map_focus <- world_map %>%
  mutate(GeographicalFocus = ifelse(region %in% highlight_countries, region, "Other"))

# Create a single blue category for all study locations
world_map_focus <- world_map_focus %>%
  mutate(StudyFocus = ifelse(GeographicalFocus != "Other", "Study Locations", "Other"))

# Define colors: dark blue for study locations, light blue for others
study_colors <- c("Study Locations" = "#0c3c78", "Other" = "lightblue")

# **Plot the map using GeographicalFocus for fill**
# **Plot the map using StudyFocus for fill**
plot_study_locations <- ggplot(world_map_focus, aes(fill = StudyFocus, map_id = region)) +
  geom_map(map = world_map_focus, color = "white", size = 0.1) +  # Country borders
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_manual(
    values = study_colors,
    name = NULL  # Remove legend title
  ) + 
  coord_map("mollweide") +  # Mollweide projection for a balanced world view
  theme_map() +  
  theme(
    legend.position = c(0.6, 0.2),  # Show a simple legend on the right
    legend.text = element_text(size = 12),  # Adjust text size
    panel.background = element_rect(fill = "white", color = NA),  # White background
    plot.background = element_rect(fill = "white", color = NA),  # White outer background
    plot.margin = unit(c(0,0,0,0), "cm")
  ) +
  guides(fill = guide_legend(reverse = TRUE)) +  # Invert legend order
#Africa
  annotate("text", x = 14, y = 5, label = "Whitney et al. 2018") +  # Uganda (shift west)
  annotate("text", x = 9, y = 2, label = "Nyamukuru et al. 2023") +  # Uganda
  annotate("text", x = 10, y = -1, label = "Tabuti et al. 2022") +  # Uganda
  annotate("text", x = -26, y = 12, label = "Lanzanova et al. 2019") +  # Burkina Faso
  annotate("text", x = 60, y = 11, label = "Yigzaw et al. 2019") +  # Ethiopia
  annotate("text", x = 70, y = 8, label = "Liman et al. 2020, 2021") +  # Ethiopia
  annotate("text", x = 20, y = 19, label = "Sub-Sahara Africa Scope\nKuyah et al. 2019") +  # Kenya
  annotate("text", x = 70, y = 1, label = "Oluoch et al. 2022, 2023, 2024") +  # Kenya
  annotate("text", x = 61, y = -2, label = "Luedeling et al. 2022") +  # Kenya
  annotate("text", x = 57, y = -5, label = "Kamau et al. 2021") +  # Kenya
  annotate("text", x = 55, y = -8, label = "Tamba et al. 2021") +  # Kenya
  annotate("text", x = -5, y = -30, label = "Whitney et al. 2025") +  # South Africa
  # C. & S. America
  annotate("text", x = -98, y = -25, label = "Fernandez et al. 2020") +  # Chile
  annotate("text", x = -40, y = -5, label = "Latin America and the Caribbean\nFernandez et al. 2022") + # Latin America and the Caribbean
  annotate("text", x = -94, y = -33, label = "Rojas et al. 2021") +  # Chile
  annotate("text", x = -109, y = 3, label = "Burbano-Figueroa et al. 2022a,b") +  # Colombia
  annotate("text", x = -105, y = 10, label = "Netter et al. 2022") +  # Costa Rica
  # Global
  annotate("text", x = -45, y = 35, label = "Global Scope\nWhitney et al. 2023") +  # Europe (Central)
  annotate("text", x = -45, y = 29, label = "Mcgonigle et al. 2020") +  # Europe (North)
  # Europe
  annotate("text", x = 47, y = 50, label = "Ruett et al. 2020, 2022a,b") +  # Germany
  # Asia
  annotate("text", x = 127, y = 18, label = "Do et al. 2020, 2024") +  # Vietnam
  annotate("text", x = 127, y = 15, label = "Luu et al. 2024a,b") +  # Vietnam (South China Sea)
  annotate("text", x = 127, y = 12, label = "Luu et al. 2022") +  # Vietnam
  # Middle East
  annotate("text", x = 63, y = 35, label = "Sulaiman et al. 2021")   # Syria

# Save the figure as a wide and short image
ggsave("figures/plot_study_locations_map.png", plot_study_locations, width = 15, height = 7, dpi = 300)

# Save the map and thematic timeline together

# source("functions/plot_thematic_areas.R")

# library(patchwork)
        
# plot_map_themes <- plot_spacer() / plot_study_locations  / plot_spacer() / thematic_plot + plot_layout(heights = c(-0.99, 4.5, -0.99, 1))

# ggsave("figures/plot_map_themes.png", plot_map_themes, width = 17, height = 10, dpi = 300)

