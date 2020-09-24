#!/bin/bash
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)

# This script is a bit Ubuntu-specific
# Specifically, the names of kernel packages are Ubuntu-specific
# In Ubuntu (and Ubuntu flavours and derivatives), we look for:
# linux-image* linux-headers* linux-signed-image-generic linux-generic
# This may be different in other Debian distros

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs

if [ ! -d ${KERNEL_DEB_DIR} ]; then
    echo "KERNEL_DEB_DIR not a directory: $KERNEL_DEB_DIR"
    exit 0
fi
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)
KP_LIST=${KERNEL_DEB_DIR}/kernel_pkgs.list

if [ ! -f $KP_LIST ]; then
    echo "kernel_pkgs.list not found: $KP_LIST"
    exit 0
fi

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



# First check that all new kernel packages are actually installed
for p in $(cat $KP_LIST | cut -d_ -f1)
do
	# inst=$(dpkg -l $p 2>/dev/null | grep '^ii' | awk '{print $2}' | cut-d: -f1)
    inst=$(filter_installed_pkgs $p)
	if [ "$p" != "$inst" ]; then
		echo "Expected package not installed: $p"
		echo "Not uninstalling anything"
		exit 0
	fi
done

# Remove kernel-related packages EXCEPT those in $KP_LIST
REMOVE_LIST=""
# for p in $(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
for p in $(filter_installed_pkgs 'linux-image*')
do
	fgrep -qx $p $KP_LIST
	if [ $? -ne 0 ]; then
		REMOVE_LIST="$REMOVE_LIST $p"
	fi
done
# for p in $(dpkg -l 'linux-modules-*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
for p in $(filter_installed_pkgs 'linux-modules-*')
do
	fgrep -qx $p $KP_LIST
	if [ $? -ne 0 ]; then
		REMOVE_LIST="$REMOVE_LIST $p"
	fi
done
# for p in $(dpkg -l 'linux-headers*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
for p in $(filter_installed_pkgs 'linux-headers*')
do
	fgrep -qx $p $KP_LIST
	if [ $? -ne 0 ]; then
		REMOVE_LIST="$REMOVE_LIST $p"
	fi
done
# for p in linux-signed-image-generic linux-generic
for p in $(filter_installed_pkgs linux-signed-image-generic linux-generic)
do
	fgrep -qx $p $KP_LIST
	if [ $? -ne 0 ]; then
		REMOVE_LIST="$REMOVE_LIST $p"
	fi
done

if [ -n "$REMOVE_LIST" ]; then
    echo "Removing following packages:"
    for p in $REMOVE_LIST
    do
        echo $p | sed -e 's/^/    /'
    done
    sudo apt-get autoremove -y --purge $REMOVE_LIST 2>/dev/null 1>/dev/null
else
    echo "No kernel packages to remove"
fi

# While we check not to DIRECTLY remove any package in $KP_LIST,
# because we use apt-get autoremove, the autoremove may remove
# things like linux-firmware-image - happens when linux-firmware-image
# we are installing in 01_install_kernels.sh is the SAME as the 
# linux-firmware-image version shipped by the distro
# To deal with this, we RE-CHECK and REINSTALL any debs in
# $KERNEL_DEB_DIR that are no longer installed!

ls ${KERNEL_DEB_DIR}/ | grep -q '\.deb$'
if [ $? -ne 0 ]; then
    echo "No deb files in $KERNEL_DEB_DIR"
else
    REINSTALLED=no
    for f in ${KERNEL_DEB_DIR}/*.deb
    do
        PKG_VER=$(dpkg-deb -W --showformat '${Package}___${Version}\n' $f)
        dpkg-query -W --showformat '${Package}___${Version}\n' 2>/dev/null | fgrep -q "${PKG_VER}"
        if [ $? -ne 0 ]; then
            echo "Reinstalling ${PKG_VER}"
            dpkg -i $f
            REINSTALLED=yes
        fi
    done
    if [ "${REINSTALLED}" = "yes" ]; then
        echo overlay >> /etc/initramfs-tools/modules
        update-initramfs -u 2>/dev/null
    fi
fi

echo "Kernel-related packages remaining:"
filter_installed_pkgs_by_section kernel  | sed -e 's/^/    /'
