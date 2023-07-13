#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#
#  Multiversion specific commands.

# Fetch and format mv version (remove "." and skip last "-<number>" e.g. package version)
MV_VERSION=$(echo $VERSION | sed -E 's/\s|\.|\-[0-9]+$//g')

comment "Update package name in control file (${PACKAGE}-${MV_VERSION})"
sed -i -E "s/^(Package:)\s([a-z\._-]+)$/\1 \2-${MV_VERSION}/" ${CONTROL_FILE}

# Remove conflicts
comment "Remove conflicts field in control file"
sed -i "/^Conflicts:/d" ${CONTROL_FILE}

# Special case for mandel packages.
if [ -d ${TMP_DIR}/usr/local/bin ]; then
    ORIG_PATH=usr/local

    local ORIG_VERDIR=$(ls "${TMP_DIR}/${ORIG_PATH}" 2> /dev/null | head -1)
	local NEW_PATH=usr/opt/${PACKAGE}
	comment "Rename ${ORIG_PATH} to ${NEW_PATH}/${MV_VERSION}-mv"
	pushd ${TMP_DIR} > /dev/null
	mkdir -p "${NEW_PATH}"
	mv ${ORIG_PATH} ${NEW_PATH}/${MV_VERSION}-mv 2> /dev/null
	popd > /dev/null

# All other types of packages :)
else :

    # Remove usr/bin
    # original deb packages install symlinks here and will therefor produce conflicts.
    comment "Remove usr/bin"
    if [ -d ${TMP_DIR}/usr/bin ]; then
    	rm -rf ${TMP_DIR}/usr/bin 2> /dev/null
    else :
    	warning "'usr/bin' did not exist."
    fi

    # Find package directory.
    if [ -d ${TMP_DIR}/usr/opt/${PACKAGE} ]; then
    	ORIG_OPT_PATH=usr/opt/${PACKAGE}
    else :
    	ORIG_OPT_PATH=usr/opt/eosio
    fi

    # rename directory in usr/opt/ to something unique (again, will produce file conflicts otherwise).
    local ORIG_VERDIR=$(ls "${TMP_DIR}/${ORIG_OPT_PATH}" 2> /dev/null | head -1)

    if [ -z ${ORIG_VERDIR} ]; then
    	warning "Could not find anything in '${ORIG_OPT_PATH}'."
    else :
    	local NEW_OPT_PATH=usr/opt/${PACKAGE}
    	comment "Rename ${ORIG_OPT_PATH}/${ORIG_VERDIR} to ${NEW_OPT_PATH}/${MV_VERSION}-mv"
    	pushd ${TMP_DIR} > /dev/null
    	mkdir -p "${NEW_OPT_PATH}"
    	mv ${ORIG_OPT_PATH}/${ORIG_VERDIR} ${NEW_OPT_PATH}/${MV_VERSION}-mv 2> /dev/null
    	if [ -z "$(ls -A ${ORIG_OPT_PATH})" ]; then
    		comment "${ORIG_OPT_PATH} is empty, removing."
    		rm -rf ${ORIG_OPT_PATH}
    	fi
    	popd > /dev/null
    fi

fi

# Update package name
PACKAGE="${PACKAGE}-${MV_VERSION}"
