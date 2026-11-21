# Load required libraries
if (!requireNamespace("RefManageR", quietly = TRUE)) install.packages("RefManageR")
library(RefManageR)

# Helper function to clean text
clean_text <- function(text) {
  if (is.null(text)) return("No information available")
  gsub("[{}%()]", "", text)
}

# Helper function for summarizing abstracts
summarize_text_simple <- function(text, max_sentences = 3) {
  if (is.null(text) || nchar(text) == 0) return("No abstract available")
  
  # Split into sentences and take the first few
  sentences <- unlist(strsplit(text, "(?<=[.!?])\\s+", perl = TRUE))
  if (length(sentences) <= max_sentences) {
    return(paste(sentences, collapse = " "))
  }
  
  # Return only the first max_sentences
  summarized <- paste(sentences[1:max_sentences], collapse = " ")
  return(summarized)
}

# Function to summarize BibTeX abstracts into a single file with BibRef
summarize_abstracts_with_bibref <- function(bibtex_file, output_file) {
  # Read the BibTeX file
  bib_entries <- ReadBib(bibtex_file)
  
  # Initialize a character vector to store all the content
  all_content <- c()
  
  # Loop through each BibTeX entry
  for (bib_ref in names(bib_entries)) {
    # Extract and clean abstract
    abstract <- clean_text(bib_entries[[bib_ref]]$abstract)
    
    # Summarize abstract
    summarized_abstract <- summarize_text_simple(abstract, max_sentences = 3)
    
    # Construct the output format
    entry_content <- paste(
      "@", bib_ref, "\n",
      summarized_abstract, "\n\n",
      sep = ""
    )
    
    # Append to the overall content
    all_content <- c(all_content, entry_content)
  }
  
  # Write all content to the output file
  writeLines(all_content, con = output_file)
  
  cat("Summarized abstracts saved to:", output_file, "\n")
}

# Specify paths and run
bibtex_file <- "bib/cory_papers_habilitation.bib"  # BibTeX file path
output_file <- "summaries/summarized_abstracts_with_citations.txt"  # Output file to save summaries
summarize_abstracts_with_bibref(bibtex_file, output_file)
