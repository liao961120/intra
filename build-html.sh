# pandoc main.md -f markdown -t html5 --citeproc -s -o docs/main.html --katex --default-image-extension ".svg"
Rscript -e 'stom::pandoc_html("main.md", "docs/main.html", c("--number-sections","--shift-heading-level-by=-1"))'
[[ -d docs/fig ]] || mkdir docs/fig
cp fig/*.svg docs/fig

# , "-M", "link-citation=true"
