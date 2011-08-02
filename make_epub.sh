#!/bin/sh
#####################################################################
#
#   make_epub.sh
#   
#   Create the ePub book structure from the original source files
#
#####################################################################

. settings.sh

# Copy chapter files from source to numbered subdirectories
for (( i=0; i<25; i++ ))
do
    echo Copying chapter $i
    mkdir -p "$BUILD"/OEBPS/civic_45D_MRC/$i
    cp "$SRC"/CivHtml/$i-*.htm "$BUILD"/OEBPS/civic_45D_MRC/$i
    cp "$SRC"/CivHtml/$i-*.gif "$BUILD"/OEBPS/civic_45D_MRC/$i
done

# Copy chapter resources
echo Copying Resources
mkdir -p "$BUILD"/OEBPS/civic_45D_MRC/res
cp "$SRC"/CivHtml/*.css "$BUILD"/OEBPS/civic_45D_MRC/res

