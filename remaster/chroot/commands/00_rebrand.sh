#!/bin/bash
# Rebrand distro (/etc/lsb-release, /etc/os-release etc)

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SCRIPTS_DIR=${PROG_DIR}/../rebrand

if [ ! -d ${SCRIPTS_DIR} ]; then
    echo "SCRIPTS_DIR not a directory: $SCRIPTS_DIR"
    exit 0
fi
SCRIPTS_DIR=$(readlink -e $SCRIPTS_DIR)
INSTALL_SCRIPT=/root/rebrand/rebrand.py

mkdir -p /root
cp -r ${SCRIPTS_DIR} /root/

if [ ! -x ${INSTALL_SCRIPT} ]; then
    echo "Not found or not executable: ${INSTALL_SCRIPT}"
    exit 0
fi

python $INSTALL_SCRIPT
