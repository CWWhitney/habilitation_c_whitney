# Call the function to create bibtex data
source("functions/create_bibtex_data.R")

# Create the RMD
create_rmd_with_fields <- function(bib_data, output_file) {
  # Open a connection to the RMarkdown file
  file_conn <- file(output_file, "w")
  
  # Write the YAML header
  cat("---\n", file = file_conn, append = TRUE)
  cat("title: \"References List\"\n", file = file_conn, append = TRUE)
  cat("output: pdf_document\n", file = file_conn, append = TRUE)
  cat("---\n\n", file = file_conn, append = TRUE)
  
  # Loop through each entry in the bib data
  for (i in 1:nrow(bib_data)) {
    # Extract details for the entry
    journal <- bib_data$Journal[i]
    title <- bib_data$Title[i]
    authors <- bib_data$Authors[i]
    year <- bib_data$Year[i]
    abstract <- bib_data$Abstract[i]
    
    # Write the RMarkdown content for each reference
    cat(paste0("## Paper ", i, ". ", title, "\n\n"), file = file_conn, append = TRUE)
    cat(paste0("**Authors**: ", authors, "\n\n"), file = file_conn, append = TRUE)
    cat(paste0("**Journal**: ", journal, "\n\n"), file = file_conn, append = TRUE)
    cat(paste0("**Year**: ", year, "\n\n"), file = file_conn, append = TRUE)
    cat(paste0("**Abstract**: ", abstract, "\n\n"), file = file_conn, append = TRUE)
    cat("\\newpage\n\n", file = file_conn, append = TRUE) # Page break between entries
  }
  
  # Close the connection
  close(file_conn)
}

# Specify the output RMarkdown file path
output_rmd <- "summaries/summarized_title_author_etc.Rmd"

# Use the function to create the RMarkdown file
create_rmd_with_fields(bibtex_data, output_rmd)

