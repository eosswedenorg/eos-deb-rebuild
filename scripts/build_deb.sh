#!/usr/bin/env bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PACKAGE_DESCRIPTION="Script to rebuild eosio debian packages"
PACKAGE_TMPDIR="pack"

# Default to 1 if no release is set.
if [[ -z $RELEASE ]]; then
  RELEASE="1"
fi

PACKAGE_FULLNAME="${PACKAGE_NAME}_${PACKAGE_VERSION}-${RELEASE}_all"

rm -fr ${BASE_DIR}/${PACKAGE_TMPDIR}

# Create debian files.
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN
echo "Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}-${RELEASE}
Section: devel
Priority: optional
Architecture: all
Homepage: https://github.com/eosswedenorg/eos-deb-rebuild
Maintainer: Henrik Hautakoski <henrik@eossweden.org>
Depends: eos-deb-rebuild-info (>= 1.0.3)
Description: ${PACKAGE_DESCRIPTION}" &> ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

cat ${BASE_DIR}/${PACKAGE_TMPDIR}/DEBIAN/control

# Copy all files
for file in ${PACKAGE_FILES}; do
	mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_INSTALLDIR}/$(dirname ${file})
	cp ${BASE_DIR}/../$file ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_INSTALLDIR}/${file}
done

# Copy program
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_INSTALLDIR}/$(dirname ${PACKAGE_PROGRAM})
cp ${BASE_DIR}/../${PACKAGE_PROGRAM}.sh ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_INSTALLDIR}/${PACKAGE_PROGRAM}


# Create bindir and symlink.
mkdir -p ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_BINDIR}
pushd ${BASE_DIR}/${PACKAGE_TMPDIR}/${PACKAGE_BINDIR} > /dev/null
ln -sf $(echo ${PACKAGE_INSTALLDIR} | sed "s~${PACKAGE_PREFIX}~..~")/${PACKAGE_PROGRAM} $(basename ${PACKAGE_PROGRAM})
popd > /dev/null

fakeroot dpkg-deb --build ${BASE_DIR}/${PACKAGE_TMPDIR} ${BASE_DIR}/${PACKAGE_FULLNAME}.deb
