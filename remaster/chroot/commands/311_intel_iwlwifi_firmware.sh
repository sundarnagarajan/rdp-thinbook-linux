#!/bin/bash
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

# FIRMWARE_GIT='git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-next.git'
FIRMWARE_GIT='git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/linux-firmware.git'
FIRMWARE_DEST_DIR=/lib/intel-firmware

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

# Intel firmware git
echo "Cloning Intel firmware to ${FIRMWARE_DEST_DIR}: $FIRMWARE_GIT"
git clone --quiet --depth 1 "$FIRMWARE_GIT" "$FIRMWARE_DEST_BASENAME" 1>/dev/null 2>&1
rm -rf ${FIRMWARE_DEST_DIR}/.git

# Copy (ONLY) additional firmware file from intel-firmware to firmware
# In particular only iwlwifi-*.ucode and intel/*
cd $FIRMWARE_DEST_DIR
# Comment
( find -maxdepth 1 -type f -name 'iwlwifi-*.ucode'; find -mindepth 2 -type f -path './intel/*' ) | while read fn; do dest=$(dirname /lib/firmware/$fn); if [ ! -e  $dest ]; then mkdir -p $dest; cp -v $fn $dest; fi; done ; cd - 1>/dev/null 2>&1
cd $FIRMWARE_DEST_PARENT_DIR
rm -rf $FIRMWARE_DEST_DIR

# Uninstall git
if [ -z "$GIT_ALREADY_INSTALLED" ]; then
    apt-get autoremove -y --purge git 1>/dev/null 2>/dev/null
fi
