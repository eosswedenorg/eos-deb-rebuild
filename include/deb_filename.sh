#!/bin/bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.
#
#  Correct .deb filenames

# arg1: filename
function deb_filename() {
	local version=$(lsb_release -rs)
	local distro=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

	echo $1 | sed -E "s/^([a-z0-9\.-]+)_([^-]+)-([^_]+)_([a-z0-9]+)\.deb\$/\1_\2-\3-${distro}-${version}_\4.deb/"
}
