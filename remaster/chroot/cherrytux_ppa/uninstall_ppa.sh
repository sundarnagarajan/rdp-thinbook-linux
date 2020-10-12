#!/bin/bash
# ------------------------------------------------------------------------
# This script removes the cherrytux PPA public key from the list of keys
# trusted by apt - once run, apt will never download and install packages
# from the cherrytux PPA
# This script also disabled the cherrytux PPA source definition from under
# /etc/apt/sources.list.d
# Disabling is done ONLY IF:
# - The original sources file is in the same dir as this script
# - AND the sources file under /etc/sources.list.d is identical
#   to the original sources file
#
# ------------------------------------------------------------------------
if [ -n "$BASH_SOURCE" ]; then
      PROG_PATH=${PROG_PATH:-$(readlink -e $BASH_SOURCE)}
  else
      PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
  fi
  PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
  PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SOURCES_FILENAME=001-cherrytux-ppa.list
CHERRYTUX_PPA_GPG_KEYID=ABF7C302A5B662BDE68E0EFE883F04480A577E61

# Delete trusted key
APT_KEY_OUT=$(apt-key list $CHERRYTUX_PPA_GPG_KEYID 2>/dev/null)
if [ -n "$APT_KEY_OUT" ]; then
    apt-key del $CHERRYTUX_PPA_GPG_KEYID 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Untrusted Cherrytux PPA GPG Key $CHERRYTUX_PPA_GPG_KEYID"
    else
        echo "Failed to untrust Cherrytux PPA GPG Key $CHERRYTUX_PPA_GPG_KEYID"
    fi
else
    echo "Cherrytux PPA GPG Key $CHERRYTUX_PPA_GPG_KEYID not trusted already"
fi

# Checks before disabling cherrytux PPA source under /etc/apt/sources.list.d
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
    echo "mv /etc/apt/sources.list.d/${SOURCES_FILENAME} /etc/apt/sources.list.d/${SOURCES_FILENAME}.disabled"
    echo "apt update"
    exit 1
fi

# Disable cherrytux PPA source under /etc/apt/sources.list.d
\mv -nv /etc/apt/sources.list.d/${SOURCES_FILENAME} /etc/apt/sources.list.d/${SOURCES_FILENAME}.disabled 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Disabled /etc/apt/sources.list.d/${SOURCES_FILENAME}"
else
    echo "Could not disable /etc/apt/sources.list.d/${SOURCES_FILENAME}"
    echo "Cherrytux PPA GPG key $CHERRYTUX_PPA_GPG_KEYID should no longer be trusted"
    echo "apt will never download or install packages from Cherrytix PPA"
fi
