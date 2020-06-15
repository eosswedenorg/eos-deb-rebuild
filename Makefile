
NAME 		= eos-deb-rebuild
PREFIX 		= /usr
INSTALLDIR 	= $(PREFIX)/opt/$(NAME)
PROGRAMS 	= $(patsubst %.sh,%,$(shell find bin -type f))
FILES	    = README.md LICENSE $(shell find include -type f)
EXTRAFILES  = $(addprefix $(INSTALLDIR)/,$(FILES))
BINFILES  	= $(addprefix $(INSTALLDIR)/,$(PROGRAMS))
SYMLINKS  	= $(addprefix $(PREFIX)/,$(PROGRAMS))

install : $(BINFILES) $(EXTRAFILES) $(SYMLINKS)

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

deb:
	export PACKAGE_NAME="$(NAME)" \
	export PACKAGE_VERSION="0.2.1" \
	export PACKAGE_PREFIX=$(PREFIX:/%=%) \
	export PACKAGE_PROGRAM=$(PROGRAMS) \
	export PACKAGE_FILES="$(FILES)" \
	export PACKAGE_INSTALLDIR=$(INSTALLDIR:/%=%) \
	&& ./scripts/build_deb.sh

.PHONY: install uninstall deb
