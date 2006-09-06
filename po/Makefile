.PHONY: all update clean install uninstall

# To change the locales that are generated, you have to pass
# something like LOCALES="fr de" on the command line

# locales that are supported
SUPPORTED_PO_FILES	=	$(wildcard *.po)
SUPPORTED_LOCALES	=	$(patsubst %.po,%,$(SUPPORTED_PO_FILES))

# by default, build all supported locales
LOCALES	=	$(SUPPORTED_LOCALES)

# locales that actually have to be built/installed
# (needed to drop the unsupported/duplicated ones that the user requests)
BUILT_LOCALES	=	$(sort $(filter $(SUPPORTED_LOCALES),$(LOCALES)))
BUILT_MO_FILES	=	$(patsubst %,%.mo,$(BUILT_LOCALES))

all: update

update:: $(BUILT_MO_FILES)

$(BUILT_MO_FILES): %.mo: %.po
	msgfmt $< -o $@

clean::
	$(RM) $(BUILT_MO_FILES)

install::
	for lang in $(BUILT_LOCALES) ; do \
		install -d -m 0755 $(LOCALEDIR)/$${lang}/LC_MESSAGES/ ; \
		install -m 0644 $${lang}.mo $(LOCALEDIR)/$${lang}/LC_MESSAGES/llgal.mo ; \
	done

uninstall::
	for lang in $(BUILT_LOCALES) ; do \
		rm $(LOCALEDIR)/$${lang}/LC_MESSAGES/llgal.mo ; \
		rmdir $(LOCALEDIR)/$${lang}/LC_MESSAGES/ ; \
		rmdir $(LOCALEDIR)/$${lang}/ ; \
	done
	rmdir $(LOCALEDIR)/
