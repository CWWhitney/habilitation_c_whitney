# Load required libraries
library(ggplot2)
library(ggrepel) # For labels
library(dplyr)
library(stringr)  # For text processing

# Ensure Year is numeric
bibtex_data$Year <- as.numeric(bibtex_data$Year)


# Define method groupings 
method_groups <- c(
  # Decision Analysis - Split into 3 groups
  "Monte Carlo" = "Probabilistic & Monte Carlo Approaches",
  "Probabilistic decision analysis" = "Probabilistic & Monte Carlo Approaches",
  "Probabilistic Cost-Benefit Analysis" = "Probabilistic & Monte Carlo Approaches",
  
  "Portfolio Theory" = "Optimization & Portfolio Methods",
  "Stochastic Impact Evaluation" = "Optimization & Portfolio Methods",
  "Simulation" = "Optimization & Portfolio Methods",
  
  "Decision Analysis" = "Decision Support & Trade-off Analysis",
  "Meta Analysis" = "Decision Support & Trade-off Analysis",
  "Partial Budget Analysis" = "Decision Support & Trade-off Analysis",
  
  # Agroecology - Split into 2 groups
  "CropModels" = "Agroecological Modeling & Forecasting",
  "Mapping" = "Agroecological Modeling & Forecasting",
  "Hyperspectral" = "Agroecological Modeling & Forecasting",
  
  "Stakeholder Engagement" = "Agroecological Policy & System Evaluations",
  "Systems thinking" = "Agroecological Policy & System Evaluations",
  "Impact pathways" = "Agroecological Policy & System Evaluations",
  
  # Ecological & Ethnobotanical
  "Ethnoecology" = "Ecological & Ethnobotanical",
  "Exploratory Quantitative Ethnobotany" = "Ecological & Ethnobotanical",
  
  # Others
  "Knowledge Brokering" = "Agroecological Policy & System Evaluations",  # Closely related to Stakeholder Engagement
  "Allometric" = "Agroecological Modeling & Forecasting",  # Often used for biomass and ecosystem modeling
  "Exploratory Quantitative Ethnobotany" = "Ecological & Ethnobotanical",  # Similar to Ethnoecology
  "Multivariate Analysis" = "Optimization & Portfolio Methods"  # Often used for trade-offs & decision-making
)


# Modify y-axis labels to include line breaks
method_labels <- c(
  "Probabilistic & Monte Carlo Approaches" = "Probabilistic &\nMonte Carlo Approaches",
  "Optimization & Portfolio Methods" = "Optimization &\nPortfolio Methods",
  "Decision Support & Trade-off Analysis" = "Decision Support &\nTrade-off Analysis",
  "Agroecological Modeling & Forecasting" = "Agroecological Modeling &\nForecasting",
  "Agroecological Policy & System Evaluations" = "Agroecological Policy &\nSystem Evaluations",
  "Ecological & Ethnobotanical" = "Ecological &\nEthnobotanical"
)

# Apply method groupings
bibtex_methods <- bibtex_data %>%
  select(BibRef, Year, Methods) %>%
  drop_na()  %>%
  mutate(GroupedMethods = recode(Methods, !!!method_groups, .default = "Agroecological Policy & System Evaluations"))  # Group methods
  #mutate(GroupedMethods = recode(Methods, !!!method_groups, .default = "Unassigned"))

# Function to shorten BibRef names (extract first word & year)
shorten_bibref <- function(bibref) {
  parts <- unlist(str_split(bibref, "_"))  # Split by underscore
  paste0(str_to_title(parts[1]), " et al. ", parts[length(parts)])  # First word + "et al." + Year
}

# Apply function to shorten paper names
bibtex_methods$ShortName <- sapply(bibtex_methods$BibRef, shorten_bibref)

# Detect duplicate author-year pairs and assign 'a', 'b', etc.
bibtex_methods <- bibtex_methods %>%
  group_by(ShortName, Year) %>%  # Group by both author and year
  mutate(dup_count = row_number(),
         total_dups = n()) %>%  # Count total duplicates in each group
  ungroup() %>%
  mutate(ShortName = ifelse(total_dups > 1, paste0(ShortName, letters[dup_count]), ShortName)) %>%
  select(-dup_count, -total_dups)  # Remove temporary columns

# Automatically assign colors for each method group
method_list <- unique(bibtex_methods$GroupedMethods)
library(RColorBrewer)
method_colors <- setNames(brewer.pal(length(method_list), "Dark2"), method_list)

# Generate base plot with inverted y-axis
method_groups <- ggplot(bibtex_methods, aes(x = Year, y = fct_rev(GroupedMethods), color = GroupedMethods)) +
  geom_hline(yintercept = as.numeric(fct_rev(factor(unique(bibtex_methods$GroupedMethods)))), 
             color = "gray80", linetype = "dashed") +  # Horizontal lines
# geom_text_repel with ggrepel
  geom_text_repel(aes(label = ShortName), max.overlaps = 8, segment.color = 'transparent') + 
  scale_x_continuous(
    breaks = seq(min(bibtex_data$Year), max(bibtex_data$Year), 1),
    expand = expansion(mult = c(0.1, 0.1))  # Expand x-axis to make space for labels
  ) +  
  labs(title = "Timeline of Methods Used in Publications",
       x = "Year", y = NULL) +  # Remove y-axis label
  theme_minimal(base_size = 12) +  # Set larger base text size
  theme(
    axis.text.y = element_blank(),  # Remove default y-axis text
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",  # Remove legend completely
    panel.background = element_rect(fill = "white", color = NA),  # White background
    plot.background = element_rect(fill = "white", color = NA),  # White outer background
    plot.margin = margin(10, 10, 10, 180, "pt")  # Keep high left margin
  ) +
  coord_cartesian(clip = "off")  # Prevent text from being cut off
method_groups <- method_groups + 
 scale_color_manual(values = method_colors)  # Ensure consistent colors across plot elements

# Add custom-colored y-axis labels using annotate()
for (i in seq_along(method_list)) {
  method_groups <- method_groups + annotate("text", 
                                            x = min(bibtex_data$Year) - 0.8,  # Move text further left
                                            y = method_list[i], 
                                            label = method_labels[method_list[i]],  # Use modified labels
                                            color = method_colors[method_list[i]], 
                                            size = 5, hjust = 1)
}

# Print final plot
# print(method_groups)

# Save the figure with proper dimensions
# ggsave("figures/plot_method_groups.png", method_groups, width = 18, height = 4, dpi = 300, bg = "white")
