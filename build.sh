# This script build documents locally
pandoc_pdf () {
	Rscript /Library/Frameworks/R.framework/Versions/4.2-arm64/Resources/library/stom/cli/pandoc_pdf.R "$@"
}

# Build documents
pandoc_pdf main.md
quarto render analysis.qmd

# Move files
[[ -d docs ]] && rm -r docs
mkdir docs
mv *.pdf *.html *_files docs/
mv docs/analysis.html docs/index.html
touch docs/.nojekyll
