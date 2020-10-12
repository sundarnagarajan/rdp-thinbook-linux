#!/bin/bash

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster

ZFS_PKGS=$(dpkg -l | grep zfs | awk '{print $2}' | tr '\n' ' ')
if [ -n "$ZFS_PKGS" ]; then
    echo "Removing packages: $ZFS_PKGS"
    apt autoremove --purge -y $ZFS_PKGS 1>/dev/null 2>&1
else
    echo "No ZFS packages to remove"
fi
