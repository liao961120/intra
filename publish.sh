# Move files
[[ -d docs ]] && rm -r docs
mkdir docs
mv -r *.pdf *.html *_files docs/
mv docs/analysis.html docs/index.html
bash zip.sh
touch docs/.nojekyll

# Archive
src_dir=`pwd`
cd $(mktemp -d)
cp -r ${src_dir}/* .
rm -rf .git docs/intra.zip
zip -r ${src_dir}/docs/intra.zip .
cd -
