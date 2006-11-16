NAME	=	llgal
ifeq ($(shell [ -d .svn ] && echo 1),1)
	VERSION	=	$(shell cat VERSION)+svn.$(shell date +%Y%m%d)
else
	VERSION	=	$(shell cat VERSION)
endif

DATA_SUBDIR	=	data
LIB_SUBDIR	=	lib
PO_SUBDIR	=	po
DOC_SUBDIR	=	doc

DESTDIR	=	
PREFIX	=	/usr/local
EXEC_PREFIX	=	$(PREFIX)
BINDIR	=	$(EXEC_PREFIX)/bin
DATADIR	=	$(PREFIX)/share
SYSCONFDIR	=	$(PREFIX)/etc
MANDIR	=	$(PREFIX)/man
LOCALEDIR	=	$(DATADIR)/locale
DOCDIR	=	$(DATADIR)/doc
PERL_INSTALLDIRS	=	

TARBALL	=	$(NAME)-$(VERSION)
DEBIAN_TARBALL	=	$(NAME)_$(VERSION).orig

.PHONY: llgal clean install uninstall tarball

all:: llgal

llgal:: llgal.in VERSION build-lib update-po
	sed -e 's!@DATADIR@!$(DESTDIR)$(DATADIR)!g' -e 's!@SYSCONFDIR@!$(DESTDIR)$(SYSCONFDIR)!g' \
		-e 's!@LOCALEDIR@!$(DESTDIR)$(LOCALEDIR)!' -e 's!@VERSION@!$(VERSION)!g' \
		< llgal.in > llgal
	chmod 755 llgal

clean:: clean-lib clean-po
	rm -f llgal

install:: install-lib install-po
	install -d -m 0755 $(DESTDIR)$(BINDIR)/ $(DESTDIR)$(DATADIR)/llgal/ $(DESTDIR)$(MANDIR)/man1/ $(DESTDIR)$(SYSCONFDIR)/llgal/
	install -m 0755 llgal $(DESTDIR)$(BINDIR)/llgal
	install -m 0644 $(DATA_SUBDIR)/* $(DESTDIR)$(DATADIR)/llgal/
	install -m 0644 llgalrc $(DESTDIR)$(SYSCONFDIR)/llgal/

uninstall:: uninstall-lib uninstall-po
	rm $(DESTDIR)$(BINDIR)/llgal
	rm -rf $(DESTDIR)$(DATADIR)/llgal/
	rm -rf $(DESTDIR)$(SYSCONFDIR)/llgal/

tarball::
	mkdir /tmp/$(TARBALL)/
	cp llgal.in /tmp/$(TARBALL)
	cp llgalrc /tmp/$(TARBALL)
	cp llgal.1 llgalrc.5 /tmp/$(TARBALL)
	cp Makefile /tmp/$(TARBALL)
	cp Changes /tmp/$(TARBALL)
	cp COPYING README VERSION /tmp/$(TARBALL)
	cp -a $(DOC_SUBDIR)/ /tmp/$(TARBALL)
	cp -a $(DATA_SUBDIR)/ /tmp/$(TARBALL)
	cp -a $(LIB_SUBDIR) /tmp/$(TARBALL)
	mkdir /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cp $(PO_SUBDIR)/Makefile /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cp $(PO_SUBDIR)/*.po /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cd /tmp && tar cfz $(DEBIAN_TARBALL).tar.gz $(TARBALL)
	cd /tmp && tar cfj $(TARBALL).tar.bz2 $(TARBALL)
	mv /tmp/$(DEBIAN_TARBALL).tar.gz /tmp/$(TARBALL).tar.bz2 ..
	rm -rf /tmp/$(TARBALL)

# Perl modules
.PHONY: build-lib clean-lib install-lib uninstall-lib prepare-lib

$(LIB_SUBDIR)/Makefile.PL: $(LIB_SUBDIR)/Makefile.PL.in VERSION
	sed -e 's!@VERSION@!$(VERSION)!g' < $(LIB_SUBDIR)/Makefile.PL.in > $(LIB_SUBDIR)/Makefile.PL

$(LIB_SUBDIR)/Makefile: $(LIB_SUBDIR)/Makefile.PL
	cd $(LIB_SUBDIR) && perl Makefile.PL INSTALLDIRS=$(PERL_INSTALLDIRS)	

prepare-lib: $(LIB_SUBDIR)/Makefile

build-lib: prepare-lib
	$(MAKE) -C $(LIB_SUBDIR)

install-lib: prepare-lib
	$(MAKE) -C $(LIB_SUBDIR) install

clean-lib: prepare-lib
	$(MAKE) -C $(LIB_SUBDIR) distclean
	rm $(LIB_SUBDIR)/Makefile.PL

uninstall-lib: prepare-lib
	$(MAKE) -C $(LIB_SUBDIR) uninstall

# PO files
.PHONY: update-po clean-po install-po uninstall-po

update-po:
	$(MAKE) -C $(PO_SUBDIR) update

clean-po:
	$(MAKE) -C $(PO_SUBDIR) clean

install-po:
	$(MAKE) -C $(PO_SUBDIR) install LOCALEDIR=$(DESTDIR)$(LOCALEDIR)

uninstall-po:
	$(MAKE) -C $(PO_SUBDIR) uninstall LOCALEDIR=$(DESTDIR)$(LOCALEDIR)

# Install the doc, only called on-demand by distrib-specific Makefile
.PHONY: install-doc uninstall-doc

install-doc:
	$(MAKE) -C $(DOC_SUBDIR) install DOCDIR=$(DESTDIR)$(DOCDIR)

uninstall-doc:
	$(MAKE) -C $(DOC_SUBDIR) uninstall DOCDIR=$(DESTDIR)$(DOCDIR)

# Install the manpages, only called on-demand by distrib-specific Makefile
.PHONY: install-man uninstall-man

install-man::
	install -m 0644 llgal.1 $(DESTDIR)$(MANDIR)/man1/
	install -m 0644 llgalrc.5 $(DESTDIR)$(MANDIR)/man5/

uninstall-man::
	rm $(DESTDIR)$(MANDIR)/man1/llgal.1
	rm $(DESTDIR)$(MANDIR)/man5/llgalrc.5

