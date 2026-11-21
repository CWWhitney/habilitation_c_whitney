# Build the bonndoc (ULB Bonn online publication) version of the habilitation.
# Run from the repository root:  Rscript bonndoc/build_bonndoc.R
# Output: bonndoc/habilitation_c_whitney_bonndoc.pdf
#
# Changes vs. index.Rmd (ULB Bonn, D. Roth, 17 Apr 2026):
# 1) no Cover.pdf (old university logo)
# 2) new title page + date-of-habilitation page (bonndoc/0_Title_bonndoc.Rmd)
# 3) Papers 19/20: the two Liman Harou PDFs carry each other's content,
#    so the bonndoc appendix points each heading at the right file
# 4) no Eigenstaendigkeitserklaerung
# 5) extra LaTeX passes so the List of Figures page numbers settle

# 3) appendix copy with the two Liman Harou PDFs swapped back
aa <- readLines("Appendix_3_All_Prints/AA_references.Rmd", encoding = "UTF-8")
mapping <- "Appendix_3_All_Prints/liman_harou_mapping_2020.pdf"
crop <- "Appendix_3_All_Prints/liman_harou_crop_2021.pdf"
stopifnot(sum(grepl(mapping, aa, fixed = TRUE)) == 1,
          sum(grepl(crop, aa, fixed = TRUE)) == 1)
aa <- gsub(mapping, "@@MAPPING@@", aa, fixed = TRUE)
aa <- gsub(crop, mapping, aa, fixed = TRUE)
aa <- gsub("@@MAPPING@@", crop, aa, fixed = TRUE)
writeLines(aa, "bonndoc/AA_references_bonndoc.Rmd", useBytes = TRUE)

# Render from the repository root so all relative paths match index.Rmd
build_rmd <- "_bonndoc_build.Rmd"
file.copy("bonndoc/index_bonndoc.Rmd", build_rmd, overwrite = TRUE)
on.exit(unlink(c(build_rmd, Sys.glob("_bonndoc_build*"))), add = TRUE)

rmarkdown::render(build_rmd, output_format = "pdf_document",
                  output_options = list(keep_tex = TRUE),
                  clean = TRUE, envir = new.env())

# 5) recompile the kept .tex with enough passes for TOC/LoF to be stable
tex <- "_bonndoc_build.tex"
unlink(c("_bonndoc_build.aux", "_bonndoc_build.toc", "_bonndoc_build.lof", "_bonndoc_build.out"))
tinytex::latexmk(tex, engine = "xelatex", min_times = 4, clean = TRUE)

file.rename("_bonndoc_build.pdf", "bonndoc/habilitation_c_whitney_bonndoc.pdf")
file.rename(tex, "bonndoc/habilitation_c_whitney_bonndoc.tex")
message("Done: bonndoc/habilitation_c_whitney_bonndoc.pdf")
