#!/bin/bash
# Updates all installed packages to latest versions
# Requires 020_set_dns.sh and 045_apt_update.sh
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}


echo "Updating all packages - this may take quite a while"
echo "- depending on your network speed and machine configuration"
(apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y)
