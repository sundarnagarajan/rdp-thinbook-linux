#!/bin/bash
# Make apt use HTTPS and not HTTP
APT_CMD=apt-get
DEBIAN_FRONTEND=noninteractive $APT_CMD install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    gnupg \
    dirmngr \
    curl \
    1>/dev/null 2>&1
