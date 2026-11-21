# Load dplyr for data manipulation
library(dplyr)

# source to create bibtex data
source("functions/create_bibtex_data.R")

# Function to group BibRefs by a specific column and return in citation format
group_bibrefs_for_markdown <- function(data, group_by_column, group_name) {
  # Filter data for the specific group name
  filtered_bibrefs <- data %>%
    filter(!!sym(group_by_column) == group_name) %>%
    pull(BibRef)
  
  # Format BibRefs for Markdown citation
  paste0("@", filtered_bibrefs, collapse = ", ")
}
