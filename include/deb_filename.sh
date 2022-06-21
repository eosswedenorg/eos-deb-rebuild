#!/bin/bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.
#
#  Correct .deb filenames

# arg1: filename
# arg2: distro (optional)
# arg3: version (optional)
function deb_filename() {
    local distro=${2:-$(lsb_release -is | tr '[:upper:]' '[:lower:]')}
	local version=${3:-$(lsb_release -rs)}

	echo $1 | sed -E "s/(-${distro})?(-${version})?_([a-z0-9]+)\.deb\$/-${distro}-${version}_\3.deb/"
}
