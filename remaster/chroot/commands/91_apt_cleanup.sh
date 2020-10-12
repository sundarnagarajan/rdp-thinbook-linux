#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

apt-get clean 1>/dev/null 2>&1
apt-get autoclean 1>/dev/null 2>&1
apt-get -y autoremove --purge 1>/dev/null 2>&1
