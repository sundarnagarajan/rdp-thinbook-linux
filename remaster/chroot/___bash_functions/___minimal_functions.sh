#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# ------------------------------------------------------------------------
# - Source this file first - using plain 'source path/to/this/file'
# - Then source other function files in the same dir:
#       source_file "${___SRC_DIR}/<function_filename>
# - Can also source files in other locations:
#       source_file "/another/dir/filename"
#
# Sourcing this file sets some useful variables:
#   ___PROG_DIR    : Dir with top-level executing script OR pwd of process
#                    when sourced interactively
#   ___SRC_DIR     : Dir containing this file with functions - may be
#                    the same as or different from ___PROG_DIR
#   ___INTERACTIVE : Set to 'yes' if sourced from interactive shell
#                    'no' otherwise
#
# Global variables that drive search path for source_file:
#
#   By default, first searches in ___SRC_DIR, ___PROG_DIR (in that order)
#   ___SRCDIRS_DEFAULT : Which default search dirs to search
#       If ___SRCDIRS_DEFAULT is unset, defaults to: $___SRC_DIR:$___PROG_DIR
#       If ___SRCDIRS_DEFAULT is set:
#           ___SRC_DIR is searched ONLY if ___SRCDIRS_DEFAULT contains '.'
#           ___PROG_DIR is searched ONLY if ___SRCDIRS_DEFAULT contains '..'
#       ___SRCDIRS_DEFAULT affects adding of ___SRC_DIR and ___PROG_DIR to
#       search path at ANY position
#   ___SRCDIRS : ADDITIONAL paths to search
#       If __SRCDIRS is set and EMPTY, only ABSOLUTE paths are allowed -
#           no search is performed
#       If ___SRCDIRS contains '.', it is replaced with ___SRC_DIR at that position
#       If ___SRCDIRS contains '..', it is replaced with ___PROG_DIR at that position
#       Non-existent and non-dir elements of ___SRCDIRS are IGNORED
#       Elements of ___SRCDIRS that are not absolute paths are IGNORED
#       Any element of ___SRCDIRS starting with './' or '../' are IGNORED
#       Any element of ___SRCDIRS that is '.' or '..' are IGNORED
#       Any element of ___SRCDIRS that is not an absolute path is IGNORED
#       $1 is appended to each dir in ___SRCDIRS
#   When searching, the FIRST found path that exists and is readable is returned
# ------------------------------------------------------------------------
#BASHDOC


function ___check_bash_features() {
    # Directly check some bash features that we depend on
    declare -A ___junk 1>/dev/null 2>&1 || return 1
    ___junk[k1]="test case" 1>/dev/null 2>&1 || return 2
    [[ "${___junk[k1]}" = "test case" ]] || return 3
    local pat="^test (\S+)$" 1>/dev/null 2>&1 || return 4
    [[ ${___junk[k1]} =~ $pat ]] || return 5
    [[ "${BASH_REMATCH[1]}" = "case" ]] || return 6

    # We need a minimum bash version - we use regexes, associative arrays etc
    local ___MIN_BASH_VERSION=4
    if [[ "${BASH_VERSINFO[1]}" -lt $___MIN_BASH_VERSION ]]; then
        >&2 echo "Need bash version >= $___MIN_BASH_VERSION"
        return 7
    fi
}
___ret=0
___check_bash_features || ___ret=$?
if [[ $___ret -ne 0 ]]; then
    >&2 echo "Need to use bash version >= 4 ($___ret)"
    sleep 2
    [[ -n "${BASH_SOURCE+_}" ]] && return 1
    exit 1
fi
unset ___check_bash_features ___ret


# ___INTERACTIVE is yes if being sourced from an interactive shell, no otherwise
if [[ -z "${___INTERACTIVE+_}" ]]; then
    [[ -n "$PS1" ]] && ___INTERACTIVE=yes || ___INTERACTIVE=no
    readonly ___INTERACTIVE
fi
# ___PROG_DIR is pwd if interactive shell or dirname of top-level script otherwise
if [[ -z "${___PROG_DIR+_}" ]]; then
    [[ -n "${BASH_SOURCE+_}" ]] && ___PROG_DIR=$(dirname $(readlink -e ${BASH_SOURCE[-1]})) || ___PROG_DIR="$(pwd)"
    readonly ___PROG_DIR
fi
# ___SRC_DIR is directory of this script or pwd if BASH_SOURCE not set
if [[ -z "${___SRC_DIR+_}" ]]; then
    [[ -n "${BASH_SOURCE+_}" ]] && ___SRC_DIR=$(dirname $(readlink -e ${BASH_SOURCE[0]})) || ___SRC_DIR="$(pwd)"
    readonly ___SRC_DIR
fi

# Do not 'set -ue -o pipefail' in interactive shell - painful
[[ "$___INTERACTIVE" = "yes" ]] || set -ue -o pipefail

function var_value_contains_spaces() {
    # $1: VALUE - not variable NAME
    # Returns: 0 if $1 contains spaces; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    local pat="[[:space:]]"
    [[ $1 =~ $pat ]] && return 0 || return 1
}

function var_declared() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is declared (normal var/ indexed array or associive array; 1 otherwise
    #[[ "$(declare -p $1 2>/dev/null)" =~ ^declare\ -[-nirxaAx]+\ $1 ]];
    [[ $# -lt 1 ]] && return 1
    var_value_contains_spaces "$1" && return 1

    pat="^declare[[:space:]]+([^[:space:]]+)[[:space:]]+$1(={0,1}|$)"
    [[ "$(declare -p $1 2>/dev/null)" =~ $pat ]];
}

# ___SOURCED is associative array with key=full path of sourced script
var_declared ___SOURCED || declare -g -A ___SOURCED

# Use the functions below to avoid tripping up '-u' or '-e' options

function var_type() {
    # $1: variable name - WITHOUT '$'
    # echoes (to stdout): variable type from 'declare -p' output - e.g. --|-a|-A|-n ...
    [[ $# -lt 1 ]] && return 
    var_value_contains_spaces "$1" && return 1

    pat="^declare\s+(\S+)\s+$1="
    # For references 'echo -n' echoes nothing, so use printf
    [[ "$(declare -p $1 2>/dev/null)" =~ $pat ]] && printf '%s\n' "${BASH_REMATCH[1]}" && return 0
    # Associative and non-associative arrays when declared without elements
    # do not have the trailing '='
    pat="^declare\s+(\S+)\s+$1$"
    # For references 'echo -n' echoes nothing, so use printf
    [[ "$(declare -p $1 2>/dev/null)" =~ $pat ]] && printf '%s\n' "${BASH_REMATCH[1]}" && return 0
}

function var_val_in_delimited_var() {
    # $1: variable name WITHOUT '$'
    # $2: value to search for
    # $3: delimiter (optional) - defaults to ':'
    # Returns: 0 if found; 1 otherwise
    [[ $# -lt 2 ]] && return 1
    var_declared "$1" || return 1
    local _S=$2
    local _D=:
    [[ $# -gt 2 ]] && _D=$3
    local ___PAT="^${_S}$|^${_S}${_D}|${_D}${_S}${_D}|${_D}${_S}$"
    [[ ${!1} =~ $___PAT ]]
}

function var_split_delimited_var() {
    # $1: variable name WITHOUT '$'
    # $2: delimiter (optional) - defaults to ':'
    # echoes (stdout) contents of $1 split on delimiter
    [[ $# -lt 1 ]] && return 0
    var_declared "$1" || return 0
    local _D=:
    [[ $# -gt 1 ]] && _D=$2
    echo "${!1}" | while IFS="${_D}" read -ra p_arr
    do 
        for p in "${p_arr[@]}"
        do [[ -n "$p" ]] && echo -n "$p "
        done
    done
}

function path_is_abs() {
    # $1: value: path
    # Returns:0 if $1 starts with '/'; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ "$1" = /* ]]
}

function var_is_ref() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is a reference to another var; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ -n "$1" ]] || return 1
    var_declared "$1" || return 1
    pat="^declare\s+-n\s+$1=\"\S+\""
    [[ "$(declare -p $1 2>/dev/null)" =~ $pat ]]
}

function var_deref() {
    # $1: variable name - WITHOUT '$'
    # Outputs (to stdout):
    #   ARG1 (unchanged) if it is declared but is not a reference
    #   The FINAL variable that ARG1 points at if it is a ref
    #   NOTHING if ARG1 is not a declared variable
    # Returns:
    #   0: If ARG1 is declared and is not a reference
    #   0: If ARG1 is a reference and dereferenced variable is declared
    #   1: If $1 is not set or null or contains white space
    #   2: If ARG1 is not a declared variable
    #   3: If ARG1 is a reference and final var it points at is not declared
    #   4: Unexpected error - should not happen
    [[ $# -lt 1 ]] && return 1
    [[ -n "$1" ]] || return 1
    var_value_contains_spaces "$1" && return 1
    var_declared "$1" || return 2
    var_is_ref "$1"
    [[ $? -ne 0 ]] && printf '%s\n' "$1" && return 0

    local var_name=$1

    while [[ "$var_name" ]];
    do
        pat="^declare\s+-n\s+${var_name}=\"(\S+)\""
        [[ "$(declare -p ${var_name} 2>/dev/null)" =~ $pat ]] || return 4
        var_name=$(printf '%s\n' "${BASH_REMATCH[1]}") || return 4

        var_is_ref "${var_name}"
        if [[ $? -eq 0 ]]; then
            # One more level of deref required
            continue
        else
            # Not a reference - end loop
            var_declared "${var_name}" || return 3
            printf '%s\n' "${var_name}" && return 0
        fi
    done
    return 4
}

function var_is_map() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is a associative array; 1 otherwise
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 1
    local vt=$(var_type $dereferenced)
    [[ -z "$vt" ]] && return 1
    [[ $vt = "-A" ]]
}

function var_map_has_elem() {
    # $1: associative array var WITHOUT '$'
    # $2: key
    # Returns:
    #   0: If key $1 found in associative array $2
    #   1: If associative array $1 found, but key $2 not found in it
    #   2: If $1 is not an associative array OR $1 not a declared var
    #   3: $1 or $2 not set
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 2 ]] && return 3
    local dereferenced=$(var_deref "$1") || return 2
    var_is_map "$dereferenced" || return 2
    declare -n ___ref=$dereferenced
    [[ ${___ref["$2"]+_} ]] 1>/dev/null 2>&1  && return 0 || return 1
}

function ___find_source_file() {
    # $1: source file path (value)
    # echoes full path of source file if found to stdout
    # Returns: 0 if source file found; 1 otherwise
    #
    # If $1 is an absolute path, it is searched for as such
    # elif $1 is a relative path, search uses two (optional) global variables:
    #   By default, first searches in ___SRC_DIR, ___PROG_DIR (in that order)
    #   ___SRCDIRS_DEFAULT : Which default search dirs to search
    #       If ___SRCDIRS_DEFAULT is unset, defaults to: $___SRC_DIR:$___PROG_DIR
    #       If ___SRCDIRS_DEFAULT is set:
    #           ___SRC_DIR is searched ONLY if ___SRCDIRS_DEFAULT contains '.'
    #           ___PROG_DIR is searched ONLY if ___SRCDIRS_DEFAULT contains '..'
    #       ___SRCDIRS_DEFAULT affects adding of ___SRC_DIR and ___PROG_DIR to
    #       search path at ANY position
    #   ___SRCDIRS : ADDITIONAL paths to search
    #       If __SRCDIRS is set and EMPTY, only ABSOLUTE paths are allowed -
    #           no search is performed
    #       If ___SRCDIRS contains '.', it is replaced with ___SRC_DIR at that position
    #       If ___SRCDIRS contains '..', it is replaced with ___PROG_DIR at that position
    #       Non-existent and non-dir elements of ___SRCDIRS are IGNORED
    #       Elements of ___SRCDIRS that are not absolute paths are IGNORED
    #       Any element of ___SRCDIRS starting with './' or '../' are IGNORED
    #       Any element of ___SRCDIRS that is '.' or '..' are IGNORED
    #       Any element of ___SRCDIRS that is not an absolute path is IGNORED
    #       $1 is appended to each dir in ___SRCDIRS
    #   When searching, the FIRST found path that exists and is readable is returned

    if [[ $# -lt 1 ]]; then
        return 1
    fi
    local ___FOUND_PATH=

    if path_is_abs "$1"; then
        if [[ ! -e "$1" ]]; then
            # Doesn't exist
            >&2 echo "Absolute path does not exist: $1"
            return 2
        fi
        if [[ ! -r "$1" ]]; then
            # Not readable
            >&2 echo "Absolute path not readable: $1"
            return 3
        fi
        ___FOUND_PATH=$(readlink -e "$1")
        echo "$___FOUND_PATH"
        return 0
    fi
    # If we got here, $1 is not an absolute path
    if var_declared ___SRCDIRS; then
       if [[ -z "${___SRCDIRS}" ]]; then
            # ___SRCDIRS explicitly set and empty, but not absolute path
            return 4
        fi
    fi
    # Whether we search in ___SRC_DIR and ___PROG_DIR at all
    local ___SEARCH_SRC=0
    local ___SEARCH_PROG=0
    if [[ "${___SRCDIRS_DEFAULT+_}" ]]; then
        var_val_in_delimited_var ___SRCDIRS_DEFAULT '\.' || ___SEARCH_SRC=1
        var_val_in_delimited_var ___SRCDIRS_DEFAULT '\.\.' || ___SEARCH_PROG=1
    fi
    # Now actual search
    local ___SEARCH_PATH=
    if [[ "${___SRCDIRS+_}" ]]; then
        ___SEARCH_PATH=$___SRCDIRS
        local ret=0
        var_val_in_delimited_var ___SRCDIRS '\.' || ret=1
        if [[ $ret -ne 0 ]]; then
            if [[ $___SEARCH_SRC -eq 0 ]]; then
                ___SEARCH_PATH="${___SRC_DIR}:$___SEARCH_PATH"
            fi
        fi
        ret=0
        var_val_in_delimited_var ___SRCDIRS '\.\.' || ret=1
        if [[ $ret -ne 0 ]]; then
            if [[ $___SEARCH_PROG -eq 0 ]]; then
                ___SEARCH_PATH="${___PROG_DIR}:$___SEARCH_PATH"
            fi
        fi
    else
        if [[ $___SEARCH_SRC -eq 0 ]]; then
            ___SEARCH_PATH="${___SRC_DIR}:$___SEARCH_PATH"
        fi
        if [[ $___SEARCH_PROG -eq 0 ]]; then
            ___SEARCH_PATH="${___PROG_DIR}:$___SEARCH_PATH"
        fi
    fi
    # Now we search based on ___SEARCH_PATH
    local ___EXCLUDE_PAT="^\./|^\.\./"
    for p in $(var_split_delimited_var ___SEARCH_PATH)
    do
        [[ "$p" = '.' ]] && p=$___SRC_DIR
        [[ "$p" = '..' ]] && p=$___PROG_DIR
        path_is_abs "$p" || continue
        [[ -e "$p" ]] || continue
        p=$(readlink -e "$p")
        [[ -d "$p" ]] || continue
        [[ $p =~ $___EXCLUDE_PAT ]] && continue
        ___FOUND_PATH="${p}/$1"
        [[ -e "$___FOUND_PATH" ]] || continue
        ___FOUND_PATH=$(readlink -e "$___FOUND_PATH")
        [[ -r "$___FOUND_PATH" ]] || continue
        # Found
        echo $___FOUND_PATH
        return 0
    done
    return 5 # didn't find
}

function source_file() {
    # $1: file path to source
    # $2: ___OVERRIDE : If set to any value allow re-sourcing
    #
    # Usage:
    #   If calling this function from NON-INTERACTIVE script:
    #       To IGNORE error:
    #           source_file xyz/abc || true
    #       To exit on error:
    #           source_file xyz/abc
    #   If calling this function from an INTERACTIVE shell:
    #       You do not want to exit if sourcing fails (usually)
    #           source_file xyz/abc
    #       If you do:
    #           source_file xyz/abc || exit 1
    [[ $# -lt 1 ]] && return 1
    [[ -z "$1" ]] && return 1
    if [[ ! -r "$1" ]]; then
        return 1
    fi
    declare -i ___OVERRIDE=0
    if [[ $# -gt 1 ]]; then
        if [[ -n "$2" ]]; then
            ___OVERRIDE=1
        fi
    fi

    local ret=0
    local ___SRC_FILE=$(___find_source_file "$1") || return 1
    local found=1
    var_map_has_elem ___SOURCED "$___SRC_FILE" && found=0
    if [[ $found -eq 0 ]]; then
        if [[ $___OVERRIDE -eq 0 ]]; then
            # echo "$___SRC_FILE : already sourced" >&2
            return $ret
        else
            # echo "$___SRC_FILE : re-sourcing" >&2
            unset ___SOURCED["$___SRC_FILE"]
        fi
    fi

    ret=0
    source "$___SRC_FILE" || ret=$?
    if [[ $ret -eq 0 ]]; then
        ___SOURCED["$___SRC_FILE"]=sourced
    fi
    return $ret
}

# export source_file in case we sourced this file in an interactive shell
export source_file

___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
