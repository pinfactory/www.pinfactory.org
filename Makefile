SOURCES = index.md privacy.md people.md

PAGES = $(SOURCES:%.md=%/index.html)

all : $(PAGES) index.html

%/index.html : %.md template.html Makefile
	dirname $@ | xargs -n 1 mkdir -p
	pandoc --section-divs -t html5 --template template.html -s -o $@ $< 

index.html : index/index.html
	cp $< $@

clean :
	rm -f $(PAGES) index.html

deploy : all
	(git branch -D gh-pages || true) &> /dev/null
	rm -rf build && mkdir -p build
	cp -a Makefile .git *.md template.html build
	make -C build gh-pages
	rm -rf build

gh-pages : all
	basename `pwd` | grep -q build || exit 1
	rm -f .git/hooks/pre-push
	git checkout -b gh-pages
	git add -f index.html $(PAGES)
	git rm *.md
	git commit -m "this is a temporary branch, do not commit here."
	git push -f origin gh-pages:gh-pages

.PHONY : all clean deploy

