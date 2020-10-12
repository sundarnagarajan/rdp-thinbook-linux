#!/bin/bash
# Install files related to setting Wifi regulatory domain
# Depends on 020_set_dns.sh 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

# Install / upgrade wireless-regdb and crda
apt-get -y --no-install-recommends --no-install-suggests install wireless-regdb crda 1>/dev/null

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
