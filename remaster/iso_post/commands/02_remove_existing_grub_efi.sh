#!/bin/bash
# Removes existing grub modules and EFI image file
# 03_update_grub_efi.sh will then recreate all of them

# ------------------------------------------------------------------------
# The README for xterm said:
#   Abandon All Hope, Ye Who Enter Here
#
# Restrict to setting:
#
#
# Unlike chroot/commands, the scripts in this directory are executed
# OUTSIDE the chroot and AS ROOT! Mistakes in these scripts could make
# unintended changes to your HOST machine environment
#
# 1. Check that ISO_EXTRACT_DIR env var is set and is not empty or '/'
# 2. Identify ALL directories the script uses at the TOP (globals)
# 3. For EACH directory used in the script (globals):
#       a. Check that the variable is set and is not empty and not '/'
#       b. Check that the value starts with $ISO_EXTRACT_DIR
#
# If any of above conditions are not met, bail with exit code 127
# ------------------------------------------------------------------------



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
