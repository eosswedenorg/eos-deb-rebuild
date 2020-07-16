#!/usr/bin/env bash
#
#  Copyright (C) 2019-2020 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

PROGRAM="${0##*/}"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
SHARE_DIR="/usr/local/share/eos-deb-rebuild"
INFO_DIR="${SHARE_DIR}/info"
TMP_DIR="tmp"
INCLUDE_DIR="$(realpath "$(dirname $SELF)/../")/include"
PLUGINS_DIR="$INCLUDE_DIR/plugins"
CONTROL_FILE="${TMP_DIR}/DEBIAN/control"
VERBOSE=0
INPUT_FILE=
PKG_TYPE=standard
PKG_FLAVOR=
PKG_VERSION=

source "${INCLUDE_DIR}/log.sh"
source "${INCLUDE_DIR}/deb_filename.sh"
source "${INCLUDE_DIR}/guess_pkg_flavor.sh"

usage() {
	echo "usage ${PROGRAM} [ OPTIONS ] [ <pkg-spec> ] <file>"

	echo -e "  \e[34mOptions:\e[0m"
	echo -e "   -v\t\tVerbose Output"
	echo -e "   -R <number>\tPackage release number"
	echo    ""
	echo -e "  \e[34mpkg-spec:\e[0m"
	echo -e "  Package specification follows the format \e[33m'<flavor>:<type>'\e[0m"
	echo    "  If the ':' delimiter is not there, the program will guess if the string is flavor or type."
	echo    ""
	echo -e "  If \e[33m<flavor>\e[0m is omitted its taken from the deb file's \`Package\` field. Defaults to \`eos\` if that fails."
	echo -e "  Default \e[33m<type>\e[0m is \`${PKG_TYPE}\`"
	echo    ""
	echo -e "  Flavors are:" $(ls ${INFO_DIR} | sed 's/.*/\\e\[34m&\\e\[0m/;$!s/$/, /')
	echo -e "  Package types are: \e[34mstandard\e[0m," $(ls $PLUGINS_DIR | sed 's/.sh$//;s/.*/\\e\[34m&\\e\[0m/;$!s/$/, /')
	echo    ""
	echo -e "  Example: \e[33m'bos:mv'\e[0m - builds bos multiversion package"
	echo -e "           \e[33m'wax'\e[0m - builds standard wax package"
	echo -e "           \e[33m'mv'\e[0m - builds eos multiversion package"

	exit 1
}

parse_args() {

	while getopts ":vR:" opt; do
	  case ${opt} in
		v )
		  VERBOSE=1
		  ;;
		R )
		  PKG_VERSION="$OPTARG"
		  ;;
		:  )
		  error "Missing value for option '-$OPTARG'"
		  ;;
		\? )
		  warning "Unrecognized option '$OPTARG'"
		  ;;
		* )
		  usage
		  ;;
	  esac
	done
	shift $((OPTIND -1))

	if [ $# -gt 1 ]; then
		local in="$1"

		if [[ $in =~ ":" ]]; then
			PKG_FLAVOR=$(cut -d':' -f1 <<<$in)
			PKG_TYPE=$(cut -d':' -f2 <<<$in)
		# Guess that it's a type
		elif [ -f "${PLUGINS_DIR}/$in.sh" ]; then
			PKG_TYPE="$in"
		# Other
		else :
			PKG_FLAVOR="$in"
		fi

		# Validate
		if [[ ! -z $PKG_FLAVOR  &&  ! -f "${INFO_DIR}/$PKG_FLAVOR" ]] \
		|| [[ ! -f "${PLUGINS_DIR}/$PKG_TYPE.sh" && $PKG_TYPE != "standard" ]]; then
			error "Invalid type: '$in'"
		fi

		shift 1
	fi


	[ $# -eq 0 ] && usage

	INPUT_FILE="$1"

	# Guess flavor from input file if empty.
	if [ -z "$PKG_FLAVOR" ]; then
		PKG_FLAVOR=$(guess_pkg_flavor "$INPUT_FILE")
	fi

	if [ ${VERBOSE} -gt 0 ]; then
		echo "--- Build variables ---"
		echo "Flavor:" $PKG_FLAVOR
		echo "Type:" $PKG_TYPE
		echo "File:" $INPUT_FILE
		if [ ! -z "${PKG_VERSION}" ]; then
			echo "Package Version:" $PKG_VERSION
		fi
	fi
}

program() {
	if [ ! -f $INPUT_FILE ]; then
		error "could not find file: $INPUT_FILE"
	fi

	comment "Extract files from $INPUT_FILE"
	rm -fr ${TMP_DIR}
	dpkg-deb -x $INPUT_FILE ${TMP_DIR}

	# Patch control file.
	if [ -f "${INFO_DIR}/$PKG_FLAVOR" ]; then
		declare -A array

		while read -r l; do
			K=$(cut -d':' -f1 <<<$l)
			V=$(cut -d':' -f2- <<<$l | xargs)
			array[$K]="$V"
		done <<< $(dpkg-deb -f $INPUT_FILE | cat - "${INFO_DIR}/$PKG_FLAVOR")

		mkdir -p $(dirname "${CONTROL_FILE}")
		for k in $(cat $INCLUDE_DIR/control_order); do
			v="${array[$k]}"
			[[ ! -z $v ]] && echo "$k: $v" >> ${CONTROL_FILE}
		done
	fi

	# Get package name and version
	PACKAGE=$(awk -F ':' '/Package/{print $2}' ${CONTROL_FILE} | tr -d '[:space:]')
	VERSION=$(awk -F ':' '/Version/{print $2}' ${CONTROL_FILE} | tr -d '[:space:]')

	# Update version if package version is defined.
	if [ ! -z "$PKG_VERSION" ]; then
		VERSION=$(echo $VERSION | sed -E "s/-[0-9]+\$/-$PKG_VERSION/g")
		sed -i -E "s/^(Version:)\s(.*)\$/\1 ${VERSION}/" ${CONTROL_FILE}
	fi

	if [ -x "${PLUGINS_DIR}/$PKG_TYPE.sh" ]; then
		comment "Execute plugin:" "$PKG_TYPE"
		COMMENT_PREFIX=$PKG_TYPE
		. "${PLUGINS_DIR}/$PKG_TYPE.sh"
		unset COMMENT_PREFIX
	fi

	comment "Build package"
	OUTPUT_FILE=$(echo $INPUT_FILE | sed -E "s/^([a-z\.]+)_([^-]+)-([^-_]+)/${PACKAGE}_${VERSION}/")
	OUTPUT_FILE=$(deb_filename "${OUTPUT_FILE}")
	fakeroot dpkg-deb -b ${TMP_DIR} ${OUTPUT_FILE}
	rm -fr ${TMP_DIR}

	if [ ${VERBOSE} -gt 0 ]; then
		comment "Listing INFO from ${OUTPUT_FILE}"
		dpkg-deb -I ${OUTPUT_FILE}
		comment "Listing CONTENT from ${OUTPUT_FILE}"
		dpkg-deb -c ${OUTPUT_FILE}
	fi

	comment "Done"
}

parse_args $@
program
