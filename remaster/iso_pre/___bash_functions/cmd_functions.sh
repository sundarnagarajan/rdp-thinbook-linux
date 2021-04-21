#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# ------------------------------------------------------------------------
# Functions related to commands
# Depends (only) on ___minimal_functions.sh
# Does not use or call any external commands or sub-shells
# bash-specific and may need bash version 4
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


# Run any command including shell function, ignoring non-zero return
function cmd_ignore_error() {
    local ret=0
    $@ || ret=$?
    return 0
}

function cmd_catch_stdout_stderr() {
{
    # Run an arbitrary command (or shell function) and capture
    # STDOUT and STDERR in SEPARATE variables
    #
    # From: https://stackoverflow.com/a/41069638
    # $1: Name of variable to hold stdout - WITHOUT '$'
    # $2: Name of variable to hold stderr - WITHOUT '$'
    # $3: command
    # $4+: command args
    [[ $# -lt 4 ]] && return 1
    eval "$({
    __2="$(
      { __1="$("${@:3}")"; } 2>&1;
      ret=$?;
      printf '%q=%q\n' "$1" "$__1" >&2;
      exit $ret
      )"
    local ___ret="$?";
    printf '%s=%q\n' "$2" "$__2" >&2;
    printf '( exit %q )' "$___ret" >&2;
    } 2>&1 )";
    }
}


function cmd_find_python() {
    # $1: python code to try - should exit successfully if it works
    # Typically put all your imports (only) in $1
    # Outputs (stdout): command that can be used with 'env <command>'
    # to run python if python was found AND executed ARG1 successfully
    # Returns:
    #   0: If some python was found that executed ARG1 successfully
    #   1: ARG1 not provided
    #   2: No python candidate was found
    #   
    [[ $# -lt 1 ]] && return 1
    var_declared ___PY_CMD && [[ -n "$___PY_CMD" ]] && return 0
    local CMD_LIST="python3 python python2"
    var_declared ___PY_CMD_LIST && [[ -n "$___PY_CMD_LIST" ]] && CMD_LIST=$___PY_CMD_LIST
    for PY_CMD in $CMD_LIST
    do
        local ret=0
        env $PY_CMD -c "$CHECK_PYTHON_CODE" 1>/dev/null 2>&1 || ret=$?
        if [[ $ret -eq 0 ]]; then
            echo "$PY_CMD"
            return 0
        fi
    done
    return 2
}


___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
