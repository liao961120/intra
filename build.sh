# This script build documents locally
pandoc_pdf () {
	Rscript /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/stom/cli/pandoc_pdf.R "$@"
}

# Build documents
pandoc_pdf main.md
quarto render analysis.qmd
