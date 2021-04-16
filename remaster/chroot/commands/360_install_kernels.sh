#!/bin/bash
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)
# It also assumes Ubuntu-like initramfs commands / config

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster
FAILED_EXIT_CODE=127


# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs

if [ ! -d ${KERNEL_DEB_DIR} ]; then
    echo "KERNEL_DEB_DIR not a directory: $KERNEL_DEB_DIR"
    exit 0
fi
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)

ls $KERNEL_DEB_DIR/ | grep -q '\.deb$'
if [ $? -ne 0 ]; then
    echo "No deb files in $KERNEL_DEB_DIR"
    exit 0
fi
KP_LIST=kernel_pkgs.list
KP_LIST=${KERNEL_DEB_DIR}/$KP_LIST

if [ -x /etc/grub.d/30_os-prober ]; then
    chmod -x /etc/grub.d/30_os-prober
fi
dpkg -i ${KERNEL_DEB_DIR}/*.deb 2>/dev/null 1>/dev/null
if [ $? -ne 0 ]; then
    echo "Install of kernel DEBs failed"
    exit $FAILED_EXIT_CODE
fi
# postpone update-initramfs to 920_update_initramfs.sh

\cp -f /dev/null ${KP_LIST}
for f in ${KERNEL_DEB_DIR}/*.deb
do
    dpkg-deb -f $f Package >> ${KP_LIST}
done
if [ -f ${KP_LIST} ]; then
    echo "New kernel packages installed:"
    cat ${KP_LIST} | sed -u -e 's/^/    /'
    mkdir -p $REMASTER_DIR
    cp ${KP_LIST} ${REMASTER_DIR}/
else
    exit 0
fi
