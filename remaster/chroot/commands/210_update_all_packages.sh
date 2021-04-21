#!/bin/bash
# Updates all installed packages to latest versions
# Requires 020_set_dns.sh and 045_apt_update.sh
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
APT_CMD=apt-get


echo "Updating all packages - this may take quite a while depending on your"
echo "network speed and machine configuration"
($APT_CMD update && $APT_CMD upgrade -y && $APT_CMD dist-upgrade -y) 1>/dev/null 2>&1
