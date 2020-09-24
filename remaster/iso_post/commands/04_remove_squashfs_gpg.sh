#!/bin/bash

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)

SCRIPT_DIR=${PROG_DIR}

GPG_FILE=${ISO_EXTRACT_DIR}/casper/filesystem.squashfs.gpg
if [ -f "$GPG_FILE" ]; then
    echo "Removing $GPG_FILE"
    \rm -fv "$GPG_FILE"
else
    echo "File not found: $GPG_FILE"
fi
