
NAME 			= eos-deb-rebuild
DESTDIR			= /
PREFIX 			= usr
INSTALLDIR 		= $(DESTDIR)/$(PREFIX)
INSTALLDIR_OPT  = $(INSTALLDIR)/opt/$(NAME)
PROGRAMS 		= $(patsubst %.sh,%,$(shell find bin -type f))
FILES	    	= README.md LICENSE $(shell find include -type f)
EXTRAFILES  	= $(addprefix $(INSTALLDIR_OPT)/,$(FILES))
BINFILES  		= $(addprefix $(INSTALLDIR_OPT)/,$(PROGRAMS))
SYMLINKS  		= $(addprefix $(INSTALLDIR)/,$(PROGRAMS))

install : $(BINFILES) $(EXTRAFILES) $(SYMLINKS)

uninstall :
	rm $(SYMLINKS)
	rm -r $(INSTALLDIR)

# Files
$(INSTALLDIR_OPT)/% : %
	mkdir -p $(dir $@) && cp $< $@

# Binaries
$(INSTALLDIR_OPT)/bin/% : bin/%.sh
	mkdir -p $(dir $@) && cp $< $@ && chmod +x $@

# Symlinks to binaries
$(INSTALLDIR)/bin/% : $(INSTALLDIR_OPT)/bin/%
	mkdir -p $(dir $@) && ln -sf $(subst $(INSTALLDIR)/,../,$<) $@

.PHONY: install uninstall
