#!/bin/bash
#
#  Copyright (c) 2019-2023 EOS Sw/eden
#

SELF="$(readlink -f "${BASH_SOURCE[0]}")"
BASE_DIR=$(dirname $SELF)
INCLUDE_DIR="$(realpath "$BASE_DIR/../")/include"

source "${BASE_DIR}/assert.sh"
source "${INCLUDE_DIR}/deb_filename.sh"

assert "$(deb_filename "eosio" "1.8.7-1" "amd64" "ubuntu" "18.04")" "eosio_1.8.7-1-ubuntu-18.04_amd64.deb"
assert "$(deb_filename "eosio.cdt" "1.8.1-1" "amd64" "ubuntu" "16.04")" "eosio.cdt_1.8.1-1-ubuntu-16.04_amd64.deb"
assert "$(deb_filename "eosio" "2.0.8-sec2" "amd64" "ubuntu" "18.04")" "eosio_2.0.8-sec2-ubuntu-18.04_amd64.deb"
assert "$(deb_filename "eosio" "2.0.7-sec-patch2" "amd64" "ubuntu" "18.04")" "eosio_2.0.7-sec-patch2-ubuntu-18.04_amd64.deb"

assert "$(deb_filename "mandel" "3.1.0wax01-1" "x86_64" "ubuntu" "18.04")" "mandel_3.1.0wax01-1-ubuntu-18.04_x86_64.deb"
assert "$(deb_filename "mandel-3.1.0wax01-rc1" "3.1.0wax01-rc1" "x86_64" "ubuntu" "18.04")" "mandel-3.1.0wax01-rc1_3.1.0wax01-rc1-ubuntu-18.04_x86_64.deb"
assert "$(deb_filename "wax-mandel-310wax01-rc1" "3.1.0wax01-rc1" "x86_64" "ubuntu" "18.04")" "wax-mandel-310wax01-rc1_3.1.0wax01-rc1-ubuntu-18.04_x86_64.deb"
