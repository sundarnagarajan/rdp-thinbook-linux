#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
APT_CMD=apt-get

$APT_CMD clean 1>/dev/null 2>&1
$APT_CMD autoclean 1>/dev/null 2>&1
$APT_CMD -y autoremove --purge 1>/dev/null 2>&1
