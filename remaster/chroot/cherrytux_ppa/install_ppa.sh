#!/bin/bash
# ------------------------------------------------------------------------
# This script installs the PPA source definition file in this directory
# under /etc/apt/sources.list.d
# It will NOT overwrite an existing file with the same name.
# This script also adds the cherrytux PPA public key as a trusted key
# for apt
#
# Also see uninstall_ppa.sh in the same directory
# ------------------------------------------------------------------------
if [ -n "$BASH_SOURCE" ]; then
      PROG_PATH=${PROG_PATH:-$(readlink -e $BASH_SOURCE)}
  else
      PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
  fi
  PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
  PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SOURCES_FILENAME=001-cherrytux-ppa.list

if [ ! -f ${PROG_DIR}/${SOURCES_FILENAME} ]; then
    echo "PPA sources file not found:  ${PROG_DIR}/${SOURCES_FILENAME}"
    exit 1
fi

if [ -f /etc/apt/sources.list.d/${SOURCES_FILENAME} ]; then
    echo "Not overwriting existing file: /etc/apt/sources.list.d/${SOURCES_FILENAME}"
else
    cp ${PROG_DIR}/${SOURCES_FILENAME} /etc/apt/sources.list.d/${SOURCES_FILENAME}
fi
# Add trusted key
apt-key --keyring /etc/apt/trusted.gpg.d/ppa.gpg adv --recv-keys --keyserver keyserver.ubuntu.com ABF7C302A5B662BDE68E0EFE883F04480A577E61 2>/dev/null
