#mimics group_bibrefs_for_markdown.R
# Load dplyr for data manipulation
library(dplyr)

# source to create bibtex data
source("functions/create_bibtex_data.R")

# Function to group Paper Numbers by a specific column and return as a list
group_paper_numbers <- function(data, group_by_column, group_name) {
  # Filter data for the specific group name
  filtered_numbers <- data %>%
    filter(!!sym(group_by_column) == group_name) %>%
    pull(Number)
  
  return(filtered_numbers)
}

