KDRFC   = kramdown-rfc2629
XML2RFC = xml2rfc --v3
RFCDIFF = rfcdiff
MKDIR   = mkdir -p
CURL    = curl
RM      = rm -f

SRCFILE = draft.md

DISTDIR = dist
PREVDIR = previous_version

PREVPATH = $(DISTDIR)/$(PREVDIR)

DOCNAME = $(shell grep "^docname:" $(SRCFILE) | sed 's/docname:[[:space:]]\([a-z0-9-]\{1,\}\).*/\1/')
PREVNAME=

VERNUM  = $(lastword $(subst -, ,$(DOCNAME)))
ifeq ($(VERNUM), 00)
	PREVVER = $(PREVNAME)
else
	PREVVER = \
		$(shell d=$(DOCNAME); v=$(VERNUM); echo $${d%-*}-`printf "%02d" "$$(($${v##0}-1))"`)
endif

XMLFILE = $(DOCNAME).xml
TXTFILE = $(DOCNAME).txt
HTMLFILE= $(DOCNAME).html
PREVFILE= $(PREVVER).txt

.PHONY: all xml txt html diff diff-only tag bump git-isclean git-ismaster \
        clean cleanall

all: txt

$(DISTDIR):
	@$(MKDIR) $@

$(PREVPATH):
	@$(MKDIR) $@

$(DISTDIR)/$(XMLFILE): $(SRCFILE) $(DISTDIR)
	@$(KDRFC) $< > $@.tmp
	@mv $@.tmp $@

$(DISTDIR)/$(TXTFILE): $(DISTDIR)/$(XMLFILE)
	@$(XML2RFC) --text $<

$(DISTDIR)/$(HTMLFILE): $(DISTDIR)/$(XMLFILE)
	@$(XML2RFC) --html $<

$(PREVPATH)/$(PREVFILE): $(PREVPATH)
ifeq ($(PREVVER),)
	$(error Cannot find previous version)
endif
	$(CURL) https://www.ietf.org/archive/id/$(PREVVER).txt --output $@

xml: $(DISTDIR)/$(XMLFILE)

txt: $(DISTDIR)/$(TXTFILE)

html: $(DISTDIR)/$(HTMLFILE)

diff: $(PREVPATH)/$(PREVFILE) $(DISTDIR)/$(TXTFILE)
	cd $(DISTDIR); $(RFCDIFF) $(PREVDIR)/$(PREVFILE) $(TXTFILE)

diff-only: $(PREVPATH)/$(PREVFILE)
	cd $(DISTDIR); $(RFCDIFF) $(PREVDIR)/$(PREVFILE) $(TXTFILE)

tag: git-ismaster git-isclean
	@git tag -a $(DOCNAME) -m "Submitted WG-Document $(DOCNAME)"
	@echo "Don't forget to push with \"git push --tags\" and clean up with"
	@echo "\"git branch -d revision-ietf-$(VERNUM); git remote prune origin\""

bump: git-ismaster git-isclean
	$(eval NEXTVERNUM := $(shell v=$(VERNUM); printf "%02d" "$$(($${v##0}+1))"))
	@git co -b revision-ietf-$(NEXTVERNUM)
	@sed -i 's/^\(docname:[[:space:]][a-z0-9-]\{1,\}-\)[0-9]\{1,\}/\1$(NEXTVERNUM)/' $(SRCFILE)
	@git add $(SRCFILE)
	@git ci -m "Bumped to revision draft-ietf-...-$(NEXTVERNUM)"
	@echo "Push the new branch with \"git push -u origin revision-ietf-$(NEXTVERNUM)\""

git-isclean:
	@status=$$(git status --porcelain); \
	if [ ! -z "$${status}" ]; then \
		echo "Error - working directory is dirty."; \
		exit 1; \
	fi

git-ismaster:
	@branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "master" != "$${branch}" ]; then \
		echo "Error - not on master."; \
		exit 1; \
	fi

clean:
	@$(RM) $(DISTDIR)/*.txt $(DISTDIR)/*.html $(DISTDIR)/*.xml

cleanall: clean
	@$(RM) $(PREVPATH)/$(PREVFILE)
	@rmdir $(PREVPATH) $(DISTDIR)
