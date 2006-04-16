NAME	=	llgal
ifeq ($(shell [ -d .svn ] && echo 1),1)
	VERSION	=	$(shell cat VERSION)+svn
else
	VERSION	=	$(shell cat VERSION)
endif

.PHONY: llgal clean install uninstall tarball

DATA_SUBDIR	=	data
PO_SUBDIR	=	po

DESTDIR	=	
PREFIX	=	/usr/local
EXEC_PREFIX	=	$(PREFIX)
BINDIR	=	$(EXEC_PREFIX)/bin
DATADIR	=	$(PREFIX)/share
SYSCONFDIR	=	$(PREFIX)/etc
MANDIR	=	$(PREFIX)/man
LOCALEDIR	=	$(DATADIR)/locale

TARBALL	=	$(NAME)-$(VERSION)
DEBIAN_TARBALL	=	$(NAME)_$(VERSION).orig

all:: llgal

llgal:: update-po
	sed -e 's!@DATADIR@!$(DESTDIR)$(DATADIR)!g' -e 's!@SYSCONFDIR@!$(DESTDIR)$(SYSCONFDIR)!g' \
		-e 's!@LOCALEDIR@!$(DESTDIR)$(LOCALEDIR)!' -e 's!@VERSION@!$(VERSION)!g' \
		< llgal.in > llgal
	chmod 755 llgal

clean:: clean-po
	rm -f llgal

install:: install-po
	install -d -m 0755 $(DESTDIR)$(BINDIR)/ $(DESTDIR)$(DATADIR)/llgal/ $(DESTDIR)$(MANDIR)/man1/ $(DESTDIR)$(SYSCONFDIR)/llgal/
	install -m 0755 llgal $(DESTDIR)$(BINDIR)/llgal
	install -m 0644 $(DATA_SUBDIR)/* $(DESTDIR)$(DATADIR)/llgal/
	install -m 0644 llgalrc $(DESTDIR)$(SYSCONFDIR)/llgal/
	install -m 0644 llgal.1 $(DESTDIR)$(MANDIR)/man1/

uninstall:: uninstall-po
	rm $(DESTDIR)$(BINDIR)/llgal
	rm -rf $(DESTDIR)$(DATADIR)/llgal/
	rm -rf $(DESTDIR)$(SYSCONFDIR)/llgal/
	rm $(DESTDIR)$(MANDIR)/man1/llgal.1

tarball::
	mkdir /tmp/$(TARBALL)/
	cp llgal.in /tmp/$(TARBALL)
	cp llgalrc /tmp/$(TARBALL)
	cp llgal.1 /tmp/$(TARBALL)
	cp Makefile /tmp/$(TARBALL)
	cp Changes /tmp/$(TARBALL)
	cp COPYING README UPGRADE VERSION /tmp/$(TARBALL)
	cp -a $(DATA_SUBDIR)/ /tmp/$(TARBALL)
	mkdir /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cp $(PO_SUBDIR)/Makefile /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cp $(PO_SUBDIR)/*.po /tmp/$(TARBALL)/$(PO_SUBDIR)/
	cd /tmp && tar cfz $(DEBIAN_TARBALL).tar.gz $(TARBALL)
	cd /tmp && tar cfj $(TARBALL).tar.bz2 $(TARBALL)
	mv /tmp/$(DEBIAN_TARBALL).tar.gz /tmp/$(TARBALL).tar.bz2 ..
	rm -rf /tmp/$(TARBALL)

update-po:
	$(MAKE) -C $(PO_SUBDIR) update

clean-po:
	$(MAKE) -C $(PO_SUBDIR) clean

install-po:
	$(MAKE) -C $(PO_SUBDIR) install LOCALEDIR=$(DESTDIR)$(LOCALEDIR)

uninstall-po:
	$(MAKE) -C $(PO_SUBDIR) uninstall LOCALEDIR=$(DESTDIR)$(LOCALEDIR)
