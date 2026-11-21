# Load required libraries
library(ggplot2)
library(dplyr)
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

# Ensure the dataset contains the required columns
data_citations <- data_altmetric %>%
  mutate(Year = as.numeric(str_extract(ShortName, "\\d{4}"))) %>%  # Extract year from ShortName
  select(BibRef, Year, Citations, ThematicArea = ThematicArea) %>%  
  drop_na()  # Remove rows where year or citations are missing

# Ensure data is sorted by year
data_citations <- data_citations %>% arrange(Year)

# Get the full range of years
year_range <- min(data_citations$Year):max(data_citations$Year)

# Expand dataset so every ThematicArea has an entry for every year
data_cumulative <- expand.grid(Year = year_range, ThematicArea = unique(data_citations$ThematicArea)) %>%
  left_join(data_citations, by = c("Year", "ThematicArea")) %>%
  arrange(ThematicArea, Year) %>%
  group_by(ThematicArea) %>%
  mutate(
    Citations = replace_na(Citations, 0),  # Replace missing citation counts with 0
    CumulativeCitations = cumsum(Citations)  # Compute cumulative sum
  )

# Compute total citations for the thesis papers
total_thesis_citations <- sum(data_citations$Citations, na.rm = TRUE)

# Compute h-index for the thesis papers
sorted_thesis_citations <- sort(data_citations$Citations, decreasing = TRUE)
h_index_thesis <- sum(sorted_thesis_citations >= seq_along(sorted_thesis_citations))

# Manually define the exact colors to match the thematic areas plot
thematic_colors <- c(
  "Livelihoods & Socio-Economic Impact" = "#1B9E77",  
  "Sustainability" = "#D95F02",  
  "Climate Change Mitigation/Adaptation" = "#7570B3",  
  "Biodiversity Conservation" = "#E7298A",  
  "Stakeholder & Community Engagement" = "#66A61E"
)

# Modify legend labels to include line breaks
thematic_labels <- c(
  "Livelihoods & Socio-Economic Impact" = "Livelihoods &\nSocio-Economic Impact",
  "Sustainability" = "Sustainability",
  "Climate Change Mitigation/Adaptation" = "Climate Change\nMitigation & Adaptation",
  "Biodiversity Conservation" = "Biodiversity\nConservation",
  "Stakeholder & Community Engagement" = "Stakeholder &\nCommunity Engagement"
)

# Ensure ThematicArea column matches exactly
data_cumulative$ThematicArea <- recode(data_cumulative$ThematicArea,
                                       "Biodiversity\nConservation" = "Biodiversity Conservation",
                                       "Climate Change Mitigation\nAdaptation" = "Climate Change Mitigation/Adaptation",
                                       "Livelihoods &\nSocio-Economic Impact" = "Livelihoods & Socio-Economic Impact",
                                       "Stakeholder &\nCommunity Engagement" = "Stakeholder & Community Engagement",
                                       "Sustainability" = "Sustainability"
)

# Generate the cumulative citation trends plot using **correct color mapping & line breaks in legend**
citation_plot <- ggplot(data_cumulative, aes(x = Year, y = CumulativeCitations, color = ThematicArea)) +
  geom_line(size = 2) +   # Slightly thicker lines for better visibility on A3
  geom_point(size = 4) +  # Bigger data points
  scale_x_continuous(breaks = seq(min(data_cumulative$Year), max(data_cumulative$Year), 1)) +  
  scale_color_manual(values = thematic_colors, labels = thematic_labels) +  
  labs(title = "Cumulative Citation Trends of Research Contributions",
       x = "Year",
       y = "Cumulative Citations",
       color = "Thematic Area") +
  
  # Increase text sizes using theme()
  theme_minimal(base_size = 30) +  # Base size increased significantly for A3
  theme(
    legend.position = "top",
    legend.title = element_text(size = 20),  # Bigger legend title
    legend.text = element_text(size = 16),  # Bigger legend text
    axis.title = element_text(size = 26),  # Bigger axis titles
    axis.text = element_text(size = 22),  # Bigger axis labels
    plot.title = element_text(size = 34, face = "bold"),  # Bigger title
    panel.grid.minor = element_blank()
  ) +
  
  # Increase size of total citations and h-index annotation
  annotate("text", x = max(data_cumulative$Year) - 1, y = 200, 
           label = paste("Citations:", total_thesis_citations, 
                         "\nh-index:", h_index_thesis, " *"), 
           color = "black", size = 10, hjust = 1, fontface = "bold") +
  
  # Increase size of clarification note
  annotate("text", x = mean(data_cumulative$Year), y = min(data_cumulative$CumulativeCitations) - 5, 
           label = "* Citations and h-index reflect only the publications included in this thesis", 
           color = "black", size = 7, hjust = 0.5, fontface = "italic")


# Save the figure with a wide layout for a fold-out
ggsave("figures/plot_thematic_citation_trends.png", width = 16.54, height = 11.69, dpi = 300, bg = "white")
