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
# On 18.04 live server ISO initrd is called initrd.gz and not initrd.lz!
# Find each file named vmlinuz* and initrd* and overwrite them if they
# are different from SRC_VMLINUZ and SRC_INITRD respectively

for f in ${ISO_EXTRACT_DIR}/casper/vmlinuz*
do
    SRC_FILE=$SRC_VMLINUZ
    diff --brief $SRC_FILE $f 1>/dev/null
    if [ $? -ne 0 ]; then
        \cp -f $SRC_FILE $f
        echo "replaced $(basename $f)"
    else
        echo "$(basename $f) unchanged - not overwriting"
    fi
done

for f in ${ISO_EXTRACT_DIR}/casper/initrd*
do
    SRC_FILE=$SRC_INITRD
    diff --brief $SRC_FILE $f 1>/dev/null
    if [ $? -ne 0 ]; then
        \cp -f $SRC_FILE $f
        echo "replaced $(basename $f)"
    else
        echo "$(basename $f) unchanged - not overwriting"
    fi
done
