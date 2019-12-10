#!/usr/bin/env bash
#
# Copyright (C) 2019 Henrik Hautakoski <henrik@eossweden.org>. All Rights Reserved.

PROGRAM="${0##*/}"
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
TMP_DIR="tmp"
INCLUDE_DIR="$(realpath "$(dirname $SELF)/../")/include"
CONTROL_FILE="${TMP_DIR}/DEBIAN/control"
VERBOSE=0
INPUT_FILE=
PKG_TYPE=standard
PKG_FLAVOR=eos

comment() {
	echo -e "\e[34m ::\e[0m" $@
}

error() {
	echo -e "\e[31mError\e[0m:" $@ 1>&2
	exit 1
}

warning() {
	echo -e "\e[33mWarning\e[0m:" $@ 1>&2
}

usage() {
	echo "usage ${PROGRAM} [ -v ] [ <pkg-spec> ] <file>"

	echo    ""
	echo -e "  Default pkg-spec: \e[33m${PKG_FLAVOR}:${PKG_TYPE}\e[0m"
	echo -e "  Package specification follows the format \e[33m'<flavor>:<type>'\e[0m"
	echo    "  If the ':' delimiter is not there, the program will guess if the string is flavor or type."
	echo    ""
	echo -e "  Flavors are:" $(ls $INCLUDE_DIR/control | sed 's/.*/\\e\[34m&\\e\[0m/;$!s/$/, /')
	echo -e "  Package types are: \e[34mstandard\e[0m," $(ls $INCLUDE_DIR/scripts | sed 's/.sh$//;s/.*/\\e\[34m&\\e\[0m/;$!s/$/, /')
	echo    ""
	echo -e "  Example: \e[33m'bos-mv'\e[0m - builds bos multiversion package"
	echo -e "           \e[33m'wax'\e[0m - builds standard wax package"
	echo -e "           \e[33m'mv'\e[0m - builds eos multiversion package"

	exit 1
}

parse_args() {

	while getopts ":v" opt; do
	  case ${opt} in
		v )
		  VERBOSE=1
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
		elif [ -f "$INCLUDE_DIR/scripts/$in.sh" ]; then
			PKG_TYPE="$in"
		# Other
		else :
			PKG_FLAVOR="$in"
		fi

		# Validate
		if [ ! -f "$INCLUDE_DIR/control/$PKG_FLAVOR" ] \
		|| [ ! -f "$INCLUDE_DIR/scripts/$PKG_TYPE.sh" ] && [ $PKG_TYPE != "standard" ]; then
			error "Invalid type: '$in'"
		fi

		shift 1
	fi


	[ $# -eq 0 ] && usage

	INPUT_FILE="$1"

	if [ ${VERBOSE} -gt 0 ]; then
		echo "--- Build variables ---"
		echo "Flavor:" $PKG_FLAVOR
		echo "Type:" $PKG_TYPE
		echo "File:" $INPUT_FILE
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
	if [ -f "$INCLUDE_DIR/control/$PKG_FLAVOR" ]; then
		declare -A array

		while read -r l; do
			K=$(cut -d':' -f1 <<<$l)
			V=$(cut -d':' -f2- <<<$l | xargs)
			array[$K]="$V"
		done <<< $(dpkg-deb -f $INPUT_FILE | cat - "$INCLUDE_DIR/control/$PKG_FLAVOR")

		mkdir -p $(dirname "${CONTROL_FILE}")
		for k in $(cat $INCLUDE_DIR/control_order); do
			v="${array[$k]}"
			[[ ! -z $v ]] && echo "$k: $v" >> ${CONTROL_FILE}
		done
	fi

	# Get package name
	PACKAGE=$(awk -F ':' '/Package/{print $2}' ${CONTROL_FILE} | tr -d '[:space:]')

	if [ -x "$INCLUDE_DIR/scripts/$PKG_TYPE.sh" ]; then
		comment "Execute script:" "$PKG_TYPE.sh"
		. "$INCLUDE_DIR/scripts/$PKG_TYPE.sh"
	fi

	# Build package
	OUTPUT_FILE=$(echo $INPUT_FILE | sed -E "s/^([a-z]+)/$PACKAGE/")
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
