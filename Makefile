
NAME 		= eos-deb-rebuild
PREFIX 		= /usr
INSTALLDIR 	= $(PREFIX)/opt/$(NAME)
PROGRAMS 	= $(patsubst %.sh,%,$(shell find bin -type f))
FILES 		= $(addprefix $(INSTALLDIR)/,README.md LICENSE $(shell find include -type f))
BINFILES  	= $(addprefix $(INSTALLDIR)/,$(PROGRAMS))
SYMLINKS  	= $(addprefix $(PREFIX)/,$(PROGRAMS))

install : $(FILES) $(BINFILES) $(SYMLINKS)

uninstall :
	rm $(SYMLINKS)
	rm -r $(INSTALLDIR)

# Files
$(INSTALLDIR)/% : %
	mkdir -p $(dir $@) && cp $< $@

# Binaries
$(INSTALLDIR)/bin/% : bin/%.sh
	mkdir -p $(dir $@) && cp $< $@ && chmod +x $@

# Symlinks to binaries
$(PREFIX)/bin/% : $(INSTALLDIR)/bin/%
	mkdir -p $(dir $@) && ln -sf $(subst $(PREFIX)/,../,$<) $@

.PHONY: install uninstall
