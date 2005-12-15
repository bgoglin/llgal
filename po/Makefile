.PHONY: all update clean install uninstall

PO_FILES	=	$(wildcard *.po)
MO_FILES	=	$(subst .po,.mo,$(PO_FILES))
LANGUAGES	=	$(subst .po,,$(PO_FILES))

$(MO_FILES): %.mo: %.po
	msgfmt $< -o $@

all: update

update:: $(MO_FILES)

clean::
	$(RM) $(MO_FILES)

install::
	for lang in $(LANGUAGES) ; do \
		install -d -m 0755 $(LOCALEDIR)/$${lang}/LC_MESSAGES/ ; \
		install -m 0644 $${lang}.mo $(LOCALEDIR)/$${lang}/LC_MESSAGES/llgal.mo ; \
	done

uninstall::
	for lang in $(LANGUAGES) ; do \
		rm $(LOCALEDIR)/$${lang}/LC_MESSAGES/llgal.mo ; \
		rmdir $(LOCALEDIR)/$${lang}/LC_MESSAGES/ ; \
		rmdir $(LOCALEDIR)/$${lang}/ ; \
	done
	rmdir $(LOCALEDIR)/
