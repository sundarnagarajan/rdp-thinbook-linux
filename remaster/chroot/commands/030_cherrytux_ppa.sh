#!/bin/bash
# ------------------------------------------------------------------------
# Adds and trusts cherrytux PPA public key and sources.list.d file
# ------------------------------------------------------------------------

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster
PPASCRIPTS_DIR_NAME=cherrytux_ppa
PPA_SCRIPTS_DIR=${PROG_DIR}/../$PPASCRIPTS_DIR_NAME
SOURCES_FILENAME=001-cherrytux-ppa.list
INSTALL_SCRIPT_FILENAME=install_ppa.sh


if [ ! -d ${PPA_SCRIPTS_DIR} ]; then
    echo "PPA_SCRIPTS_DIR not a directory: $PPA_SCRIPTS_DIR"
    exit 0
fi
PPA_SCRIPTS_DIR=$(readlink -e $PPA_SCRIPTS_DIR)
test "$(ls -A $PPA_SCRIPTS_DIR)"
if [ $? -ne 0 ]; then
    echo "No files to copy: $PPA_SCRIPTS_DIR"
    exit 0
fi

mkdir -p /root
cp -r ${PPA_SCRIPTS_DIR} /root/

if [ ! -f /root/$PPASCRIPTS_DIR_NAME/$SOURCES_FILENAME ]; then
    echo "Sources file not found: /root/$PPASCRIPTS_DIR_NAME/$SOURCES_FILENAME"
    exit 0
fi
if [ ! -x /root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME ]; then
    echo "Install script not found: /root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME"
    exit 1
fi

# Install the PPA sources file and add trusted key
/root/$PPASCRIPTS_DIR_NAME/$INSTALL_SCRIPT_FILENAME || exit 0
