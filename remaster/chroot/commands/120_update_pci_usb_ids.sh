#!/bin/bash
# update pci and USB IDs
# Requires 020_set_dns.sh and 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

MISSING_PKGS=""
for pkg in pciutils usbutils
do
    dpkg -l | awk '{print $2}' | fgrep -q -x $pkg
    if [ $? -ne 0 ]; then
        MISSING_PKGS="$MISSING_PKGS $pkg"
    fi
done
if [ -n "$MISSING_PKGS" ]; then
    echo "Installing $MISSING_PKGS"
    apt-get install --no-install-recommends --no-install-suggests -y $MISSING_PKGS 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Install failed: $MISSING_PKGS"
    fi
fi

which update-pciids 1>/dev/null 2>&1 && {
    echo "Updating PCI IDs"
    update-pciids -q
} || {
    echo "update-pciids not found"
}
which update-usbids 1>/dev/null 2>&1 && {
    echo "Updating USB IDs"
    update-usbids -q
} || {
    echo "update-usbids not found"
}
