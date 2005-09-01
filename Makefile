NAME	=	llgal
VERSION	=	0.9.1

.PHONY: install uninstall tarball

DESTDIR	=	
PREFIX	=	/usr/local
EXEC_PREFIX	=	$(PREFIX)
BINDIR	=	$(EXEC_PREFIX)/bin
DATADIR	=	$(PREFIX)/share
SYSCONFDIR	=	$(PREFIX)/etc
MANDIR	=	$(PREFIX)/man

TARBALL	=	$(NAME)_$(VERSION).orig

install::
	install -d -m 0755 $(DESTDIR)$(BINDIR) $(DESTDIR)$(DATADIR)/llgal $(DESTDIR)$(MANDIR)/man1 $(DESTDIR)$(SYSCONFDIR)
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
	cp llgal /tmp/$(TARBALL)
	cp indextemplate.html llgal.css slidetemplate.html tile.png /tmp/$(TARBALL)
	cp llgalrc /tmp/$(TARBALL)
	cp llgal.1 /tmp/$(TARBALL)
	cp Makefile /tmp/$(TARBALL)
	cd /tmp && tar cfz $(TARBALL).tar.gz $(TARBALL)
	rm -rf /tmp/$(TARBALL)
	mv /tmp/$(TARBALL).tar.gz ..
