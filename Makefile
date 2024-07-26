KDRFC   = kramdown-rfc2629
XML2RFC = xml2rfc --v3
IDDIFF  = iddiff
IDNITS  = idnits
MKDIR   = mkdir -p
CURL    = curl
RM      = rm -f

SRCFILE = draft.md

DISTDIR = dist
PREVDIR = $(DISTDIR)/previous_version

DOCNAME = $(shell grep "^docname:" $(SRCFILE) | sed 's/docname:[[:space:]]\([a-z0-9-]\{1,\}\).*/\1/')
REPLACES=

VERNUM  = $(lastword $(subst -, ,$(DOCNAME)))
ifeq ($(VERNUM), 00)
	PREVNAME = $(REPLACES)
	DIFFNAME = $(DOCNAME)-from-$(REPLACES)
else
	PREVNUM = $(shell v=$(VERNUM); echo `printf "%02d" "$$(($${v##0}-1))"`)
	PREVNAME= $(shell d=$(DOCNAME); echo $${d%-*})-$(PREVNUM)
	DIFFNAME= $(DOCNAME)-from-$(PREVNUM)
endif

XMLFILE = $(DISTDIR)/$(DOCNAME).xml
TXTFILE = $(DISTDIR)/$(DOCNAME).txt
HTMLFILE= $(DISTDIR)/$(DOCNAME).html
PREVFILE= $(PREVDIR)/$(PREVNAME).txt
DIFFFILE= $(DISTDIR)/$(DIFFNAME).html

.PHONY: all xml txt html diff idnits tag bump git-isclean git-ismaster clean cleanall

all: txt

$(DISTDIR):
	@$(MKDIR) $@

$(PREVDIR):
	@$(MKDIR) $@

$(XMLFILE): $(SRCFILE) $(DISTDIR)
	@$(KDRFC) $< > $@

$(TXTFILE): $(XMLFILE)
	@$(XML2RFC) --text $<

$(HTMLFILE): $(XMLFILE)
	@$(XML2RFC) --html $<

$(PREVFILE): $(PREVDIR)
ifeq ($(PREVNAME),)
	$(error Cannot find previous version)
endif
	@$(CURL) https://www.ietf.org/archive/id/$(PREVNAME).txt --output $@

$(DIFFFILE): $(PREVFILE) $(TXTFILE)
	@$(IDDIFF) $^ > $@
	@echo " Created diff file $@"

xml: $(XMLFILE)

txt: $(TXTFILE)

html: $(HTMLFILE)

diff: $(DIFFFILE)

idnits: $(XMLFILE)
	@$(IDNITS) $<

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
	@$(RM) $(PREVFILE)
	@rmdir $(PREVDIR) $(DISTDIR)
