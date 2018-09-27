#!/bin/bash
# Install files related to setting Wifi regulatory domain

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

ORIG_RESOLV_CONF=/etc/resolv.conf.remaster_orig
cat /etc/resolv.conf 2>/dev/null | grep -q '^nameserver'
if [ $? -ne 0 ]; then
    echo "Replacing /etc/resolv.conf"
    mv /etc/resolv.conf $ORIG_RESOLV_CONF
    echo -e "nameserver   8.8.8.8\nnameserver  8.8.4.4" > /etc/resolv.conf
fi

apt-get update 1>/dev/null

# Install / upgrade wireless-regdb and crda
apt-get -y install wireless-regdb crda 1>/dev/null

# Restore original /etc/resolv.conf if we had moved it
if [ -f  $ORIG_RESOLV_CONF -o -L $ORIG_RESOLV_CONF ]; then
    echo "Restoring original /etc/resolv.conf"
    \rm -f /etc/resolv.conf
    mv  $ORIG_RESOLV_CONF /etc/resolv.conf
fi

if [ -f /lib/crda/setregdomain ]; then
    if [ ! -f /etc/udev/rules.d/40-crda.rules ]; then
        echo 'SUBSYSTEM=="ieee80211", ACTION=="add", RUN+="/lib/crda/setregdomain"' > /etc/udev/rules.d/40-crda.rules
        # Set a default regulatory domain in /etc/default/crda
        CRDA_CONF=/etc/default/crda
        if [ -f $CRDA_CONF ]; then
            sed -i -e 's/^REGDOMAIN=$/REGDOMAIN=US/' $CRDA_CONF
            echo "Setting DEFAULT Wifi regulatory domain to US"
            echo "Change $CRDA_CONF to set REGDOMAIN to 2-letter ISO country code"
            echo "where you are operating Wifi to comply with local laws"
            echo "See: https://wireless.wiki.kernel.org/en/developers/Regulatory/CRDA"
        else
            echo "File not found: $CRDA_CONF"
        fi
    fi
else
    echo "File not found: /lib/crda/setregdomain"
fi
