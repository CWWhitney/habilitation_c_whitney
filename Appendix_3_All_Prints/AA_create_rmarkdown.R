# Call the function and save the output
source("functions/create_bibtex_data.R")

# Function to generate RMarkdown content
create_rmarkdown <- function(bib_data, output_file) {
  file_conn <- file(output_file, "w")
  
  for (i in seq_len(nrow(bib_data))) {
    bib_ref <- bib_data$BibRef[i]
    title <- bib_data$Title[i]
    authors <- bib_data$Authors[i]
    journal <- bib_data$Journal[i]
    year <- bib_data$Year[i]
    pdf_file <- paste0("Appendix_3_All_Prints/", bib_ref, ".pdf")
    
    cat("<!-- ", journal, " -->\n", file = file_conn, append = TRUE)
    cat("\\newpage\n", file = file_conn, append = TRUE)
    cat(paste0("## Paper ", i, " ", title, " {#", bib_ref, "}\n\n"), file = file_conn, append = TRUE)
    cat("\\begin{center}\n", file = file_conn, append = TRUE)
    cat("\\vspace*{2cm}\n", file = file_conn, append = TRUE)
    cat(paste0("{\\Large \\textbf{", authors, "}} \\\\[0.5cm]\n"), file = file_conn, append = TRUE)
    cat("\\vspace*{1cm}\n", file = file_conn, append = TRUE)
    cat(paste0("{\\Large ", journal, "} \\\\[2cm]\n"), file = file_conn, append = TRUE)
    cat("\\end{center}\n", file = file_conn, append = TRUE)
    cat(paste0("\\includepdf[pages=-, pagecommand={\\thispagestyle{fancy}}]{", pdf_file, "}\n\n"), file = file_conn, append = TRUE)
  }
  
  # Close the connection
  close(file_conn)
}


# Specify the output RMarkdown file path
output_rmd <- "Appendix_3_All_Prints/AA_references.Rmd"


# Create the RMarkdown file
create_rmarkdown(bibtex_data, output_rmd)
