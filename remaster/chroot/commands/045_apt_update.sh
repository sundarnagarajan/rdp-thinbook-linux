#!/bin/bash
# Run 'apt update' to get current package lists
# Requires Internet, updated /etc/resolv.conf (020_set_dns.sh)
apt update 1>/dev/null 2>&1
