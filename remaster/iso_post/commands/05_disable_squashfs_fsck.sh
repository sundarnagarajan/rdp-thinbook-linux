#!/bin/bash

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)

SCRIPT_DIR=${PROG_DIR}

GRUB_CFG="$ISO_EXTRACT_DIR"/boot/grub/grub.cfg
echo "Setting fsck.mode=skip"
sed -i 's/\(^[[:space:]]*linux.* \)---$/\1fsck.mode=skip ---/' $GRUB_CFG
