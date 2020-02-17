SOURCES = index.md privacy.md

PAGES = $(SOURCES:%.md=%/index.html)

all : $(PAGES) index.html hooks

%/index.html : %.md template.html Makefile
	dirname $@ | xargs -n 1 mkdir -p
	pandoc --section-divs -t html5 --template template.html -s -o $@ $< 

index.html : index/index.html
	cp $< $@

deploy : all
	(git branch -D gh-pages || true) &> /dev/null
	rm -rf build && mkdir -p build
	cp -a Makefile .git *.md template.html build
	make -C build gh-pages
	rm -rf build

gh-pages :
	basename `pwd` | grep -q build || exit 1
	rm -f .git/hooks/pre-push
	git checkout -b gh-pages
	git add -f Makefile *.html *.md
	git commit -m "this is a temporary branch, do not commit here."
	git push -f --set-upstream origin gh-pages

clean :
	rm -rf build
	rm -f $(PAGES) index.html
	git branch -D gh-pages || true

hooks : .git/hooks/pre-push

.git/hooks/% : Makefile
	echo "#!/bin/sh" > $@
	echo "make `basename $@`" >> $@
	chmod 755 $@

pre-push : deploy

.PHONY : all clean hooks deploy pre-push

