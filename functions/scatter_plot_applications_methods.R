source("functions/create_bibtex_data.R")

library(ggplot2)
library(ggrepel)
library(dplyr)

# Ensure factor ordering
bibtex_data$Methods <- factor(bibtex_data$Methods)
bibtex_data$Applications <- factor(bibtex_data$Applications)

# Function to shorten BibRef names (extract first word & year)
shorten_bibref <- function(bibref) {
  parts <- unlist(str_split(bibref, "_"))  # Split by underscore
  paste0(str_to_title(parts[1]), " et al. ", parts[length(parts)])  # First word + "et al." + Year
}

# Apply function to shorten paper names
bibtex_data$ShortName <- sapply(bibtex_data$BibRef, shorten_bibref)

# Detect duplicate author-year pairs and assign 'a', 'b', etc.
bibtex_data <- bibtex_data %>%
  group_by(ShortName, Year) %>%
  mutate(dup_count = row_number(),
         total_dups = n()) %>%
  ungroup() %>%
  mutate(ShortName = ifelse(total_dups > 1, paste0(ShortName, letters[dup_count]), ShortName)) %>%
  select(-dup_count, -total_dups)  # Remove temporary columns

# Define clusters for Applications (Y-axis)
application_groups <- c(
  "Agroforestry" = "Agroecology &\nSustainability",
  "ClimateServices" = "Agroecology &\nSustainability",
  "Conservation" = "Agroecology &\nSustainability",
  "WildEdible" = "Agroecology &\nSustainability",
  "SmallholderFarming" = "Agroecology &\nSustainability",
  
  "Certification" = "Decision &\nPolicy Analysis",
  "MethodsDev" = "Decision &\nPolicy Analysis",
  "CarbonEmissions" = "Decision &\nPolicy Analysis",
  "Hydrological" = "Decision &\nPolicy Analysis",
  "Nutrition" = "Decision &\nPolicy Analysis",
  
  "Horticulture" = "Production &\nManagement",
  "TradKnowledge" = "Production &\nManagement",
  "Allometric" = "Production &\nManagement",
  "MixedEffects" = "Production &\nManagement"
)

# Define clusters for Methods (X-axis)
method_groups <- c(
  "Decision Analysis" = "Probabilistic &\nDecision Methods",
  "Monte Carlo" = "Probabilistic &\nDecision Methods",
  "Probabilistic Cost-Benefit Analysis" = "Probabilistic &\nDecision Methods",
  "Probabilistic decision analysis" = "Probabilistic &\nDecision Methods",
  
  "Ethnoecology" = "Ecological &\nEthnobotanical Methods",
  "WildEdible" = "Ecological &\nEthnobotanical Methods",
  "Exploratory Quantitative Ethnobotany " = "Ecological &\nEthnobotanical Methods",
  "Allometric" = "Ecological &\nEthnobotanical Methods",
  
  "CropModels" = "Spatial &\nPredictive Modeling",
  "Mapping" = "Spatial &\nPredictive Modeling",
  "Hyperspectral" = "Spatial &\nPredictive Modeling",
  "Meta Analysis" = "Spatial &\nPredictive Modeling",
  "Multivariate Analysis" = "Spatial &\nPredictive Modeling",
  "Simulation" = "Spatial &\nPredictive Modeling",
  
  "Impact pathways" = "Stakeholder &\nSystemic Approaches",
  "Knowledge Brokering" = "Stakeholder &\nSystemic Approaches",
  "Portfolio Theory" = "Stakeholder &\nSystemic Approaches",
  "Stakeholder Engagement" = "Stakeholder &\nSystemic Approaches",
  "Stochastic Impact Evaluation" = "Stakeholder &\nSystemic Approaches",
  "Systems thinking" = "Stakeholder &\nSystemic Approaches",
  "Partial Budget Analysis" = "Stakeholder &\nSystemic Approaches"
)

# Apply clustering
bibtex_data <- bibtex_data %>%
  mutate(ApplicationGroup = recode(Applications, !!!application_groups),
         MethodGroup = recode(Methods, !!!method_groups))

# Define a dark color palette for Methods
dark_method_colors <- c(
  "Decision Analysis" = "#003f5c",
  "Monte Carlo" = "#2f4b7c",
  "Probabilistic Cost-Benefit Analysis" = "#665191",
  "Probabilistic decision analysis" = "#a05195",
  "Ethnoecology" = "#d45087",
  "WildEdible" = "#f95d6a",
  "Exploratory Quantitative Ethnobotany" = "#ff7c43",
  "Allometric" = "#ffa600",
  "CropModels" = "#d62728",
  "Mapping" = "#9467bd",
  "Hyperspectral" = "#8c564b",
  "Meta Analysis" = "#e377c2",
  "Multivariate Analysis" = "#7f7f7f",
  "Simulation" = "#bcbd22",
  "Impact pathways" = "#17becf",
  "Knowledge Brokering" = "#1f77b4",
  "Portfolio Theory" = "#ff7f0e",
  "Stakeholder Engagement" = "#2ca02c",
  "Stochastic Impact Evaluation" = "#d62728",
  "Systems thinking" = "#9467bd",
  "Partial Budget Analysis" = "#8c564b"
)

# Plot
scatter_plot_applications_methods <- ggplot(bibtex_data, aes(x = MethodGroup, 
                        y = ApplicationGroup, 
                        color = Methods)) +
  geom_text_repel(aes(label = ShortName), 
                  max.overlaps = 20, segment.color = 'transparent') +
  scale_color_manual(values = dark_method_colors) +  # Apply darker colors
  scale_x_discrete(position = "top") + 
  xlab("Research Methods") +
  ylab("Applications") +
  
  # Expand axes for better spacing
  theme_bw() +
  theme(
    plot.margin = unit(c(1, 1, 1, 1), "cm"),
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    legend.position = "bottom",
    legend.title = element_blank()  # Remove legend title
  ) 

ggsave("figures/scatter_plot_applications_methods.png", 
       scatter_plot_applications_methods, 
       width = 10, height = 6, dpi = 300, bg = "white")

