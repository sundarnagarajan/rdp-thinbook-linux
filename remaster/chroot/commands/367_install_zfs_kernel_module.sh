#!/bin/bash
# Depends on 020_set_dns.sh 045_apt_update.sh
#
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
		echo "Not installing ZFS kernel DEBs"
		exit 0
	fi
done


SRC_DEB_DIR=${PROG_DIR}/../zfs-kernel-debs

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

# We need dkms and dkms needs python3-distutils (undeclared ?)
apt install --no-install-recommends --no-install-suggests -y build-essential dkms python3-distutils 1>/dev/null 2>&1
# Stop zsys if it is running
sudo systemctl stop zsysd.service zsysd.socket zsys-commit.service zsys-gc.service zsys-gc.timer 1>/dev/null 2>&1
# Remove zfsutils-linux that conflicts with zfs-dkms
ZFS_REMOVE_PKGS="zsys zfs-zed zfsutils-linux libnvpair3linux libuutil3linux"
echo "Removing packages that conflicts with zfs-dkms: $ZFS_REMOVE_PKGS"
# apt autoremove -y $ZFS_REMOVE_PKGS 1>/dev/null 2>&1
apt autoremove -y $ZFS_REMOVE_PKGS

echo "Installing ZFS kernel DEBs"
# dpkg -i ${SRC_DEB_DIR}/*.deb 1>/dev/null 2>&1
dpkg -i ${SRC_DEB_DIR}/*.deb
if [ $? -ne 0 ]; then
    echo "Install of ZFS kernel DEBs failed"
    exit $FAILED_EXIT_CODE
fi

# postpone update-initramfs to 920_update_initramfs.s

echo "New ZFS kernel packages installed:"
for f in ${SRC_DEB_DIR}/*.deb
do
    dpkg-deb -W --showformat='${Package}\n' "$f" 2>/dev/null
done | sort | sed -e 's/^/    /'
