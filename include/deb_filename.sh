#!/bin/bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.
#
#  Correct .deb filenames

# arg1: filename
function deb_filename() {
	local version=$(lsb_release -rs)
	local distro=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

	echo $1 | sed -E "s/(-${distro})?(-${version})?_([a-z0-9]+)\.deb\$/-${distro}-${version}_\3.deb/"
}
