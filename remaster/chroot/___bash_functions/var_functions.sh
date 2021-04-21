#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# ------------------------------------------------------------------------
# Functions related to variables
# Depends (only) on ___minimal_functions.sh
# Does not use or call any external commands or sub-shells
# bash-specific and may need bash version 4
#
# functions with names starting with 'var_value_' use the VALUE of the
#   variables provided as parameters
# Other functions names starting with var_ (but not starting with
# 'var_value_' expect variable NAMES WITHOUT the '$'
# ------------------------------------------------------------------------
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



function var_undeclared() {
    # $1: variable name - WITHOUT '$'
    # Returns: 1 if $1 is declared (normal var/ indexed array or associive array; 0 otherwise
    # Exact complement of var_declared
    [[ $# -lt 1 ]] && return 1
    var_declared "$1" && return 1 || return 0
}

function var_is_array() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is a non-associative array; 1 otherwise
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 1
    local vt=$(var_type $dereferenced)
    [[ -z "$vt" ]] && return 1
    local pat="[a]"
    [[ $vt =~ $pat ]]
}

function var_is_nonarray() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is a 'normal' var (non-array); 1 otherwise
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 1
    local vt=$(var_type $dereferenced)
    [[ -z "$vt" ]] && return 1
    local pat="[a]"
    [[ $vt =~ $pat ]] && return 1
    pat="[A]"
    [[ $vt =~ $pat ]] && return 1
    return 0
}

function var_value_int() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if value of $1 is an integer; 1 otherwise
    # Undeclared variable names return 1
    # All array-type variables return 1
    [[ $# -lt 1 ]] && return 1
    var_is_nonarray "$1" || return 1
    local pat='^[0-9]+$'
    [[ "${!1}" =~ $pat ]]
}

function var_value_numeric() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if value of $1 is an integer OR float; 1 otherwise
    # Undeclared variable names return 1
    # All array-type variables return 1
    # Useful for checking variable to pass to sleep function etc
    # Use value_is_numeric if possible - it is faster
    [[ $# -lt 1 ]] && return 1
    var_is_nonarray "$1" || return 1
    [[ -n "${!1}" ]] || return 1
    printf "%f" "${!1}" 1>/dev/null 2>&1 || return 1
    return 0
}

function var_is_readonly() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is a readonly variable; 1 otherwise
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 1
    local vt=$(var_type $dereferenced)
    [[ -z "$vt" ]] && return 1
    local pat="[r]"
    [[ $vt =~ $pat ]]
}

function var_is_exported() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if $1 is an exported variable; 1 otherwise
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 1
    local vt=$(var_type $dereferenced)
    [[ -z "$vt" ]] && return 1
    local pat="[x]"
    [[ $vt =~ $pat ]]
}

function var_len() {
    # $1: variable name - WITHOUT '$'
    # echoes (to stdout):
    #   Length of variable value - for non-array vars
    #   Number of elements - for array vars
    #   0 if unset
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 0
    local ret=0
    local dereferenced=$(var_deref "$1") || ret=1
    if [[ $ret -ne 0 ]]; then
        echo 0
        return 0
    fi
    var_is_nonarray "$dereferenced" && echo ${#1} && return 0

    declare -n ___ref=$dereferenced

    # indexed and associative arrays give 'unbound variable' error when accesing
    # size with '${#var[@]}' even if variable is declared unless array has elements
    # So we need to reset '-u' option if set and restore at the end
    local ___uplus
    [[ -o nounset ]] && ___uplus=yes || ___uplus=no
    [[ "$___uplus" = "yes" ]] && set +u

    declare -i size=${#___ref[@]}
    [[ "$___uplus" = "yes" ]] && set -u
    unset $___uplus
    echo $size
}

function var_empty() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if unset _OR_ null or declared without any elements; 1 otherwise
    # Works for ordinary vars, ordinary arrays and associative arrays and references
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local dereferenced=$(var_deref "$1") || return 0
    var_is_nonarray "$dereferenced" && [[ -z "${dereferenced}" ]] && return 0
    # Otherwise it is set and it is some type of array
    [[ $(var_len "$1") -eq 0 ]]
}

function var_strip() {
    # $1: variable name - WITHOUT '$'
    # Outputs: $1 CONTENTS with leading AND trailing white space stripped
    [[ $# -lt 1 ]] && return
    var_value_contains_spaces "$1" && return
    var_declared "$1" || return
    if [[ "${!1}" =~ ^[[:space:]]*(.*)[[:space:]]*$ ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

function var_regex() {
    # $1: variable name - WITHOUT '$'
    # $2: regex expression
    # Returns: 0 if value of $1 matches $2; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    var_value_contains_spaces "$1" && return 1
    [[ "${!1}" =~ "$2" ]];
}

function var_make_readonly() {
    # $@ variable names WITHOUT '$'
    # Will become read-only - irreversible
    # Note - if any of the variable names are REFERENCES, then
    # the REFERENCE is made read-only. 
    for v in $@
    do
        var_declared $v || continue
        readonly $v
    done
}

function var_can_be_var_name() {
    # $1: variable name - WITHOUT '$'
    # Returns: 0 if ARG1 can be a variable name; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    read -r var_name <<< "$1"
    declare $var_name 1>/dev/null 2>&1 || return 1
    return 0
}

function var_value_len() {
    # $1: VALUE - not variable NAME
    # echoes (to stdout): Length of value
    #   NOT DEFINED for array variables
    [[ $# -lt 1 ]] && return 0
    var_declared "$1" || return
    var_value_contains_spaces "$1" && return 0
    echo ${#1} && return 0
}

function var_value_bool() {
    # $1: VALUE to check - NOT variable name without '$'
    # Returns: 0 if one of (y|Y|Yes|yes|TRUE|true|True or value is zero; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ -n "$1" ]] || return 1
    [[ $1 =~ ^(y|Y|Yes|yes|TRUE|true|True)$ ]]; 
}

function var_bool() {
    # $1: Variable to check - variable name WITHOUT '$'
    # Returns: 0 if one of (y|Y|Yes|yes|TRUE|true|True; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    var_declared "$1" || return 1
    var_empty "$1" || return 1
    local ___ret=0
    local ___v=$(var_deref $1 || ___ret=1)
    [[ $___ret -ne 0 ]] && return 1
    var_value_bool "${!___v}"
}

function var_value_no_bad_chars() {
    # $1: VALUE to check - NOT variable name without '$'
    # $2: optional: if not empty, allows '/' character also (e.g. in paths
    # Returns: 0 if value does not contain troublesome characters; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    local v="$1"
    local path=1
    if [[ $# -gt 1 ]]; then
        if [[ -n "$2" ]]; then
            path=0
        fi
    fi
    if [[ $path -eq 0 ]]; then
        local conv=$(echo -e "$v" | sed -e 's/[^[[:upper:][:lower:][:digit:]/\._\-]//g')
    else
        local conv=$(echo -e "$v" | sed -e 's/[^[[:upper:][:lower:][:digit:]\._\-]//g')
    fi
    [[ "$v" = "$conv" ]]
}

function var_array_clear() {
    # $1: (NON-associative) array var WITHOUT '$'
    # Will CLEAR the (NON-associative) array ARG1
    # If ARG1 is not declared or is not a (NON-associative) array, does nothing
    # Returns:
    #   1: If ARG1 is not set
    #   2: If ARG1 is not declared or is not an (NON_associative) array
    #   3: If ARG1 is a (NON-associative) array, but is readonly
    #   0: Otherwise (success)
    #
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local ___ref_name=$(var_deref "$1") || return 2
    var_is_array ___ref_name || return 2
    var_is_readonly ___ref_name && return 3
    declare -n ___ref=$___ref_name
    ___ref=()
    return 0
}

function var_array_from_keys() {
    # $1: (NON-associative) array var WITHOUT '$'
    # Remaining args: keys to set in ARG1
    # Will clear and set ARG2+ in ARG1 with empty string as value
    # Similar to pythons dict.fromkeys() except here ARG1 should
    # be an EXISTING (NON-associative) array variable
    # If no keys are provided, ARG1 is not modified
    # keys that are not integers are IGNORED
    # 
    # Returns:
    #   1: If ARG1 is not set
    #   2: If ARG1 is not declared or is not an (NON_associative) array
    #   3: If ARG1 is a (NON-associative) array, but is readonly
    #   0: Otherwise (success)
    [[ $# -lt 1 ]] && return 1
    local ___ref_name=$1
    shift
    # No keys provided
    [[ $# -lt 1 ]] && return 0

    var_array_clear "$___ref_name" || return $?
    declare -n ___ref=$___ref_name
    for ___key in $@
    do
        ___ref["$___key"]=""
    done
    return 0
}

function var_map_elem() {
    # $1: associative array var WITHOUT '$'
    # $2: key
    # echoes (to stdout): value if found; nothing otherwise
    # Returns: what var_map_has_elem returns
    local ret=0
    var_map_has_elem $@ || ret=$?
    if [[ $ret -ne 0 ]]; then
        return $ret
    fi
    declare -n ___ref=$1
    echo ${___ref["$2"]}
    return 0
}

function var_map_clear() {
    # $1: associative array var WITHOUT '$'
    # Will CLEAR the associative array ARG1
    # If ARG1 is not declared or is not an associative array, does nothing
    # Returns:
    #   1: If ARG1 is not set
    #   2: If ARG1 is not declared or is not an associative array
    #   3: If ARG1 is an associative array, but is readonly
    #   0: Otherwise (success)
    #
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first
    [[ $# -lt 1 ]] && return 1
    local ___ref_name=$(var_deref "$1") || return 2
    var_is_map ___ref_name || return 2
    var_is_readonly ___ref_name && return 3
    declare -n ___ref=$___ref_name

    for ___key in "${!___ref[@]}"
    do
        unset ___ref["$___key"]
    done
}

function var_map_from_keys() {
    # $1: associative array var WITHOUT '$'
    # Remaining args: keys to set in ARG1
    # Will clear and set ARG2+ in ARG1 with empty string as value
    # Similar to pythons dict.fromkeys() except here ARG1 should
    # be an EXISTING associative array variable
    # If no keys are provided, ARG1 is not modified
    # 
    # Returns:
    #   1: If ARG1 is not set
    #   2: If ARG1 is not declared or is not an associative array
    #   3: If ARG1 is an associative array, but is readonly
    #   0: Otherwise (success)
    [[ $# -lt 1 ]] && return 1
    local ___ref_name=$1
    shift
    # No keys provided
    [[ $# -lt 1 ]] && return 0

    var_map_clear "$___ref_name" || return $?
    declare -n ___ref=$___ref_name
    for ___key in $@
    do
        var_value_int "$___key" || continue
        ___ref["$___key"]=""
    done
    return 0
}

function var_map_update_from_map() {
    # $1: associative array var WITHOUT '$' - TO BE UPDATED
    # $2: associative array var WITHOUT '$' - SOURCE map
    # $3: (optional) - if set to 'noclobber', will only ADD
    #     keys to ARG1 but will NOT update existing keys in ARG1
    #
    # Will update ARG1 from ARG2
    #
    # Returns:
    #   0: If ARG1 and ARG2 were found to be associative arrays
    #      and ARG1 was not readonly
    #   1: ARG1 or ARG2 not set
    #   2: If ARG1 and ARG2 were found to be associative arrays
    #      and ARG1 was readonly - no update done
    #   3: ARG1 is not declared
    #   4: ARG2 is not declared
    #   5: ARG1 is not an associative array
    #   6: ARG2 is not an associative array
    #
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first

    [[ $# -lt 2 ]] && return 1
    local DEST=$(var_deref "$1") || return 3
    local SRC=$(var_deref "$1") || return 4
    var_is_map DEST || return 5
    var_is_map SRC || return 6
    var_is_readonly DEST && return 2

    declare -n DEST=${DEST}
    declare -n SRC=${SRC}
    local NOCLOBBER=""
    if [[ $# -gt 2 ]]; then
        if [[ "$3" = "noclobber" ]]; then
            NOCLOBBER="noclobber"
        fi
    fi
    for ___key in "${!SRC[@]}"
    do
        # no-clobber check
        local ret=0
        var_map_has_elem DEST "$___key" || ret=1
        if [[ $ret -eq 0 ]]; then
            if [[ "$NOCLOBBER" ]]; then
                continue
            fi
        fi
        DEST["$___key"]=${SRC["$___key"]}
    done
    return 0
}

function var_map_update_from_env() {
    # $1: associative array var WITHOUT '$' - TO BE UPDATED
    # $2: associative array var WITHOUT '$' - SOURCE map
    # $3: (optional) - if set to 'noclobber', will only ADD
    #     keys to ARG1 but will NOT update existing keys in ARG1
    #
    # Will update ARG1 from ARG2
    # ARG2 is assumed to be of the form:
    #   key-->name of environment variable - WITHOUT $
    #   value-->key in ARG1 to add / update
    # For each KEY in ARG2
    #   IFF key is found in environment
    #       ARG2[KEY} is set to value of $KEY in environment
    #       following 'noclobber' argument if set
    # KEYs in ARG2 that are NOT found in the environment are IGNORED
    # KEYs in ARG2 with an EMPTY string value are assumed to have
    #   value equal to the KEY
    #
    # Returns:
    #   0: If ARG1 and ARG2 were found to be associative arrays
    #      and ARG1 was not readonly
    #   1: ARG1 or ARG2 not set
    #   2: If ARG1 and ARG2 were found to be associative arrays
    #      and ARG1 was readonly - no update done
    #   3: ARG1 is not declared
    #   4: ARG2 is not declared
    #   5: ARG1 is not an associative array
    #   6: ARG2 is not an associative array
    #
    # Other than in var_declared, var_type, var_is_ref and var_deref always dereference first

    [[ $# -lt 2 ]] && return 1
    local DEST=$(var_deref "$1") || return 3
    local SRC=$(var_deref "$1") || return 4
    var_is_map DEST || return 5
    var_is_map SRC || return 6
    var_is_readonly DEST && return 2

    declare -n DEST=${DEST}
    declare -n SRC=${SRC}
    local NOCLOBBER=""
    if [[ $# -gt 2 ]]; then
        if [[ "$3" = "noclobber" ]]; then
            NOCLOBBER="noclobber"
        fi
    fi
    for ___key in "${!SRC[@]}"
    do
        local ___val=${SRC["$___key"]}
        [[ -z "$___val" ]] && ___val="$___key"

        # no-clobber check
        local ret=0
        var_map_has_elem DEST "$___val" || ret=1
        if [[ $ret -eq 0 ]]; then
            if [[ "$NOCLOBBER" ]]; then
                continue
            fi
        fi

        # Get value of ___key from environment if found
        var_declared "$___key" || continue
        var_is_nonarray "$___key" || continue
        local ___env_val=${!___key}
        DEST["$___val"]="$___env_val"
    done
    return 0
}

function var_max_len() {
    # $@: variable names WITHOUT '$'
    # echoes (to stdout): max length
    [[ $# -lt 1 ]] && return 0
    declare -i m=0
    for v in $@
    do
        x=$(var_len $v)
        if [[ $x -gt $m ]]; then
            m=$x
        fi
    done
    echo $m
}

function var_show_vars() {
    # $@: variable names WITHOUT '$' - non-array vars only
    # echoes var names and values to stdout
    [[ $# -lt 1 ]] && return;
    local ___VARLIST=
    for v in $@
    do
        var_is_nonarray $v || continue
        ___VARLIST="$___VARLIST $v"
    done
    declare -i ___MAXLEN=$(echo $___VARLIST | sed -e 's/[[:space:]][[:space:]]*/\n/g' | wc -L)
    local fmt=
    printf -v fmt "%%-%ds : %%s\\n" "$___MAXLEN"
    for v in $___VARLIST
    do
        printf "$fmt" "$v" "${!v}"
    done
}


___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
