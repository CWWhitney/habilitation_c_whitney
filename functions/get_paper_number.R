# Call the function to make the data
source("functions/create_bibtex_data.R")

# function to get the paper number for in line citations to my papers
# big time saver
# bibref must be in "", i.e. "kamau_holistic_2021"
get_paper_number <- function(bibref) {
  bibtex_data$Number[which(bibtex_data$BibRef == bibref)]
}
