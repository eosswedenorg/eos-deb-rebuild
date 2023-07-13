#!/bin/sh
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#
#  Basic logging functions.

comment() {
	local prefix=${COMMENT_PREFIX:-::}
	echo -e " \e[34m[\e[0m$prefix\e[34m]\e[0m" $@
}

error() {
	echo -e "\e[31mError\e[0m:" $@ 1>&2
	exit 1
}

warning() {
	echo -e "\e[33mWarning\e[0m:" $@ 1>&2
}
