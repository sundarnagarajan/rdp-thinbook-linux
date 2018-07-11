#!/bin/bash
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

LINUX_FIRMWARE_GIT='git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git'
# On Ubuntu 17.10 systemd provides the system-wide DNS resolver
# On such distributions, /etc/resolv.conf inside the ISO points
# at ../run/systemd/resolve/stub-resolv.conf and the target will not
# exist IFF you are remastering on an older distribution

# We detect that there is no nameserver line in /etc/resolv.conf
# and if so, we move the existing /etc/resolv.conf aside and 
# replace it with a file pointing at Google Public DNS
# At the end of the script we restore the original /etc/resolv.conf


ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

apt-get update 1>/dev/null
# Fetch the latest firmware from linux firmware git instead
apt-get -y install git 1>/dev/null
if [ $? -ne 0 ]; then
	apt-get -f install
fi

cd /lib
rm -rf firmware
git clone --depth 1 $LINUX_FIRMWARE_GIT firmware
rm -rf firmware/.git
apt-get autoremove -y --purge git 1>/dev/null 2>/dev/null
# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi


# Rest was used earlier to copy RTL8723bs firmware - not needed any more
# if we get latest linux firmware
exit 0

FIRMWARE_SRC_DIR=${PROG_DIR}/../firmware
FIRMWARE_DEST_DIR=/lib/firmware

if [ ! -d ${FIRMWARE_SRC_DIR} ]; then
    echo "FIRMWARE_SRC_DIR not a directory: $FIRMWARE_SRC_DIR"
    exit 0
fi
FIRMWARE_SRC_DIR=$(readlink -e $FIRMWARE_SRC_DIR)
test "$(ls -A $FIRMWARE_SRC_DIR)"
if [ $? -ne 0 ]; then
    echo "No firmware files to copy: $FIRMWARE_SRC_DIR"
    exit 0
fi

cp -r ${FIRMWARE_SRC_DIR}/. $FIRMWARE_DEST_DIR/
