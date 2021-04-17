#!/bin/bash
# Run 'apt update' to get current package lists
# Requires Internet, updated /etc/resolv.conf (020_set_dns.sh)
add-apt-repository -n -y universe 1>/dev/null 2>&1 && {
    echo "Added universe repository"
}
apt update 1>/dev/null 2>&1
