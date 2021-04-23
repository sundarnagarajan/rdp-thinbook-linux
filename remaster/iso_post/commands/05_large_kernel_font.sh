#!/bin/bash

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

GRUB_CFG="$ISO_EXTRACT_DIR"/boot/grub/grub.cfg
echo "Setting fsck.mode=skip"
sed -i 's/\(^[[:space:]]*linux.* \)---[[:space:]]*$/\1fbcon=font:TER16x32 ---/' $GRUB_CFG
grep '^[[:space:]]*linux.* fbcon=font:TER16x32 ' $GRUB_CFG
