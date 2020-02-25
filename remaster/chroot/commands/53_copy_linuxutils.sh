#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster


LINUXUTILS_DIR=${PROG_DIR}/../linuxutils
if [ ! -d ${LINUXUTILS_DIR} ]; then
    echo "LINUXUTILS_DIR not a directory: $LINUXUTILS_DIR"
    exit 0
fi
LINUXUTILS_DIR=$(readlink -e $LINUXUTILS_DIR)

\cp -r $LINUXUTILS_DIR ${REMASTER_DIR}/
