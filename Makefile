PREFIX  ?= /usr/local
BINDIR   = $(PREFIX)/bin
LIBDIR   = $(PREFIX)/lib/yt-fetch

.PHONY: install uninstall

install:
	install -Dm755 yt-fetch        $(DESTDIR)$(BINDIR)/yt-fetch
	install -Dm755 install.sh      $(DESTDIR)$(LIBDIR)/install.sh
	install -Dm644 lib/config.sh   $(DESTDIR)$(LIBDIR)/config.sh
	install -Dm644 lib/deps.sh     $(DESTDIR)$(LIBDIR)/deps.sh
	install -Dm644 lib/ui.sh       $(DESTDIR)$(LIBDIR)/ui.sh
	install -Dm644 lib/notify.sh   $(DESTDIR)$(LIBDIR)/notify.sh
	install -Dm644 lib/history.sh  $(DESTDIR)$(LIBDIR)/history.sh
	install -Dm644 lib/url.sh      $(DESTDIR)$(LIBDIR)/url.sh
	install -Dm644 lib/playlist.sh $(DESTDIR)$(LIBDIR)/playlist.sh
	install -Dm644 lib/quality.sh  $(DESTDIR)$(LIBDIR)/quality.sh
	install -Dm644 lib/download.sh  $(DESTDIR)$(LIBDIR)/download.sh
	install -Dm644 lib/settings.sh $(DESTDIR)$(LIBDIR)/settings.sh

uninstall:
	rm -f  $(DESTDIR)$(BINDIR)/yt-fetch
	rm -rf $(DESTDIR)$(LIBDIR)
