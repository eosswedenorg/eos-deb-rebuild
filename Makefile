
NAME 		= eos-deb-rebuild
DESTDIR		= /
PREFIX 		= usr
INSTALLDIR 	= $(DESTDIR)/$(PREFIX)
SHAREDIR	= $(INSTALLDIR)/share/$(NAME)
DOCSDIR		= $(INSTALLDIR)/share/doc/$(NAME)

DOCFILES	= $(addprefix $(DOCSDIR)/,README.md LICENSE)
INCLUDEFILES 	= $(addprefix $(SHAREDIR)/,$(shell find include -type f))
BINFILES  	= $(SHAREDIR)/eos-deb-rebuild
SYMLINKS  	= $(INSTALLDIR)/bin/eos-deb-rebuild

install : $(BINFILES) $(DOCFILES) $(INCLUDEFILES) $(SYMLINKS)

uninstall :
	rm $(SYMLINKS)
	rm -r $(INSTALLDIR)

# Install - Plugins
$(SHAREDIR)/include/plugins/% : include/plugins/%
	install -m 755 -D $< $@

# Install - Includes
$(SHAREDIR)/% : %
	install -m 644 -D $< $@

# Install - Documents
$(DOCSDIR)/% : %
	install -m 644 -D $< $@

# Install - Binaries
$(SHAREDIR)/% : bin/%.sh
	install -m 755 -D $< $@

# Install - Symlinks
$(INSTALLDIR)/bin/% : $(SHAREDIR)/%
	mkdir -p $(dir $@) && ln -sf $(subst $(INSTALLDIR)/,../,$<) $@

.PHONY: install uninstall
