# extracts multiple online engagement metrics from the Altmetric
# API to assess the visibility and impact of research papers. Each paper is
# identified by a unique reference key (BibRef) from the BibTeX file
# (cory_papers_habilitation.bib).

library(httr)
library(jsonlite)
library(tibble)
library(RefManageR)
library(rvest)
library(scholar)
library(stringdist)

# Load DOIs, Titles, and BibRefs ####
bib_file <- "bib/cory_papers_habilitation.bib"

# Function to extract DOIs and BibRefs from a BibTeX file ####
extract_dois_and_bibrefs <- function(bib_file) {
  bib_entries <- ReadBib(bib_file, check = FALSE)
  dois <- sapply(bib_entries, function(entry) if (!is.null(entry$doi)) entry$doi else NA)
  bibrefs <- sapply(bib_entries, function(entry) if (!is.null(entry$key)) entry$key else NA)
  titles <- sapply(bib_entries, function(entry) if (!is.null(entry$title)) entry$title else NA)
  
  tibble(DOI = na.omit(dois), BibRef = na.omit(bibrefs[seq_along(dois)]), Title = na.omit(titles[seq_along(dois)]))
}


doi_bibref_data <- extract_dois_and_bibrefs(bib_file)

dois <- doi_bibref_data$DOI
titles <- doi_bibref_data$Title

# Function to get Altmetric data by DOI and extract all relevant metrics ####
get_altmetric_data <- function(doi) {
  altmetric_url <- paste0("https://api.altmetric.com/v1/doi/", doi)
  response <- httr::GET(altmetric_url)
  
  if (httr::status_code(response) == 200) {
    altmetric_data <- jsonlite::fromJSON(httr::content(response, "text", encoding = "UTF-8"))
    
    # Extract all relevant fields safely
    list(
      DOI = doi,
      Mentions = ifelse("cited_by_posts_count" %in% names(altmetric_data), altmetric_data$cited_by_posts_count, 0),
      Readers_Count = ifelse("readers_count" %in% names(altmetric_data), altmetric_data$readers_count, 0),
      Altmetric_Score = ifelse("score" %in% names(altmetric_data), altmetric_data$score, 0),
      Tweets = ifelse("cited_by_tweeters_count" %in% names(altmetric_data), altmetric_data$cited_by_tweeters_count, 0),
      Blogs = ifelse("cited_by_blogs_count" %in% names(altmetric_data), altmetric_data$cited_by_blogs_count, 0),
      Wikipedia = ifelse("cited_by_wikipedia_count" %in% names(altmetric_data), altmetric_data$cited_by_wikipedia_count, 0),
      Patents = ifelse("cited_by_patents_count" %in% names(altmetric_data), altmetric_data$cited_by_patents_count, 0),
      Context_Pct = ifelse("context" %in% names(altmetric_data) && "all" %in% names(altmetric_data$context), altmetric_data$context$all$pct, NA),
      Altmetric_URL = ifelse("details_url" %in% names(altmetric_data), altmetric_data$details_url, NA)
    )
  } else {
    return(NULL)
  }
}

# check each ####
# cf. https://api.altmetric.com/v1/doi/10.1016/j.scitotenv.2019.06.133
# https://api.altmetric.com/v1/doi/10.1016/j.jhydrol.2024.132560
# Check which DOIs return NULL from Altmetric
missing_altmetric <- sapply(dois, function(doi) {
  result <- get_altmetric_data(doi)
  if (is.null(result)) return(doi) else return(NA)
})

#### TEST ####
# Filter out DOIs that have data
# missing_altmetric <- na.omit(missing_altmetric)
# 
# # Print missing DOIs
# if (length(missing_altmetric) > 0) {
#   cat("DOIs with missing Altmetric data:\n")
#   print(missing_altmetric)
# } else {
#   cat("All DOIs have Altmetric data.\n")
# }
# Look at the top of the list 

# Fetch Altmetric data for each DOI, assigning zeros if missing
altmetric_results <- lapply(dois, function(doi) {
  result <- get_altmetric_data(doi)
  if (is.null(result)) {
    # Fill missing values with zeros
    result <- list(
      DOI = doi,
      Mentions = 0,
      Readers_Count = 0,
      Altmetric_Score = 0,
      Tweets = 0,
      Blogs = 0,
      Wikipedia = 0,
      Patents = 0,
      Context_Pct = 0,
      Altmetric_URL = NA
    )
  }
  return(result)
})

# Convert list to dataframe ####
altmetric_data <- do.call(rbind, lapply(altmetric_results, as.data.frame))

# Ensure row counts match ####
if (nrow(altmetric_data) != nrow(doi_bibref_data)) {
  stop("Mismatch between Altmetric data and DOI list! Check missing entries.")
}

# Use scholar package to load citations
# Define my author ID ####
author_id <- "YPIcAA4AAAAJ"

# Function to clean and match titles ####
clean_title <- function(title) {
  title %>%
    str_replace_all("[{}]", "") %>%  # Remove LaTeX braces
    str_replace_all("[[:punct:]]", " ") %>%  # Remove punctuation
    str_squish()  # Trim extra spaces
}

# Function to get citations for a given paper title ####
get_scholar_citations <- function(author_id, paper_title) {
  papers <- get_publications(author_id)
  
  # Clean titles before matching
  safe_title <- clean_title(paper_title)
  paper_titles_cleaned <- sapply(papers$title, clean_title)
  
  # Approximate matching with string distance
  match_idx <- which.min(stringdist::stringdist(safe_title, paper_titles_cleaned))
  
  if (length(match_idx) > 0 && match_idx <= length(papers$cites)) {
    return(papers$cites[match_idx])  # Return citation count
  } else {
    return(NA)
  }
}

# Fetch citation counts for each paper in the dataset ####
citation_counts <- sapply(titles, function(title) get_scholar_citations(author_id, title))

# Combine data ####
data_combined <- cbind(doi_bibref_data, altmetric_data[, -1])
data_combined$Citations <- citation_counts

# Drop columns where all values are zero ####
data_cleaned <- data_combined[, colSums(data_combined != 0, na.rm = TRUE) > 0]

# Drop DOI and Title ####
data_final <- data_cleaned[, !names(data_cleaned) %in% c("DOI", "Title")]

# Explain ####
# - Mentions metric captures the total number
# of times a paper has been referenced online, including in news articles,
# blogs, Wikipedia, policy documents, and social media, indicating its broader
# public engagement.
# - Citaitons are from Google Scholar
# - Readers_Count reflects how often a paper has been saved in reference
# management platforms (Mendeley and CiteULike)
# - Altmetric_Score, a weighted measure that
# aggregates attention from different sources. This score is distinct from
# citation counts, as it prioritizes news mentions and policy citations over
# tweets and social shares. Papers scoring above 20 are considered to have
# significant online attention, while those over 100 are highly influential in
# public discourse.
# - Tweets measure the frequency of a paper being shared on Twitter, signaling
# dissemination but not necessarily academic impact. High tweet counts often
# stem from researchers promoting their own work. The presence of a paper in
# Wikipedia entries suggests its role in public education and foundational
# knowledge, particularly in science, health, and environmental fields.
# - Context_Pct metric indicates how a paper’s Altmetric Score compares to
# similar publications. A Context_Pct of 75%, for example, means the paper has
# received more online engagement than 75% of comparable research. 
# - Altmetric_URL, links directly to the Altmetric report for
# a detailed breakdown of online visibility. 