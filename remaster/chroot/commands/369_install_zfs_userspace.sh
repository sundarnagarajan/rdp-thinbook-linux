#!/bin/bash
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)
# It also assumes Ubuntu-like initramfs commands / config

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
FAILED_EXIT_CODE=127
REMASTER_DIR=/root/remaster


# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

SRC_DEB_DIR=${PROG_DIR}/../zfs-userspace-debs

if [ ! -d ${SRC_DEB_DIR} ]; then
    echo "SRC_DEB_DIR not a directory: $SRC_DEB_DIR"
    exit 0
fi
SRC_DEB_DIR=$(readlink -e $SRC_DEB_DIR)

ls $SRC_DEB_DIR/ | grep -q '\.deb$'
if [ $? -ne 0 ]; then
    echo "No deb files in $SRC_DEB_DIR"
    exit 0
fi

UNINSTALL_PKGS=""
for f in ${SRC_DEB_DIR}/*.deb
do
    UNINSTALL_PKGS="$UNINSTALL_PKGS $(dpkg-deb -W --showformat='${Package}' $f)"
done
if [ -n "$UNINSTALL_PKGS" ]; then
    apt autoremove -y $UNINSTALL_PKGS 1>/dev/null 2>&1
else
    echo "No packages to remove"
fi
# Remove packages with 'alternative' names that get in the way
apt autoremove -y libnvpair1linux libuutil1linux libzpool2linux 1>/dev/null 2>&1

dpkg -i ${SRC_DEB_DIR}/*.deb 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Install of ZFS userspace DEBs failed"
    exit $FAILED_EXIT_CODE
fi
# postpone update-initramfs to 920_update_initramfs.s

echo "New ZFS userspace packages installed:"
for f in ${SRC_DEB_DIR}/*.deb
do
    dpkg-deb -W --showformat='${Package}\n' "$f" 2>/dev/null
done | sort | sed -e 's/^/    /'
