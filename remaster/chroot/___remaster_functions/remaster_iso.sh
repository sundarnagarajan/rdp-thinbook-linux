#!/bin/bash
# NEEDS bash (and not sh / ksh / zsh etc)

PROG_DIR=$(dirname "$BASH_SOURCE")
PROG_DIR=$(readlink -e "$PROG_DIR")
# The directory containing generic remastering recpies
GIT_REMASTER_DIR=$PROG_DIR
# The directory ABOVE GIT_REMASTER_DIR (or wherever THIS script is copied / symlinked)
export TOP_DIR=$(readlink -e $(dirname $0))

source "$PROG_DIR"/functions.sh || {
    >&2 echo "Could not source $PROG_DIR/functions.sh"
    exit 1
}

# ------------------------------------------------------------------------
# Main script starts after this
# ------------------------------------------------------------------------

check_host_arch || exit 1

START_TIME=$(date)
export R_DIR=${TOP_DIR}/$GIT_REMASTER_DIR/remaster
export INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
export EXTRACT_DIR=${TOP_DIR}/ISO/extract
export OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso

function cleanup_mounts()
{
    if [ -z "$EXTRACT_DIR" ]; then
        return
    fi
    which findmnt 1>/dev/null 2>&1 || return
    for d in $(findmnt -n -l | grep "$EXTRACT_DIR" | awk '{print $1}' | sort -r)
    do
        echo "Unmounting $d"
        umount $d
    done
    rm -rf "$EXTRACT_DIR"
}

trap cleanup_mounts 1 2 3 15

check_required_pkgs || exit 1
check_avail_disk_space || exit 1
update_from_git || exit 1
copy_linuxutils || true
compile_kernel || exit 1
remaster_iso || exit 1
echo "Start: $START_TIME" ; echo "Ended: $(date)"
