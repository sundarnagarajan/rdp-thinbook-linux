#!/bin/bash
# update pci and USB IDs

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

MISSING_PKGS=""
for pkg in pciutils usbutils
do
    dpkg -l | awk '{print $2}' | fgrep -q -x $pkg
    if [ $? -ne 0 ]; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done
if [ -n "$MISSING_PKGS" ]; then
    apt-get update 1 > /dev/null 2>&1
    for pkg in $MISSING_PKGS
    do
        echo "Installing $pkg"
        apt-get install $pkg 1>/dev/null 2>&1
    done
fi

which update-pciids 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Updating PCI IDs"
    update-pciids -q
fi
which update-usbids 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Updating USB IDs"
    update-usbids -q
fi

# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi
