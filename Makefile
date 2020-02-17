SOURCES = index.md privacy.md

PAGES = $(SOURCES:%.md=%/index.html)

all : $(PAGES) index.html hooks

%/index.html : %.md template.html Makefile
	dirname $@ | xargs -n 1 mkdir -p
	pandoc --section-divs -t html5 --template template.html -s -o $@ $< 

index.html : index/index.html
	cp $< $@

clean :
	rm -f $(PAGES) index.html

hooks : .git/hooks/pre-push

.git/hooks/% : Makefile
	echo "#!/bin/sh" > $@
	echo "make `basename $@`" >> $@
	chmod 755 $@

pre-push : all

.PHONY : all clean hooks deploy pre-push

