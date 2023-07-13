#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#

function assert {
    local actual=$1
    local expected=$2

    if [ "$actual" != "$expected" ]; then
        echo -e "[\e[31mFAILED\e[0m] expected: '$expected' but got: '$actual'"
    else :
        echo -e "[\e[32mOK\e[0m] $expected"
    fi
}
