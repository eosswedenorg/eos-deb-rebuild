#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#
#  Correct .deb filenames

# arg1: package name
# arg2: package version
# arg3: package architecture
# arg4: distro (optional)
# arg5: distro version (optional)

function deb_filename() {
    local name=$1
    local pkg_ver=$2
    local pkg_arch=$3
    local distro=${4:-$(lsb_release -is | tr '[:upper:]' '[:lower:]')}
	local version=${5:-$(lsb_release -rs)}

    echo "${name}_${pkg_ver}-${distro}-${version}_${pkg_arch}.deb"
}
