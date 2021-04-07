#!/bin/bash
# Removes existing grub modules and EFI image file
# 03_update_grub_efi.sh will then recreate all of them

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)

SCRIPT_DIR=${PROG_DIR}

# All changes happen in GRUB_DIR
GRUB_DIR=${ISO_EXTRACT_DIR}/boot/grub

# original image filename as it is in the ISO
# JUST the filename - without full path
OLD_IMG_FILE=efi.img

if [ -f $GRUB_DIR/$OLD_IMG_FILE ]; then
    echo "Removing old image file: $GRUB_DIR/$OLD_IMG_FILE"
    \rm -f $GRUB_DIR/$OLD_IMG_FILE
fi

# Do not remove oldgrub module dirs
exit 0

for d in x86_64-efi i386-efi
do
    if [ -d $GRUB_DIR/$d ]; then
        echo "Removing grub module dir: $GRUB_DIR/$d"
        \rm -rf $GRUB_DIR/$d
    fi
done
