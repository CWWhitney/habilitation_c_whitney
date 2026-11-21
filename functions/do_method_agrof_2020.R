library(ggplot2)
library(ggforce)

# Define data for four process stages
stages <- data.frame(
  x = c(1, 3, 5, 7),  # Spread boxes apart
  y = c(3, 3, 3, 3),  # Keep on the same horizontal line
  label = c("Stage 1\nIdentification\nof Experts", 
            "Stage 2\nModel\nDevelopment", 
            "Stage 3\nProbability\nAssessment", 
            "Stage 4\nSimulation &\nSensitivity"),
  color = c("#A6CEE3", "#B2DF8A", "#FB9A99", "#FDBF6F")
)

# Define arrows for process flow (straight arrows)
arrows <- data.frame(
  x = c(1.7, 3.7, 5.7),  # Start at right edge of each box
  y = rep(3, 3),
  xend = c(2.3, 4.3, 6.3),  # End at left edge of the next box
  yend = rep(3, 3)
)

# Create ggplot figure
do_method_agrof_2020 <- ggplot() +
  # Draw process stages
  geom_rect(data = stages, aes(xmin = x-0.8, xmax = x+0.8, ymin = y-0.5, ymax = y+0.5, fill = color), 
            color = "black", size = 1) +
  geom_text(data = stages, aes(x = x, y = y, label = label), 
            size = 5, fontface = "bold", color = "black", family = "serif") +
  
  # Draw process arrows
  geom_segment(data = arrows, aes(x = x, y = y, xend = xend, yend = yend), 
               arrow = arrow(length = unit(0.2, "inches")), size = 1, color = "black") +
  
  # Set styling
  scale_fill_identity() +
  theme_void() +
  labs(title = "Decision Analysis Model Development Process") +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5, family = "serif"),
    text = element_text(family = "serif")
  )

# Save the figure as a wide and short image
ggsave("figures/do_method_agrof_2020.png", do_method_agrof_2020, width = 12, height = 2, dpi = 300)

