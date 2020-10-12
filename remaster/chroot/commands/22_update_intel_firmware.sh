#!/bin/bash
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

INTEL_FIRMWARE_GIT='git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/linux-firmware.git'

ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

apt-get update 1>/dev/null
apt-get -y install git 1>/dev/null
if [ $? -ne 0 ]; then
    echo "Install failed: git"
    exit 1
fi

# Intel firmware git
git clone --quiet --depth 1 $INTEL_FIRMWARE_GIT intel-firmware 2>&1
rm -rf intel-firmware/.git

# Copy (ONLY) additional firmware file from intel-firmware to firmware
# In particular only iwlwifi-*.ucode and intel/*
cd intel-firmware
( find -maxdepth 1 -name 'iwlwifi-*.ucode'; find -mindepth 2 -path './intel/*' ) | while read fn; do if [ ! -e /lib/firmware/$fn ]; then cp -v --parents $fn $(dirname /lib/firmware/$fn); fi; done ; cd - 1>/dev/null 2>&1
rm -rf intel-firmware

apt-get autoremove -y --purge git 1>/dev/null 2>/dev/null

# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi
