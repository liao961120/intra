# Archive
src_dir=`pwd`
cd $(mktemp -d)
cp -r ${src_dir}/* .
rm -rf .git docs/intra.zip
zip -r ${src_dir}/docs/intra.zip .
cd -
