#!/bin/bash
# Run 'apt update' to get current package lists
# Requires Internet, updated /etc/resolv.conf (020_set_dns.sh)
APT_CMD=apt-get
FAILED_EXIT_CODE=127
DEBIAN_FRONTEND=noninteractive $APT_CMD update 1>/dev/null 2>&1 || {
    echo "apt update failed"
    exit $FAILED_EXIT_CODE
}
