#!/bin/bash
# ------------------------------------------------------------------------
# Untrusts cherrytux PPA public key and disables sources.list.d file
# ------------------------------------------------------------------------

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

REMASTER_DIR=/root/remaster
PPASCRIPTS_DIR_NAME=cherrytux_ppa
PPA_SCRIPTS_DIR=${PROG_DIR}/../$PPASCRIPTS_DIR_NAME
UNINSTALL_SCRIPT_FILENAME=uninstall_ppa.sh


if [ ! -d ${PPA_SCRIPTS_DIR} ]; then
    echo "PPA_SCRIPTS_DIR not a directory: $PPA_SCRIPTS_DIR"
    exit 0
fi
PPA_SCRIPTS_DIR=$(readlink -e $PPA_SCRIPTS_DIR)
if [ ! -x /root/$PPASCRIPTS_DIR_NAME/$UNINSTALL_SCRIPT_FILENAME ]; then
    echo "Install script not found: /root/$PPASCRIPTS_DIR_NAME/$UNINSTALL_SCRIPT_FILENAME"
    exit 1
fi

# Untrust Cherrytux PPA GPG key and disable PPA sources file
/root/$PPASCRIPTS_DIR_NAME/$UNINSTALL_SCRIPT_FILENAME || exit 1
