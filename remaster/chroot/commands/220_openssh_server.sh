#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
FAILED_EXIT_CODE=127

# Depends on 020_set_dns.sh and 025_apt_update.sh

REQUIRED_PKGS="openssh-server"
echo "Installing $REQUIRED_PKGS"
apt install -y --no-install-recommends --no-install-suggests $REQUIRED_PKGS 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Install failed: $MISSING_PKGS"
    exit $FAILED_EXIT_CODE
fi
# dpkg -l $REQUIRED_PKGS 2>/dev/null | sed -e '1,5d' | awk '{print $1, $2}' | sed -e 's/^/    /'
