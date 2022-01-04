#!/bin/bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.
#
#  CDT Multiversion specific commands

# Fetch and format mv version (only keep major and minor
local MV_VERSION=$(echo $VERSION | sed -E 's/^([0-9]+\.[0-9]+).*/\1/')

PACKAGE_NO_CDT=$(echo ${PACKAGE} | sed 's/.cdt$//')
# For non eosio, prefix the direction with package name.
if [ "$PACKAGE_NO_CDT" != "eosio" ]; then
	MV_DIRECTORY="${PACKAGE_NO_CDT}-${MV_VERSION}"
else
	MV_DIRECTORY="${MV_VERSION}"
fi

comment "Update package name in control file (${PACKAGE}-${MV_VERSION})"
sed -i -E "s/^(Package:)\s([a-z\.]+)$/\1 \2-${MV_VERSION}/" ${CONTROL_FILE}

# Remove usr/bin
# original deb packages install symlinks here and will therefor produce conflicts.
comment "Remove usr/bin"
if [ -d ${TMP_DIR}/usr/bin ]; then
	rm -rf ${TMP_DIR}/usr/bin 2> /dev/null
else :
	warning "'usr/bin' did not exist."
fi

# Remove usr/lib
# original deb packages install symlinks here and will therefor produce conflicts.
comment "Remove usr/lib"
if [ -d ${TMP_DIR}/usr/lib ]; then
	rm -rf ${TMP_DIR}/usr/lib 2> /dev/null
else :
	warning "'usr/lib' did not exist."
fi

local VERSION_DIR=$(ls ${TMP_DIR}/usr/opt/eosio.cdt)

comment "Rename ${TMP_DIR}/usr/opt/eosio.cdt/${VERSION_DIR} -> ${TMP_DIR}/usr/opt/eosio.cdt/${MV_DIRECTORY}"
mv "${TMP_DIR}/usr/opt/eosio.cdt/${VERSION_DIR}" "${TMP_DIR}/usr/opt/eosio.cdt/${MV_DIRECTORY}"

# Need to update cmake config with the new path.
CMAKE_CONFIG="${TMP_DIR}/usr/opt/eosio.cdt/${MV_DIRECTORY}/lib/cmake/eosio.cdt/eosio.cdt-config.cmake"
if [ -f "${CMAKE_CONFIG}" ]; then
	comment "Patch cmake config (${CMAKE_CONFIG}) with correct path"
	sed -i -E "s~(set\(EOSIO_CDT_ROOT)\s*\"(.+)\"~\1 \"/usr/opt/eosio.cdt/${MV_DIRECTORY}\"~" ${CMAKE_CONFIG}
fi

comment "Create Linkfile"
pushd "${TMP_DIR}/usr/opt/eosio.cdt/${MV_DIRECTORY}" &> /dev/null
find bin/ -name "eosio-*" >> LINK
find lib/cmake/ -type f >> LINK
popd &> /dev/null

# Update package name
PACKAGE="${PACKAGE}-${MV_VERSION}"
