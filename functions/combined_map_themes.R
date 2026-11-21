library(ggplot2)
library(patchwork)
# Ensure Year is numeric
bibtex_data$Year <- as.numeric(bibtex_data$Year)
# Load the plots
map_plot <- ggplot(world_map_focus, aes(fill = StudyFocus, map_id = region)) +
  geom_map(map = world_map_focus, color = "white", size = 0.1) +  # Country borders
  expand_limits(x = world_map$long, y = world_map$lat) +
  scale_fill_manual(
    values = study_colors,
    name = NULL  # Remove legend title
  ) + 
  coord_map("mollweide") +  # Mollweide projection for a balanced world view
  theme_map() +  
  theme(
    legend.position = "right",  # Show a simple legend on the right
    legend.text = element_text(size = 12),  # Adjust text size
    panel.background = element_rect(fill = "white", color = NA),  # White background
    plot.background = element_rect(fill = "white", color = NA)  # White outer background
  ) +
  guides(fill = guide_legend(reverse = TRUE))  # Invert legend order

# Load the thematic areas plot
thematic_plot <- ggplot(bibtex_thematic, aes(x = Year, y = fct_rev(GroupedThematicAreas), color = GroupedThematicAreas)) +
  geom_hline(yintercept = as.numeric(fct_rev(factor(unique(bibtex_thematic$GroupedThematicAreas)))), 
             color = "gray80", linetype = "dashed") +
  geom_text_repel(aes(label = ShortName), 
                  max.overlaps = 8, segment.color = 'transparent') + 
  scale_x_continuous(
    breaks = seq(min(bibtex_data$Year), max(bibtex_data$Year), 1),
    expand = expansion(mult = c(0.1, 0.1))  
  ) +  
  labs(title = "Publications Categorized by Thematic Areas",
       x = "Year", y = NULL) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.y = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(10, 10, 10, 180, "pt")
  ) +
  coord_cartesian(clip = "off") +
  scale_color_manual(values = thematic_colors)

# Combine the plots vertically
combined_plot <- map_plot / thematic_plot + 
  plot_layout(ncol = 1, heights = c(1.2, 1))  # Adjust heights if necessary

# Save the combined plot
ggsave("figures/plot_combined_map_themes.png", combined_plot, width = 10, height = 9, dpi = 300)
