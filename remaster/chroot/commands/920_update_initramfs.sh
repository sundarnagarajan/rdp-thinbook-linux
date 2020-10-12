#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

echo overlay >> /etc/initramfs-tools/modules
update-initramfs -u -k all 1>/dev/null 2>&1
