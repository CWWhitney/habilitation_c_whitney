# Need tidyverse
library(tidyverse)

# Call the extract function 
source("functions/extract_bibtex_info.R")

bibtex_data <- extract_bibtex_info("bib/cory_papers_habilitation.bib")

# Custom order of importance
custom_order <- c(
  # First author
  "whitney_probabilistic_2018", 
  "whitney_decision_2023", 
  "whitney_balancing_2025", 
  # Last author
  "fernandez_prioritizing_2022", 
  "do_decision_2020", 
  "luu_how_2024", 
  "netter_agroforestry_2022",
  # Top papers
  "kuyah_agroforestry_2019",
  "do_adapting_2024",
  "lanzanova_improving_2019", 
  "yigzaw_stochastic_2019", 
  "oluoch_integrated_2022", 
  "luu_decision_2022", 
  "luu_stakeholder_2024", 
  "luedeling_limitations_2022",
  "rojas_adapting_2021", 
  "mcgonigle_knowledge_2020", 
  "oluoch_predicted_2024", 
  "liman_harou_mapping_2020", 
  "liman_harou_crop_2021", 
  # Supporting papers
  "burbano-figueroa_profitability_2022", 
  "burbano-figueroa_farm-planning_2022", 
  "tamba_stochastic_2021", 
  "ruett_assessing_2022",
  "ruett_model-based_2020", 
  "oluoch_indigenous_2023", 
  "sulaiman_socio-cultural_2021", 
  # Orbiting supporting
  "ruett_hyperspectral_2022",
  "fernandez_prospects_2020", 
  "nyamukuru_allometric_2023", 
  "tabuti_priority_2022", 
  "kamau_holistic_2021"
)

# Reorder the data frame
bibtex_data <- bibtex_data[match(custom_order, bibtex_data$BibRef), ]

# Add a numbered list column
bibtex_data$Number <- seq_len(nrow(bibtex_data))

# Name all countries where work was done (Europe for global ones for now)
country_list <- c(
  "whitney_probabilistic_2018" = "Uganda",
  "whitney_decision_2023" = "Europe",
  "whitney_balancing_2025" = "South Africa",
  "fernandez_prioritizing_2022" = "Chile",
  "do_decision_2020" = "Vietnam",
  "luu_how_2024" = "Vietnam",
  "netter_agroforestry_2022" = "Costa Rica",
  "kuyah_agroforestry_2019" = "Kenya",
  "do_adapting_2024" = "Vietnam",
  "lanzanova_improving_2019" = "Burkina Faso",
  "yigzaw_stochastic_2019" = "Ethiopia",
  "oluoch_integrated_2022" = "Kenya",
  "luu_decision_2022" = "Vietnam",
  "luu_stakeholder_2024" = "Vietnam",
  "luedeling_limitations_2022" = "Kenya",
  "rojas_adapting_2021" = "Chile",
  "mcgonigle_knowledge_2020" = "Europe",
  "oluoch_predicted_2024" = "Kenya",
  "liman_harou_mapping_2020" = "Ethiopia",
  "liman_harou_crop_2021" = "Kenya",
  "burbano-figueroa_profitability_2022" = "Colombia",
  "burbano-figueroa_farm-planning_2022" = "Colombia",
  "tamba_stochastic_2021" = "Kenya",
  "ruett_assessing_2022" = "Germany",
  "ruett_model-based_2020" = "Germany",
  "oluoch_indigenous_2023" = "Kenya",
  "sulaiman_socio-cultural_2021" = "Syria",
  "ruett_hyperspectral_2022" = "Germany",
  "fernandez_prospects_2020" = "Chile",
  "nyamukuru_allometric_2023" = "Uganda",
  "tabuti_priority_2022" = "Uganda",
  "kamau_holistic_2021" = "Kenya"
)

# Define the methods for each reference in a named vector
methods_list <- c(
  "whitney_probabilistic_2018" = "Decision Analysis",
  "whitney_decision_2023" = "Decision Analysis",
  "whitney_balancing_2025" = "Monte Carlo",
  "fernandez_prioritizing_2022" = "Monte Carlo",
  "do_decision_2020" = "Monte Carlo",
  "luu_how_2024" = "Impact pathways",
  "netter_agroforestry_2022" = "Monte Carlo",
  "kuyah_agroforestry_2019" = "Meta Analysis",
  "do_adapting_2024" = "Systems thinking",
  "lanzanova_improving_2019" = "Probabilistic decision analysis",
  "yigzaw_stochastic_2019" = "Stochastic Impact Evaluation",
  "oluoch_integrated_2022" = "Ethnoecology",
  "luu_decision_2022" = "Decision Analysis",
  "luu_stakeholder_2024" = "Stakeholder Engagement",
  "luedeling_limitations_2022" = "Simulation",
  "rojas_adapting_2021" = "Decision Analysis",
  "mcgonigle_knowledge_2020" = "Knowledge Brokering",
  "oluoch_predicted_2024" = "Mapping",
  "liman_harou_mapping_2020" = "Mapping",
  "liman_harou_crop_2021" = "CropModels",
  "burbano-figueroa_profitability_2022" = "Partial Budget Analysis",
  "burbano-figueroa_farm-planning_2022" = "Portfolio Theory",
  "tamba_stochastic_2021" = "Stochastic Impact Evaluation",
  "ruett_assessing_2022" = "Decision Analysis",
  "ruett_model-based_2020" = "Probabilistic Cost-Benefit Analysis",
  "oluoch_indigenous_2023" = "Ethnoecology",
  "sulaiman_socio-cultural_2021" = "Ethnoecology",
  "ruett_hyperspectral_2022" = "Hyperspectral",
  "fernandez_prospects_2020" = "Decision Analysis",
  "nyamukuru_allometric_2023" = "Allometric",
  "tabuti_priority_2022" = "Exploratory Quantitative Ethnobotany ",
  "kamau_holistic_2021" = "Multivariate Analysis"
)

# Create a named vector for Applications
applications_list <- c(
  "whitney_probabilistic_2018" = "Nutrition",
  "whitney_decision_2023" = "Nutrition",
  "whitney_balancing_2025" = "Hydrological",
  "fernandez_prioritizing_2022" = "Certification",
  "do_decision_2020" = "Agroforestry",
  "luu_how_2024" = "ClimateServices",
  "netter_agroforestry_2022" = "Certification",
  "kuyah_agroforestry_2019" = "Agroforestry",
  "do_adapting_2024" = "Agroforestry",
  "lanzanova_improving_2019" = "Hydrological",
  "yigzaw_stochastic_2019" = "Hydrological",
  "oluoch_integrated_2022" = "WildEdible",
  "luu_decision_2022" = "ClimateServices",
  "luu_stakeholder_2024" = "ClimateServices",
  "luedeling_limitations_2022" = "CarbonEmissions",
  "rojas_adapting_2021" = "Horticulture",
  "mcgonigle_knowledge_2020" = "MethodsDev",
  "oluoch_predicted_2024" = "WildEdible",
  "liman_harou_mapping_2020" = "Hydrological",
  "liman_harou_crop_2021" = "SmallholderFarming",
  "burbano-figueroa_profitability_2022" = "Horticulture",
  "burbano-figueroa_farm-planning_2022" = "Horticulture",
  "tamba_stochastic_2021" = "Horticulture",
  "ruett_assessing_2022" = "Horticulture",
  "ruett_model-based_2020" = "Horticulture",
  "oluoch_indigenous_2023" = "WildEdible",
  "sulaiman_socio-cultural_2021" = "TradKnowledge",
  "ruett_hyperspectral_2022" = "Horticulture",
  "fernandez_prospects_2020" = "Certification",
  "nyamukuru_allometric_2023" = "Allometric",
  "tabuti_priority_2022" = "Conservation",
  "kamau_holistic_2021" = "MixedEffects"
)

# Create a named vector for Geographical Focus
geographical_focus_list <- c(
  "whitney_probabilistic_2018" = "Sub-Saharan Africa",
  "whitney_decision_2023" = "Global",
  "whitney_balancing_2025" = "Sub-Saharan Africa",
  "fernandez_prioritizing_2022" = "South America",
  "do_decision_2020" = "Southeast Asia",
  "luu_how_2024" = "Southeast Asia",
  "netter_agroforestry_2022" = "South America",
  "kuyah_agroforestry_2019" = "Sub-Saharan Africa",
  "do_adapting_2024" = "Southeast Asia",
  "lanzanova_improving_2019" = "Sub-Saharan Africa",
  "yigzaw_stochastic_2019" = "Sub-Saharan Africa",
  "oluoch_integrated_2022" = "Sub-Saharan Africa",
  "luu_decision_2022" = "Southeast Asia",
  "luu_stakeholder_2024" = "Southeast Asia",
  "luedeling_limitations_2022" = "Sub-Saharan Africa",
  "rojas_adapting_2021" = "South America",
  "mcgonigle_knowledge_2020" = "Global",
  "oluoch_predicted_2024" = "Sub-Saharan Africa",
  "liman_harou_mapping_2020" = "Sub-Saharan Africa",
  "liman_harou_crop_2021" = "Sub-Saharan Africa",
  "burbano-figueroa_profitability_2022" = "South America",
  "burbano-figueroa_farm-planning_2022" = "South America",
  "tamba_stochastic_2021" = "Sub-Saharan Africa",
  "ruett_assessing_2022" = "Europe",
  "ruett_model-based_2020" = "Europe",
  "oluoch_indigenous_2023" = "Sub-Saharan Africa",
  "sulaiman_socio-cultural_2021" = "Global",
  "ruett_hyperspectral_2022" = "Europe",
  "fernandez_prospects_2020" = "South America",
  "nyamukuru_allometric_2023" = "Sub-Saharan Africa",
  "tabuti_priority_2022" = "Sub-Saharan Africa",
  "kamau_holistic_2021" = "Sub-Saharan Africa"
)

# Create a named vector for Thematic Areas
thematic_areas_list <- c(
  "whitney_probabilistic_2018" = "Livelihoods and Socio-Economic Impact",
  "whitney_decision_2023" = "Sustainability",
  "whitney_balancing_2025" = "Climate Change Mitigation/Adaptation",
  "fernandez_prioritizing_2022" = "Sustainability",
  "do_decision_2020" = "Biodiversity Conservation",
  "luu_how_2024" = "Stakeholder and Community Engagement",
  "netter_agroforestry_2022" = "Climate Change Mitigation/Adaptation",
  "kuyah_agroforestry_2019" = "Biodiversity Conservation",
  "do_adapting_2024" = "Livelihoods and Socio-Economic Impact",
  "lanzanova_improving_2019" = "Sustainability",
  "yigzaw_stochastic_2019" = "Climate Change Mitigation/Adaptation",
  "oluoch_integrated_2022" = "Biodiversity Conservation",
  "luu_decision_2022" = "Stakeholder and Community Engagement",
  "luu_stakeholder_2024" = "Stakeholder and Community Engagement",
  "luedeling_limitations_2022" = "Climate Change Mitigation/Adaptation",
  "rojas_adapting_2021" = "Climate Change Mitigation/Adaptation",
  "mcgonigle_knowledge_2020" = "Stakeholder and Community Engagement",
  "oluoch_predicted_2024" = "Biodiversity Conservation",
  "liman_harou_mapping_2020" = "Sustainability",
  "liman_harou_crop_2021" = "Livelihoods and Socio-Economic Impact",
  "burbano-figueroa_profitability_2022" = "Livelihoods and Socio-Economic Impact",
  "burbano-figueroa_farm-planning_2022" = "Sustainability",
  "tamba_stochastic_2021" = "Climate Change Mitigation/Adaptation",
  "ruett_assessing_2022" = "Sustainability",
  "ruett_model-based_2020" = "Climate Change Mitigation/Adaptation",
  "oluoch_indigenous_2023" = "Biodiversity Conservation",
  "sulaiman_socio-cultural_2021" = "Stakeholder and Community Engagement",
  "ruett_hyperspectral_2022" = "Sustainability",
  "fernandez_prospects_2020" = "Climate Change Mitigation/Adaptation",
  "nyamukuru_allometric_2023" = "Biodiversity Conservation",
  "tabuti_priority_2022" = "Biodiversity Conservation",
  "kamau_holistic_2021" = "Sustainability"
)

# Assign columns using the named vectors
bibtex_data <- bibtex_data %>%
  mutate(
    Applications = applications_list[BibRef],
    Methods = methods_list[BibRef],
    GeographicalFocus = geographical_focus_list[BibRef],
    ThematicAreas = thematic_areas_list[BibRef],
    Country = country_list[BibRef]
  )


