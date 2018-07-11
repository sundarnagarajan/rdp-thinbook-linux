#!/bin/bash
# ------------------------------------------------------------------------
# This script removes the cherrytux PPA source definition from under
# /etc/apt/sources.list.d
# Removal is done ONLY IF:
# - The original sources file is in the same dir as this script
# - AND the sources file under /etc/sources.list.d is identical
#   to the original sources file
#
# It also removes the cherrytux PPA public key from the list of keys
# trusted by apt
# ------------------------------------------------------------------------
if [ -n "$BASH_SOURCE" ]; then
      PROG_PATH=${PROG_PATH:-$(readlink -e $BASH_SOURCE)}
  else
      PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
  fi
  PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
  PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SOURCES_FILENAME=001-cherrytux-ppa.list

# Delete trusted key
apt-key del ABF7C302A5B662BDE68E0EFE883F04480A577E61

if [ ! -f ${PROG_DIR}/${SOURCES_FILENAME} ]; then
    echo "Original PPA sources file not found:  ${PROG_DIR}/${SOURCES_FILENAME}"
    exit 1
fi

if [ ! -f /etc/apt/sources.list.d/${SOURCES_FILENAME} ]; then
    echo "File not found: /etc/apt/sources.list.d/${SOURCES_FILENAME}"
    exit 1
fi

diff --brief ${PROG_DIR}/${SOURCES_FILENAME} /etc/apt/sources.list.d/${SOURCES_FILENAME} 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "File has been changed: /etc/apt/sources.list.d/${SOURCES_FILENAME}"
    echo "Will not delete changed file"
    echo "If you are sure you can delete this file manually"
    echo "rm -f /etc/apt/sources.list.d/${SOURCES_FILENAME}"
    exit 1
fi

rm -f /etc/apt/sources.list.d/${SOURCES_FILENAME}
echo "Deleted rm -f /etc/apt/sources.list.d/${SOURCES_FILENAME}"
