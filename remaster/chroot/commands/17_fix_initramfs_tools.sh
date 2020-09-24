#!/bin/bash
# Fix COMPRESS setting in /etc/initramfs-tools/initramfs.conf

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

# Check if any action is required

INITRAMFS_CONF=/etc/initramfs-tools/initramfs.conf
REQD_SETTING=gzip
CURR_SETTING=$(grep '^[[:space:]]*COMPRESS.*$' $INITRAMFS_CONF | cut -d= -f2)
if [ "$CURR_SETTING" = "$REQD_SETTING" ]; then
    echo "No change required: already $CURR_SETTING"
    exit 0
fi

# Fix IN-PLACE with 'sed -i'
sed -i "s/^[[:space:]]*COMPRESS.*$/COMPRESS=$REQD_SETTING/" $INITRAMFS_CONF
ret=$?
if [ $ret -ne 0 ]; then
    echo "Could not change $INITRAMFS_CONF"
fi

exit 0 # Always - to continue with other scripts
