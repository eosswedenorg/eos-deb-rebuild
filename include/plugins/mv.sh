#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#
#  Multiversion specific commands.

function rename() {
    BASE=$1
    OLD=$2
    NEW=$3

    comment "Rename ${OLD} to ${NEW}"

    pushd ${BASE} > /dev/null
    mkdir -p $(dirname ${NEW})
    mv ${OLD} ${NEW} 2> /dev/null
    popd > /dev/null
}

# Fetch and format mv version (remove "." and skip last "-<number>" e.g. package version)
MV_VERSION=$(echo $VERSION | sed -E 's/\s|\.|\-[0-9]+$//g')

comment "Update package name in control file (${PACKAGE}-${MV_VERSION})"
sed -i -E "s/^(Package:)\s([a-z\._-]+)$/\1 \2-${MV_VERSION}/" ${CONTROL_FILE}

# Remove conflicts
comment "Remove conflicts field in control file"
sed -i "/^Conflicts:/d" ${CONTROL_FILE}

# new packages puts binaries directly in /usr/bin
if [ -d ${TMP_DIR}/usr/bin ] && [ -d ${TMP_DIR}/usr/share/licenses/${PACKAGE} ]; then

    local NEW_PATH=usr/opt/${PACKAGE}-${MV_VERSION}

    rename ${TMP_DIR} usr/bin ${NEW_PATH}/bin
    rename ${TMP_DIR} usr/share/licenses/${PACKAGE} ${NEW_PATH}/licenses

    comment "Remove usr/share"
    rm -rf ${TMP_DIR}/usr/share 2> /dev/null

# Special case for mandel packages.
elif [ -d ${TMP_DIR}/usr/local/bin ]; then
    ORIG_PATH=usr/local

    local ORIG_VERDIR=$(ls "${TMP_DIR}/${ORIG_PATH}" 2> /dev/null | head -1)
    local NEW_PATH=usr/opt/${PACKAGE}

    rename ${TMP_DIR} ${ORIG_PATH} ${NEW_PATH}/${MV_VERSION}

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
        rename ${TMP_DIR} ${ORIG_OPT_PATH}/${ORIG_VERDIR} ${NEW_OPT_PATH}/${MV_VERSION}
        if [ -d "${ORIG_OPT_PATH}" ] && [ -z "$(ls -A ${ORIG_OPT_PATH} 2> /dev/null)" ]; then
            comment "${ORIG_OPT_PATH} is empty, removing."
            rm -rf ${ORIG_OPT_PATH}
        fi
    fi

fi

# Update package name
PACKAGE="${PACKAGE}-${MV_VERSION}"
