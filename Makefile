SOURCES = index.md privacy.md
IMAGES=$(shell find i -type f)
PAGES = $(SOURCES:%.md=%/index.html)

all : $(PAGES) index.html

PUBLICFILES = $(PAGES) $(IMAGES) index.html

%/index.html : %.md template.html Makefile
	dirname $@ | xargs -n 1 mkdir -p
	pandoc --section-divs -t html5 --template template.html -s -o $@ $< 

index.html : index/index.html
	cp $< $@

clean :
	rm -f $(PAGES) index.html build

# We make this site with "make" locally and deploy generated pages to GitHub in
# a branch. First, delete the build directory and the gh-pages branch. Then
# copy the site files into the build directory and make the gh-pages target
deploy : all
	(git branch -D gh-pages || true) &> /dev/null
	rm -rf build && mkdir -p build
	cp -a Makefile .git *.md template.html i/ build
	make -C build gh-pages
	rm -rf build

# This target only runs inside the build directory and does a commit and push
# on the gh-pages branch. If you look at this project on GitHub you should see
# the original .md files on the main branch and the generated HTML files on the
# gh-pages branch.
gh-pages : all
	basename `pwd` | grep -q build || exit 1
	rm -f .git/hooks/pre-push
	git checkout -b gh-pages
	git rm -f $(SOURCES)
	git add -f $(PUBLICFILES)
	git commit -m "this is a temporary branch, do not commit here."
	git push -f origin gh-pages:gh-pages

.PHONY : all clean deploy

