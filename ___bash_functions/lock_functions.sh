#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# ------------------------------------------------------------------------
# Functions related to locking a file (exclusive lock)
# Needs package util-linux(flock), coreutils(md5sum)
# bash-specific and may need bash version 4
#
# ------------------------------------------------------------------------
# Using these functions to protect a critical region:
#
# Assuming a program wants to obtain TWO locks
# saving lock filenames in variables LFN1 and LFN2
# and lock file FDs in variables LFD1 and LFD2
#
# # Create first lock file and FD
# lock_create LFN1; exec {LFD1}<>${LFN1}
# # This HAS to be in global section of your program - NOT in a function
# # If you don't want to USE variable LFN1, you can unset it
# # You NEED the FD (LFD1) to get or release a lock
#
# # Lock a critical region using LFD1
# lock_get $LFD1 || (ret=$?; echo "lock_get failed: $ret"; exit $ret)
#
# # ...
# # Do stuff in critical region holding LFD1
# # ...
#
# # Create second lock file and FD
# lock_create LFN2 "second"; exec {LFD2}<>${LFN2}
# # Same rules apply as to LFD1 and LFN1
#
# # ...
# # Do stuff in critical region holding LFD1
# # ...
#
# # Lock a critical region using LFD2
# lock_get $LFD2 || (ret=$?; echo "lock_get failed: $ret"; exit $ret)
#
# # ...
# # Do stuff in critical region holding LFD1 AND LFD2
# # ...
#
#
# Release lock on LFD2
# lock_release $LFD2
#
# # ...
# # Do stuff in critical region holding LFD1
# # ...
#
# Release lock on LFD1
# lock_release $LFD1
#
# With multi-process file locking, no process can safely clean up the lock
# file on exit, because the file may still be locked by ONE OR MORE OTHER
# process(es).
# lock_cleanup() function is provided, but it ONLY works predictably when
# file locking is used to prevent multiple instances of a SINGLE program
# - e.g. the way it is used in singleton.sh
#
# # Run lock_cleanup on exit to clean up lock files and lock directory
# trap lock_cleanup EXIT
#
# ------------------------------------------------------------------------
# Locking semantics:
#   - Like ALL file-locking on Linux, it is ADVISORY locking
#   - This means:
#       - Two or more processes using flock will BEHAVE AS IF the lock was
#         'mandatory' - i.e. when a lock is held by one process, it cannot
#         be obtained by another process
#       - When one process has obtained a lock, there is NOTHING to
#         prevent another process from deleting or modifyin the lock file
#         except the fact that both follow the (advisory) locking protocol
#         (using flock)
#       - Lock is automatically released when:
#           - Process holding lock exits
#           - FD is explicitly closed
#
# ------------------------------------------------------------------------
#
# Obtaining a file descriptor opening a file:
#   Open a file /my/path and get the FD into a variable named myfd using:
#     exec 2>/dev/null {myfd}<>/my/path
#   Note No spaces between '{myfd}' and '<>'
#   This CANNOT be done inside a function
#
# Notes:
#   - The file is created if it does not exist
#   - If file does not exist and cannot be cerated, returns 1
#   - If file exists and cannnot be accessed, returns 1
#   - If file exists and can be opened, file contants are not modified
# Closing a file descriptor in variable LFD1
#   exec {LFD1}>&-
#   This CANNOT be put in a function
#
# ------------------------------------------------------------------------
#
# Global variables
#   ___LOCK_CALLER - full path to calling program or basename of calling
#       program - e.g. if used from INETRACTIVE shell

#   ___LOCK_DIR - directory containing automatically created lock files
#
#   ___LOCK_FILES - associative array
#       Set in lock_create
#       Updated in lock_get and lock_release
#       Used and cleaned up in lock_cleanup to clean up automatically
#           created lock files and lock directory (if empty)
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

source_file "${___SRC_DIR}/var_functions.sh"

var_declared ___LOCK_FILES || declare -Ag ___LOCK_FILES
if [[ "$___INTERACTIVE" = "yes" ]]; then
    ___LOCK_CALLER=$(basename $0)
else
    ___LOCK_CALLER=$(readlink -e $0) || ___LOCK_CALLER=$(basename $0)
fi
#readonly ___LOCK_CALLER

function lock_create() {
    # $1: name of variable to set to lock file WITHOUT '$'
    # $2: optional lock file name suffixi
    #     - e.g. if using multiple lock files
    if [[ $# -lt 1 ]]; then
        return 1
    fi
    declare -g $1
    declare -n lock_file_path=$1

    lock_file_path=$(echo $___LOCK_CALLER | md5sum | cut -d' ' -f1)
    if [[ $# -gt 1 ]]; then
        [[ -n "$2" ]] && lock_file_path="${lock_file_path}-${2}"
    fi
    lock_file_path="${___LOCK_DIR}/${lock_file_path}"

    mkdir -p "${___LOCK_DIR}" || return 3
    touch "$lock_file_path" || return 4
    ___LOCK_FILES["$lock_file_path"]='unlocked'
    return 0
}

function lock_get() {
    # $1: file descriptor (number)
    # $2: seconds to wait (seconds) - can be decimal value
    #     If zero, is equivalent to non-blocking
    #     Defaults to 2 seconds
    # Returns: 0 on successful lock; non-zero otherwise
    # Returns 0 if already locked
    [[ $# -lt 1 ]] &&  return 1
    local fd=$1
    local ret=0
    local wait_secs=${2:-2}
    [[ -L /proc/$$/fd/${fd} ]] || return 2
    local lock_file_path=$(readlink -e /proc/$$/fd/${fd}) || return 3

    # Not created by us
    var_map_has_elem ___LOCK_FILES "$lock_file_path" || return 4
    # Already locked
    [[ ___LOCK_FILES["$lock_file_path"] = "locked" ]] && return 0

    flock --exclusive --wait $wait_secs $fd || ret=5
    ___LOCK_FILES["$lock_file_path"]='locked'
    return $ret
}

function lock_release() {
    # $1: file descriptor (number)
    # Returns: 0 always
    [[ $# -lt 1 ]] &&  return 1
    local fd=$1

    [[ -L /proc/$$/fd/${fd} ]] || return 2
    local lock_file_path=$(readlink -e /proc/$$/fd/${fd}) || return 3

    # Not locked by us
    var_map_has_elem ___LOCK_FILES "$lock_file_path" || return 4
    # Not locked
    [[ ${___LOCK_FILES["$lock_file_path"]} = "locked" ]] || return 5

    flock --unlock $fd || return 6
    ___LOCK_FILES["$lock_file_path"]='unlocked'
}

function lock_cleanup() {
    # Clean up all automatically created lock files in $___LOCK_FILES
    for lock_file_path in "${!___LOCK_FILES[@]}"
    do
        local fd=___LOCK_FILES["$lock_file_path"]
        lock_release $fd || true
        unset ___LOCK_FILES["$lock_file_path"]
        \rm -f $lock_file_path 1>/dev/null 2>&1
    done

    # Cleanup lock directory if it is (now) empty
    [[ "$(ls -A "$___LOCK_DIR" 1>/dev/null 2>&1)" ]] || (\rmdir $___LOCK_DIR 1>/dev/null 2>&1 || true)
}

___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced

# Set ___LOCK_DIR after function definitions, so that we can base
# LOCK_DIR on md5sum of the actual function definition code
# ___LOCK_DIR ALWAYS set based on (base)name of ${BASH_SOURCE[0]} or basename of $0
___SRC_MD5=$(declare -fp lock_create lock_get lock_release lock_cleanup | md5sum | cut -d' ' -f1)
___LOCK_DIR=/run/user/${UID}/$(basename ${BASH_SOURCE[0]})-${___SRC_MD5}
unset ___SRC_MD5
#readonly ___LOCK_DIR


# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
