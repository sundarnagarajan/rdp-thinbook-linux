#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster


LINUXUTILS_DIR=${PROG_DIR}/../linuxutils
if [ ! -d ${LINUXUTILS_DIR} ]; then
    echo "LINUXUTILS_DIR not a directory: $LINUXUTILS_DIR"
    exit 0
fi
LINUXUTILS_DIR=$(readlink -e $LINUXUTILS_DIR)

\cp -r $LINUXUTILS_DIR ${REMASTER_DIR}/

# Install required packages for linuxutils (show_storage, mostly)

REQUIRED_PKGS="udev coreutils util-linux hddtemp parted lvm2 hdparm nvme-cli lsscsi"

ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

MISSING_PKGS=""
for pkg in $REQUIRED_PKGS
do
    dpkg -l | awk '{print $2}' | fgrep -q -x $pkg
    if [ $? -ne 0 ]; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done
if [ -n "$MISSING_PKGS" ]; then
    echo "Installing $MISSING_PKGS"
    apt-get update 1 > /dev/null 2>&1
    apt-get install -y $MISSING_PKGS 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Install failed: $MISSING_PKGS"
    fi
fi
dpkg -l $REQUIRED_PKGS 2>/dev/null | sed -e '1,5d' | awk '{print $1, $2}' 


# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi
