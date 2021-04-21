#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# -------------------------------------------------------------------------
# Functions to encode, decode, transform
# bash-specific and may need bash version 4
# Packages: coreutils, perl-base, sed, grep
# -------------------------------------------------------------------------
#BASHDOC


# ___SRC_DIR is directory of this script or pwd if BASH_SOURCE not set
if [[ -z "${___SRC_DIR+_}" ]]; then
    [[ -n "${BASH_SOURCE+_}" ]] && ___SRC_DIR=$(dirname $(readlink -e ${BASH_SOURCE[0]})) || ___SRC_DIR="$(pwd)"
    readonly ___SRC_DIR
fi
# Explicitly source ___minimal_functions.sh using ___SRC_DIR to cause error if
# ___minimal_functions.sh has not been sourced yet
[[ -n "${PS1+_}" ]] || set -e
declare -p -F source_file 1>/dev/null 2>&1 && source_file "${___SRC_DIR}/___minimal_functions.sh" || source "${___SRC_DIR}/___minimal_functions.sh"


function encode_dos2unix() {
    # $1: input file
	# Writes to STDOUT
	# converts DOS-style linefeeds to Unix-style
	# Packages: coreutils (tr)
    [[ $# -lt 1 ]] && return
	tr -d '\r' < $1
}

function encode_hex2dec() {
	# $1: value to convert (interpreted as hexadecimal value)
    # echoes (to stdout): decimal value
	# uses bash to convert a hexadecimal value to decimal
	# Replace 16 with, e.g. 8 to convert from octal
    [[ $# -lt 1 ]] && return
	echo $(( 16#$1 ))
}

function encode_dec2hex() {
	# $1: decimal value to convert
    # echoes (to stdout): value in HEX
	# converts value to hexadecimal
	# Packages: coreutils(printf)
    [[ $# -lt 1 ]] && return
	printf "%0X\n" $1
}

function encode_url_encode() {
	# $1: string to encode
    # echoes (to stdout): url encoded version
    # Packages: perl-base(perl)
    [[ $# -lt 1 ]] && return
	echo $* | perl -wpl -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg'
}

function encode_remove_double_quotes() {
	# Reads STDIN, result on STDOUT
    # Packages: sed(sed)
	sed -e 's/\"//g'
}

function encode_remove_single_quotes() {
	# Reads STDIN, result on STDOUT
    # Packages: sed(sed)
	sed -e "s/\'//g"
}

function encode_remove_commas() {
	# Reads STDIN, result on STDOUT
    # Packages: sed(sed)
	sed -e 's/\,//g'
}

function encode_remove_comments() {
	# Reads STDIN, writes result on STDOUT
	# Removes shell-style (#) comments - lines starting with a #
	# or starting with whitespace folloed by a #
    # Packages: grep(grep)
	grep -v '^[[:space:]]*#'
}

function encode_remove_blank_lines() {
	# Reads STDIN, writes result on STDOUT
    # Packages: grep(grep)
	grep -v '^[[:space:]]*$'
}

function encode_tabout() { 
	# Reads STDIN, writes result on STDOUT
    # Packages: coreutils(fold)
	fold -s -w $(( $COLUMNS - 8 )) | sed -e '/^/s//        /'; 
}

function encode_prefix() { 
    # $1: (optional): prefix to use - defaults to 4 spaces
    # Prefixes each line with $1 or 4 spaces if $1 is not set
	# Reads STDIN, writes result on STDOUT
    # Packages: coreutils(fold)
    local prefix="    "
    local prefix_len=4
    if [[ $# -ge 1 ]]; then
        prefix=$1
        prefix_len=${#1}
    fi
    fold -s -w $(( $COLUMNS - $prefix_len )) | sed -e "/^/s//$prefix/" 
}


___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
