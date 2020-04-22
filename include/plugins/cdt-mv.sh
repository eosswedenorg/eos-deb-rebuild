#!/bin/bash
#
# CDT Multiversion specific commands

# Fetch and format mv version (only keep major and minor
local MV_VERSION=$(echo $VERSION | sed -E 's/^([0-9]+\.[0-9]+).*/\1/')

local type=$(echo ${PKG_FLAVOR} | sed 's/.cdt$//')
if [ ! -z "$type" ] && [ "$type" != "eos" ]; then
	MV_VERSION="${type}-${MV_VERSION}"
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

comment "Rename ${TMP_DIR}/usr/opt/eosio.cdt/${VERSION_DIR} -> ${TMP_DIR}/usr/opt/eosio.cdt/${MV_VERSION}"
mv "${TMP_DIR}/usr/opt/eosio.cdt/${VERSION_DIR}" "${TMP_DIR}/usr/opt/eosio.cdt/${MV_VERSION}"

comment "Create Linkfile"
pushd "${TMP_DIR}/usr/opt/eosio.cdt/${MV_VERSION}" &> /dev/null
find bin/ -name "eosio-*" >> LINK
find lib/cmake/ -type f >> LINK
popd &> /dev/null

# Update package name
PACKAGE="${PACKAGE}-${MV_VERSION}"
