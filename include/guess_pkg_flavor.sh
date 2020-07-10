#!/bin/bash
#
# Guess flavor from .deb's Package-field.

# arg1: filename
function guess_pkg_flavor() {

	flavor=$(dpkg -I "${1}" | grep Package | sed -E 's/^\s*Package:\s*([a-z]+).*/\1/')

	if [ -z "$flavor" ] || [ "$flavor" == "eosio" ]; then
		flavor="eos"
	fi

	echo $flavor
}
