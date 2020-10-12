#!/bin/bash
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions
# Requires 020_set_dns.sh and 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

FIRMWARE_GIT='git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git'
FIRMWARE_DEST_DIR=/lib/firmware


FIRMWARE_DEST_PARENT_DIR=$(dirname $FIRMWARE_DEST_DIR)
FIRMWARE_DEST_BASENAME=$(basename $FIRMWARE_DEST_DIR)

# Install git if not installed
GIT_ALREADY_INSTALLED=$(dpkg-query -W --showformat='${Package}\n' | fgrep -x git)
if [ -z "$GIT_ALREADY_INSTALLED" ]; then
    apt-get -y install --no-install-recommends --no-install-suggests git 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "Install failed: git"
        exit 1
    fi
fi

# Fetch the latest firmware from Intel iwlwifi firmware git
cd $FIRMWARE_DEST_PARENT_DIR
rm -rf $FIRMWARE_DEST_BASENAME

# linux firmware git
echo "Cloning firmware git: $FIRMWARE_GIT"
git clone --quiet --depth 1 $INTEL_FIRMWARE_GIT $FIRMWARE_DEST_BASENAME 1>/dev/null 2>&1
rm -rf ${FIRMWARE_DEST_BASENAME}/.git

# Uninstall git
if [ -z "$GIT_ALREADY_INSTALLED" ]; then
    apt-get autoremove -y --purge git 1>/dev/null 2>/dev/null
fi
