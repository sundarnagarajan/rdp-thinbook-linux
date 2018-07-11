#!/bin/bash
# This only assumes Ubuntu/Debian naming convention for kernel
# and initrd files. Also assumes Ubuntu-specific location for
# kernel and initrd in ISO (/casper)
# Expects env var REMASTER_ISO_CHROOT_DIR to be set

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)
REMASTER_DIR=/root/remaster
KP_LIST=kernel_pkgs.list

if [ -z "$REMASTER_ISO_CHROOT_DIR" ]; then
    echo "REMASTER_ISO_CHROOT_DIR not set"
    exit 0
fi
if [ ! -d "$REMASTER_ISO_CHROOT_DIR" ]; then
    echo "REMASTER_ISO_CHROOT_DIR not a directory: $REMASTER_ISO_CHROOT_DIR"
    exit 0
fi

cd ${REMASTER_ISO_CHROOT_DIR}/boot/
# Get highest version vmlinuz and initrd
SRC_VMLINUZ=$(ls vmlinuz-*| tail -1)
if [ -z "$SRC_VMLINUZ" ]; then
    echo "No vmlinuz found under $(pwd)"
    exit 0
fi
SRC_VER=$(echo $SRC_VMLINUZ | cut -d- -f2-)
if [ -z "$SRC_VER" ]; then
    echo "vmlinuz did not contain version: $(pwd)/$SRC_VMLINUZ"
    exit 0
fi
SRC_INITRD=initrd.img-${SRC_VER}
if [ ! -f "$SRC_INITRD" ]; then
    echo "initrd not found: $(pwd)/$SRC_INITRD"
    exit 0
fi
echo "Using vmlinuz: $SRC_VMLINUZ"
echo "Using initrd: $SRC_INITRD"

SRC_VMLINUZ="$(pwd)/$SRC_VMLINUZ"
SRC_INITRD="$(pwd)/$SRC_INITRD"
for f in $SRC_VMLINUZ $SRC_INITRD
do
    if [ ! -f "$f" ]; then
        echo "file not found: $f"
        exit 0
    fi
done

# On 18.04 grub.cfg references vmlinuz and not vmlinuz.efi
if [ -f ${ISO_EXTRACT_DIR}/casper/vmlinuz.efi ]; then
    TARGET_VMLINUZ=${ISO_EXTRACT_DIR}/casper/vmlinuz.efi
elif [ -f ${ISO_EXTRACT_DIR}/casper/vmlinuz ]; then
    TARGET_VMLINUZ=${ISO_EXTRACT_DIR}/casper/vmlinuz
else
    echo "Could not find target vmlinuz"
    exit 0
fi
TARGET_INITRD=${ISO_EXTRACT_DIR}/casper/initrd.lz

diff --brief $SRC_VMLINUZ $TARGET_VMLINUZ 1>/dev/null
if [ $? -eq 0 ]; then
    echo "vmlinuz unchanged - not overwriting"
else
    \cp -f $SRC_VMLINUZ $TARGET_VMLINUZ
fi
diff --brief $SRC_INITRD $TARGET_INITRD 1>/dev/null
if [ $? -eq 0 ]; then
    echo "initrd unchanged - not overwriting"
else
    \cp -f $SRC_INITRD $TARGET_INITRD
fi
