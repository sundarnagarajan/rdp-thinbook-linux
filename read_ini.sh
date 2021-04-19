#!/bin/bash
# NEEDS bash (and not sh / zsh / ksh )
#
# Read an INI file and output declare statements that can be safely
# 'eval'-ed in bash to set bash variables
#
# Usage:
#   eval "$(read_ini.sh [options] <path/to/ini_file>"
# Run read_ini.sh --help to see options and info on INI file
#

PROG_NAME=$(basename $0)
PROG_DIR=$(dirname $(readlink -e "$BASH_SOURCE"))
source "$PROG_DIR"/ini_functions.sh || {
    >&2 echo "Could not source: ${PROG_DIR}/ini_functions.sh"
    exit 1
}
ini_process_cmdline $@
exit $?
