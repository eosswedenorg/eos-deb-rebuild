#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#
#  Guess flavor from .deb's Package-field.

# arg1: filename
function guess_pkg_flavor() {

    flavor=$(dpkg -I "${1}" | grep Package | sed -E 's/^\s*Package:\s*([a-z\.]+).*/\1/')

    if [ -z "$flavor" ]; then
        flavor="leap"
    elif [ "$flavor" == "eosio" ]; then
        flavor="eos"
    elif [ "$flavor" == "eosio.cdt" ]; then
        flavor="eos.cdt"
    fi

    echo $flavor
}
