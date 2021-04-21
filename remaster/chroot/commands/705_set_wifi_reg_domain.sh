#!/bin/bash
# Install files related to setting Wifi regulatory domain
# Depends on 020_set_dns.sh 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
APT_CMD=apt-get

# Install / upgrade wireless-regdb and crda
$APT_CMD -y --no-install-recommends --no-install-suggests install wireless-regdb crda 1>/dev/null 2>&1

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


exit 0

# No longer required starting with Groovy (20.10) kernel 5.8
MIN_RELEASE=20.10
CUR_RELEASE=$(cat /etc/os-release | grep '^VERSION_ID' | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//')
[[ "$( (echo $MIN_RELEASE; echo $CUR_RELEASE) | sort -Vr | tail -1)" = "$MIN_RELEASE" ]] && {
    MIN_KERNEL=5.8
    MAX_KERNEL_VER_INSTALLED=$(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $3}' |sort -Vr | head -1)
    [[ "$( (echo $MIN_KERNEL; echo $MAX_KERNEL_VER_INSTALLED) | sort -Vr | tail -1)" = "$MIN_KERNEL" ]] && {
        echo "Current kernel (${MAX_KERNEL_VER_INSTALLED}) meets minimum requirements (${MIN_KERNEL})"
        echo "Current release (${CUR_RELEASE}) meets minimum release (${MIN_RELEASE})"
        echo "Not installing wireless-regdb and crda"
        exit 0
    }
}

