NAME	=	llgal
VERSION	=	0.9.2

.PHONY: install uninstall tarball

DESTDIR	=	
PREFIX	=	/usr/local
EXEC_PREFIX	=	$(PREFIX)
BINDIR	=	$(EXEC_PREFIX)/bin
DATADIR	=	$(PREFIX)/share
SYSCONFDIR	=	$(PREFIX)/etc
MANDIR	=	$(PREFIX)/man

TARBALL	=	$(NAME)-$(VERSION)
DEBIAN_TARBALL	=	$(NAME)_$(VERSION).orig

install::
	install -d -m 0755 $(DESTDIR)$(BINDIR) $(DESTDIR)$(DATADIR)/llgal $(DESTDIR)$(MANDIR)/man1 $(DESTDIR)$(SYSCONFDIR)
	sed -e 's!@DATADIR@!$(DATADIR)!g' -e 's!@SYSCONFDIR@!$(SYSCONFDIR)!g' < llgal.in > llgal
	install -m 0755 llgal $(DESTDIR)$(BINDIR)/llgal
	install -m 0644 indextemplate.html llgal.css slidetemplate.html tile.png $(DESTDIR)$(DATADIR)/llgal
	install -m 0644 llgalrc $(DESTDIR)$(SYSCONFDIR)
	install -m 0644 llgal.1 $(DESTDIR)$(MANDIR)/man1

uninstall::
	rm $(DESTDIR)$(BINDIR)/llgal
	rm -rf $(DESTDIR)$(DATADIR)/llgal
	rm $(DESTDIR)$(SYSCONFDIR)/llgalrc
	rm $(DESTDIR)$(MANDIR)/man1/llgal.1

tarball::
	mkdir /tmp/$(TARBALL)
	cp llgal.in /tmp/$(TARBALL)
	cp indextemplate.html llgal.css slidetemplate.html tile.png /tmp/$(TARBALL)
	cp llgalrc /tmp/$(TARBALL)
	cp llgal.1 /tmp/$(TARBALL)
	cp Makefile /tmp/$(TARBALL)
	cd /tmp && cp -a $(TARBALL) $(DEBIAN_TARBALL) && tar cfz $(DEBIAN_TARBALL).tar.gz $(DEBIAN_TARBALL) && rm -rf $(DEBIAN_TARBALL)
	cd /tmp && tar cfj $(TARBALL).tar.bz2 $(TARBALL) && rm -rf /tmp/$(TARBALL)
	mv /tmp/$(DEBIAN_TARBALL).tar.gz /tmp/$(TARBALL).tar.bz2 ..
