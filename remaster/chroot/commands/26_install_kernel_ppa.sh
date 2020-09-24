#!/bin/bash
# ------------------------------------------------------------------------
# Install kernel from cherrytux PPA
# This script automatically 'integrates' with 11_install_kernels.sh
# If 11_install_kernels.sh ran and created ${KERNEL_DEB_DIR}/$KP_LIST
# AND ${KERNEL_DEB_DIR}/$KP_LIST contains at least one linux-image-* package
# then this script will do nothing
# ------------------------------------------------------------------------

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster
KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)

KP_LIST=kernel_pkgs.list
KP_LIST=${KERNEL_DEB_DIR}/$KP_LIST

PPASCRIPTS_DIR_NAME=cherrytux_ppa
PPA_SCRIPTS_DIR=${PROG_DIR}/../$PPASCRIPTS_DIR_NAME

function unused_initrd_hack() {
    # "Hack" for Ubuntu 20.04 (Focal Fossa)
    # Explicitly /boot/initrd.img using mkinitramfs
    # ASSUME that ${KP_LIST} contains only one package named linux-image-*
    # Else use the HIGHEST version of such package
    if [ ! -f "$KP_LIST" ]; then
        exit 0
    fi
    NEW_INSTALLED_KERN_VER=$(cat ${KP_LIST} | grep '^linux-image-' | sed -e 's/^linux-image-//' | sort -V | head -1 | cut -d_ -f1)
    if [ -n "$NEW_INSTALLED_KERN_VER" ]; then
        echo "Creating initrd.img-${NEW_INSTALLED_KERN_VER} using mkinitramfs"
        mkinitramfs -o /boot/initrd.img-${NEW_INSTALLED_KERN_VER} ${NEW_INSTALLED_KERN_VER} 1>/dev/null 2>&1 || exit 0
    else
        echo "linux-image not found in ${KP_LIST}"
    fi
    exit 0
}

if [ ! -d ${PPA_SCRIPTS_DIR} ]; then
    echo "PPA_SCRIPTS_DIR not a directory: $PPA_SCRIPTS_DIR"
    exit 0
fi
PPA_SCRIPTS_DIR=$(readlink -e $PPA_SCRIPTS_DIR)
test "$(ls -A $PPA_SCRIPTS_DIR)"
if [ $? -ne 0 ]; then
    echo "No files to copy: $PPA_SCRIPTS_DIR"
    exit 0
fi

mkdir -p /root
cp -r ${PPA_SCRIPTS_DIR} /root/

SOURCES_FILENAME=001-cherrytux-ppa.list
INSTALL_SCRIPT_FILENAME=install_ppa.sh


if [ ! -f /root/$PPASCRIPTS_DIR_NAME/$SOURCES_FILENAME ]; then
    echo "Sources file not found: /root/$PPASCRIPTS_DIR_NAME/$SOURCES_FILENAME"
    exit 0
fi
if [ ! -x /root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME ]; then
    echo "Install script not found: /root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME"
    exit 1
fi

ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

# Install the PPA sources file and add trusted key
/root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME || exit 0

if [ -f $KP_LIST -a -s $KP_LIST ]; then
    grep -q '^linux-image' $KP_LIST
    if [ $? -eq 0 ]; then
        echo "Kernels already installed - not using cherrytux PPA"
        echo "cherrytux PPA setup and ready to use"
        exit 0
    fi
fi

apt-get update 1>/dev/null
REQUIRED_PKGS="cherrytux-image cherrytux-headers"
echo "Installing $REQUIRED_PKGS"
apt-get -y install $REQUIRED_PKGS 1>/dev/null
if [ $? -ne 0 ]; then
    echo "Install failed: $REQUIRED_PKGS"
    exit 255
fi
if [ -x /etc/grub.d/30_os-prober ]; then
    chmod -x /etc/grub.d/30_os-prober
fi
echo overlay >> /etc/initramfs-tools/modules
# update-initramfs -u 2>/dev/null
update-initramfs -u -k all

# Add kernel we installed to $KP_LIST
mkdir -p $KERNEL_DEB_DIR
touch $KP_LIST

dpkg -l linux-image-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST
dpkg -l linux-headers-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST

echo "Installed following packages:"
dpkg -l cherrytux-image | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
dpkg -l cherrytux-headers | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
cat $KP_LIST | sed -e 's/^/    /'


# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi
