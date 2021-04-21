#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<

#BASHDOC
# ------------------------------------------------------------------------
# Functions related to file descriptors
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

# To OPEN a file named f1 (for reading and writing) and store the file
# descriptor (number) in a variable named 'myfd' use:
#
#   exec {myfd}<>f1
#
# Notes:
#   - Cannot put this in a function
#   - myfd inside curly braces is just variable NAME (without '$')
#   - No spaces between '{myfd}' and '<>'
#   - f1 can be an ordinary file or a named pipe (created with 'mkfifo f1')
#   - f1 will be created (ordinary file) if it doesn't exist
#   - Appending (just) stdout to f1 using $myfd:
#       1>&${myfd} echo "hello"
#       1>&${myfd} cat any_file
#       1>&${myfd} any_command
#   - Appending (just) stderr to f1 using $myfd:
#       2>&${myfd} any_command
#   - Appending stdout AND stderr to f1 using $myfd:
#       >&${myfd} 2>&1 /any/command
#   - Redirect JUST stdout of command to ${myfd}:
#       /any/command 1>&${myfd}
#   - Redirect JUST stderr of command to ${myfd}:
#       /any/command 2>&${myfd}
#
# Stash existing FD in a DIFFERENT fd in stored in a variable
#   exec {copy_out}>&1     # $copy_out is a NUMBER (fd) - what stdout WAS
#   exec {copy_err}>&2     # $copy_err is a NUMBER (fd) - what stderr WAS
#
# Exchange stdout and stderr for a command - can't do this in a function
#   /any/command {copy_out}>&1 1>&2 2>&${copy_out} ; exec {copy_out}>&-
#   Explanation:
#   exec {copy_out}>&1     # $copy_out is a NUMBER (fd) - what stdout WAS
#   exec 1>&2              # stdout now is what stderr WAS
#   exec 2>&${copy_out}    # stderr is now what stdout was ORIGINALLY
#   exec {copy_out}>&-     # close unneeded copy
#
# Closing an open FD:
#   - Close by FD VALUE: (e.g. 10)
#       exec 10>&-         # Cannot parametrize and put in a function
#   - Close using name of variable (myfd) containing FD VALUE:
#       exec {myfd}>&-     # Cannot parametrize and put in a function
#
# Using bash builtin 'read' to read from an FD (value) instead of from stdin
#   read -u $myfd l
#       Reads from FD in $myfd line-by-line and assigns to variable l
#   while read -u $myfd l
#   do
#       echo $l   # do something with each line
#   done
#
# 'exec {var}<>filename' needs bash 4.1+ (2009-12-31) 

function fd_exists() {
    # $1: VALUE of fd (number) - not variable NAME
    # Returns: 0 if it is a valid open FD; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ -e /proc/self/fd/"$1" ]]
}

function fd_dest() {
    # $1: VALUE of fd (number) - not variable NAME
    # echoes (to stdout) file that FD points at
    [[ $# -lt 1 ]] && return 1
    fd_exists "$1" || return 1
    readlink -e /proc/self/fd/$1 1>/dev/null 2>&1
}


___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
