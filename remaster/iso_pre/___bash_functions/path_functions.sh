#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<


#BASHDOC
# ------------------------------------------------------------------------
# Functions related to paths, filesystems, mounts
# bash-specific and may need bash version 4
# Packages: coreutils, util-linux, sed, mawk, grep
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


function path_filesize()
{
    # $1: filename
    # echoes (to stdout) size in bytes of file specified as first argument
    # Returns 0 if successful, 1 otherwise
    # Packages: coreutils (stat)
    local ret=0
    local x=$(stat --printf "%s\n" $1 2>/dev/null || ret=$?)
    if [[ $ret -eq 0 ]]; then
        echo "$x"
    fi
    return $ret
}

function path_is_mounted()
{
    # $1: device specified as /dev/abc
    # will check if device is mounted (anywhere)
    # Returns: 0 if mounted, 1 otherwise
    # Packages: util-linux(findmnt)
    [[ $# -lt 1 ]] && return 1
    findmnt --noheadings --source "$1" 1>/dev/null 2>&1
}

function path_is_mounted_here()
{
    # $1: device specified as /dev/abc
    # $2: mount point to check for
    # Returns: 0 if mounted, 1 otherwise
    # Packages: util-linux(findmnt)
    [[ $# -lt 2 ]] && return 1
    findmnt --noheadings --source "$1" --target "$2" 1>/dev/null 2>&1
}

function path_whats_mounted_here() {
    # $1: mount point to check for
    # echoes (to stdout) device mounted at $1
    # Returns 0 if successful, 1 otherwise
    # Packages: util-linux(findmnt)
    [[ $# -lt 1 ]] && return 1
    local ret=0
    local x=$(findmnt --noheadings -o SOURCE --raw --target "$1" || ret=1)
    if [[ $ret -eq 0 ]]; then
        echo "$x"
    fi
    return $ret
}

function path_is_block_dev()
{
    # $1: device specified as /dev/abc
    # Returns: 0 if $1 is a block dev, 1 otherwise
    # checks whether a device is a known block dev (in /proc/partitions)
    # Packages: sed(sed), mawk(awk), grep(grep), coreutils(cat, basename)
    cat /proc/partitions | sed -e '1,2d' | awk '{print $4}' | grep -qFx `basename $1`
    return $?
}

function path_disk_list() {
    # echoes (to stdout) list of disk device paths
    # Will include CDROM devices even if there is no disc
    # Returns: return code of lsblk
    # Packages util-linux(lsblk), sed(sed)
    lsblk --noheadings --nodeps --exclude 1,7 -o KNAME | sed -e 's/^/\/dev\//'
}

function path_is_disk() {
    # $1: device specified as /dev/abc
    # Returns: 0 if $1 is a disk, 1 otherwise
    # Uses output of path_disk_list
    # Packages util-linux(lsblk), grep(fgrep), sed(sed)
    [[ $# -lt 1 ]] && return 1
    path_disk_list | fgrep -qx "$1"
}

function path_is_partition() {
    # $1: device specified as /dev/abc
    # Returns: 0 if $1 is a partition, 1 otherwise
    # Packages coreutils(basename)
    [[ $# -lt 1 ]] && return 1
    local bn=$(basename "$1")
    find -L /sys/block -mindepth 2 -maxdepth 2 -name "$bn"  -exec basename {} \; | fgrep -qx "$bn"
}

function path_show_disks() {
    # echoes disk details on stdout
    # Packages util-linux(lsblk)
    lsblk --nodeps --exclude 1,7 -o KNAME,TRAN,ROTA,SIZE,VENDOR,MODEL,SERIAL,REV
}

function path_show_mounts() {
    # $1: if 'showsnap', mounts on /snap are also shown (hidden by default)
    # echoes details of mounts to stdout
    # Packages util-linux(lsblk)

    if [[ $# -ge 1 ]]; then
        if [[ "$1" = "showsnap" ]]; then
            lsblk --list -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL | awk '$3 != "" && $4 != "" {print}'
            return
        fi
    fi
    lsblk --list -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL | awk '$3 != "" && $4 != "" && $4 !~ /^\/snap\// {print}' 
}

function path_check_avail_disk_space() {
    # $1: required space in bytes
    # $2: directory - defaults to .
    # Returns: 0 if enough space available, 1 otherwise
    local REQD_SPACE_BYTES=$1
    local check_dir=${2:-.}

    local AVAIL_SPACE_BYTES=$(df -B1 --output=avail "${check_dir}" | sed -e '1d')
    >&2 printf "Required space : %18d\n" $REQD_SPACE_BYTES
    >&2 printf "Available space: %18d\n" $AVAIL_SPACE_BYTES
    if [[ $AVAIL_SPACE_BYTES -lt $REQD_SPACE_BYTES ]]; then
        >&2 echo "You do not have enough disk space"
        return 1
    fi
    return 0
}

___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
