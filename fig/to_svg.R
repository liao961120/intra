for ( fp in list.files(pattern="\\.pdf$") )
    stom::pdf2svg(fp)
