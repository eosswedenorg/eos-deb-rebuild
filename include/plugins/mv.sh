#!/bin/bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.
#
#  Multiversion specific commands.

# Fetch and format mv version (remove "." and skip last "-<number>" e.g. package version)
MV_VERSION=$(echo $VERSION | sed -E 's/\s|\.|\-[0-9]+$//g')

comment "Update package name in control file (${PACKAGE}-${MV_VERSION})"
sed -i -E "s/^(Package:)\s([a-z]+)$/\1 \2-${MV_VERSION}/" ${CONTROL_FILE}

# Remove conflicts
comment "Remove conflicts field in control file"
sed -i "/^Conflicts:/d" ${CONTROL_FILE}

# Remove usr/bin
# original deb packages install symlinks here and will therefor produce conflicts.
comment "Remove usr/bin"
if [ -d ${TMP_DIR}/usr/bin ]; then
	rm -rf ${TMP_DIR}/usr/bin 2> /dev/null
else :
	warning "'usr/bin' did not exist."
fi

# rename directory in usr/opt/ to something unique (again, will produce file conflicts otherwise).
local ORIG_PKGDIR=$(ls "${TMP_DIR}/usr/opt/${PACKAGE}" | head -1)

if [ -z ${ORIG_PKGDIR} ]; then
	warning "Could not find anything in 'usr/opt/${ORIG_PKGDIR}'."
else :
	comment "Rename usr/opt/${PACKAGE} to usr/opt/${PACKAGE}-${MV_VERSION}"
	pushd ${TMP_DIR}/usr/opt/${PACKAGE} > /dev/null
	mv ${ORIG_PKGDIR} ${PACKAGE}-${MV_VERSION} 2> /dev/null
	popd > /dev/null
fi

# Update package name
PACKAGE="${PACKAGE}-${MV_VERSION}"
