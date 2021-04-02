#!/bin/bash
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)
# It also assumes Ubuntu-like initramfs commands / config

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
FAILED_EXIT_CODE=127
REMASTER_DIR=/root/remaster

KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)
KP_LIST=${KERNEL_DEB_DIR}/kernel_pkgs.list

function filter_installed_pkgs() {
    # Parameters: Package name pattern (if any) - can be multiple package names also
    # Outputs package names on stdout - 1 per line WITHOUT ':$ARCH'
    dpkg-query -W --showformat='${db:Status-Status} ${Section} ${Package}\n' $* 2>/dev/null | awk '$1=="installed" {print $3}'
}

function filter_installed_pkgs_by_section() {
    # $1: section name (optional)
    # Outputs package names on stdout - 1 per line WITHOUT ':$ARCH'
    if [ -z "$1" ]; then
        dpkg-query -W --showformat='${db:Status-Status} ${Package}\n' $* 2>/dev/null | awk '$1=="installed" {print $2}'
    else
        dpkg-query -W --showformat='${db:Status-Status} ${Section} ${Package}\n' 2>/dev/null | awk '$1=="installed" && $2=="kernel" {print $3}'
    fi
}

# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

if [ ! -f $KP_LIST ]; then
    echo "kernel_pkgs.list not found: $KP_LIST"
    exit 0
fi

# First check that all new kernel packages are actually installed
for p in $(cat $KP_LIST | cut -d_ -f1)
do
    inst=$(filter_installed_pkgs $p)
	if [ "$p" != "$inst" ]; then
		echo "Expected package not installed: $p"
		echo "Not installing ZFS userspace DEBs"
		exit 0
	fi
done

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
UNINSTALL_PKGS="libnvpair1linux libuutil1linux libzpool2linux zsys zfs-zed zfsutils-linux"
echo "Removing $UNINSTALL_PKGS"
apt autoremove -y  $UNINSTALL_PKGS 1>/dev/null 2>&1

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
