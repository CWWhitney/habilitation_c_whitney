# Extract bib info ####

library(RefManageR)

# Function to clean text by removing special characters
clean_text <- function(text) {
  if (is.null(text)) return(NA)
  gsub("[{}%()]", "", text)
}

# Define the function to extract and clean BibTeX information
extract_bibtex_info <- function(bibtex_file) {
  # Read the BibTeX file
  bib_entries <- ReadBib(bibtex_file)
  
  # Extract and clean relevant information
  extracted_info <- data.frame(
    BibRef = names(bib_entries),
    Title = sapply(bib_entries, function(x) clean_text(x$title)),
    Authors = sapply(bib_entries, function(x) if (!is.null(x$author)) clean_text(paste(x$author, collapse = ", ")) else NA),
    Journal = sapply(bib_entries, function(x) clean_text(x$journal)),
    Year = sapply(bib_entries, function(x) clean_text(x$year)),
    Volume = sapply(bib_entries, function(x) clean_text(x$volume)),
    Issue = sapply(bib_entries, function(x) clean_text(x$number)),
    Pages = sapply(bib_entries, function(x) clean_text(x$pages)),
    Abstract = sapply(bib_entries, function(x) clean_text(x$abstract)),
    stringsAsFactors = FALSE
  )
  
  # Return the extracted information
  return(extracted_info)
}

# Specify the BibTeX file path ####
bibtex_file_path <- "bib/cory_papers_habilitation.bib"

# Call the function and save the output
bibtex_data <- extract_bibtex_info(bibtex_file_path)

# Save the data to a CSV file ####
write.csv(bibtex_data, "Appendix_3_All_Prints/AA_extracted_bibtex_info.csv", row.names = FALSE)
