#!/bin/bash
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)
# It also assumes Ubuntu-like initramfs commands / config

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster

KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs

if [ ! -d "${KERNEL_DEB_DIR}" ]; then
    echo "KERNEL_DEB_DIR not a directory: $KERNEL_DEB_DIR"
    exit 0
fi
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)

ls "$KERNEL_DEB_DIR/" | grep -q '\.deb$'
if [ $? -ne 0 ]; then
    echo "No deb files in $KERNEL_DEB_DIR"
    exit 0
fi

DEST_DIR=/root/$(basename "$KERNEL_DEB_DIR")
mkdir -p "$DEST_DIR"
cp -rv "$KERNEL_DEB_DIR"/*.deb "$DEST_DIR"/
exit 0
