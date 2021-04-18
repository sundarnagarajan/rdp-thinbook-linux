#!/bin/bash
# update pci and USB IDs
# Requires 020_set_dns.sh and 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster
ALTERNATE_SCRIPT_DIR="${PROG_DIR}"/../update_pci_usb_ids
ALTERNATE_SCRIPT_DIR=$(readlink -m "$ALTERNATE_SCRIPT_DIR")
ALTERNATE_INSTALL_DIR=${REMASTER_DIR}/update_pci_usb_ids


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
    update-pciids -q && echo "Updated PCI IDs"
} || {
    echo "update-pciids not found"
    [[ -f "$ALTERNATE_SCRIPT_DIR"/update-pciids ]] && {
        mkdir -p $ALTERNATE_INSTALL_DIR && \cp -f "$ALTERNATE_SCRIPT_DIR"/update-pciids ${ALTERNATE_INSTALL_DIR}/ && {
            echo "Installed $ALTERNATE_SCRIPT_DIR/update-pciids"
            "$ALTERNATE_SCRIPT_DIR"/update-pciids -q && echo "Updated PCI IDs"
        } || echo "Could not install $ALTERNATE_SCRIPT_DIR/update-pciids"
    } || echo "File not found: $ALTERNATE_SCRIPT_DIR/update-pciids"
}
which update-usbids 1>/dev/null 2>&1 && {
    update-usbids -q && echo "Updated USB IDs"
} || {
    echo "update-usbids not found"
    [[ -f "$ALTERNATE_SCRIPT_DIR"/update-usbids ]] && {
        mkdir -p $ALTERNATE_INSTALL_DIR && \cp -f "$ALTERNATE_SCRIPT_DIR"/update-usbids ${ALTERNATE_INSTALL_DIR}/ && {
            echo "Installed $ALTERNATE_SCRIPT_DIR/update-usbids"
            "$ALTERNATE_SCRIPT_DIR"/update-usbids -q && echo "Updated USB IDs"
        } || echo "Could not install $ALTERNATE_SCRIPT_DIR/update-usbids"
    } || echo "File not found: $ALTERNATE_SCRIPT_DIR/update-usbids"
}
