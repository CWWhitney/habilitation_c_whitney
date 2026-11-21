
# Function to extract abstracts and save them with BibRef
extract_abstracts_to_text <- function(bibtex_file, output_file) {
  # Load required package
  if (!requireNamespace("RefManageR", quietly = TRUE)) {
    install.packages("RefManageR")
  }
  library(RefManageR)
  
  # Helper function to clean text
  clean_text <- function(text) {
    if (is.null(text)) return(NA)
    gsub("[{}%()]", "", text)
  }
  
  # Read the BibTeX file
  bib_entries <- ReadBib(bibtex_file)
  
  # Open a connection to the output file
  file_conn <- file(output_file, "w")
  
  # Loop through each entry in the BibTeX file
  for (bib_ref in names(bib_entries)) {
    title <- clean_text(bib_entries[[bib_ref]]$title)
    abstract <- clean_text(bib_entries[[bib_ref]]$abstract)
    
    # Write the BibRef, Title, and Abstract to the file
    cat("@", bib_ref, "\n", file = file_conn, append = TRUE)
    cat("Title: ", ifelse(!is.null(title), title, "No title available"), "\n", file = file_conn, append = TRUE)
    cat("Abstract: ", ifelse(!is.null(abstract), abstract, "No abstract available"), "\n", file = file_conn, append = TRUE)
    cat("\n", file = file_conn, append = TRUE)  # Add an empty line between entries
  }
  
  # Close the file connection
  close(file_conn)
}


# Specify the BibTeX file path directly as a string
bibtex_file_path <- "bib/cory_papers_habilitation.bib"

# Specify the output text file path
output_text_file <- "summaries/abstracts_with_citations.txt"

# Call the function
extract_abstracts_to_text(bibtex_file_path, output_text_file)
