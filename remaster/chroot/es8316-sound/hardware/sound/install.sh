#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")

# Check that required scripts are present
if [ ! -d ${PROG_DIR}/bytcht-es8316 ]; then
    echo "Missing dir: ${PROG_DIR}/bytcht-es8316"
    exit 1
fi
for f in bytcht-es8316.conf HiFi
do
    if [ ! -f ${PROG_DIR}/bytcht-es8316/$f ]; then
        echo "Missing file: ${PROG_DIR}/bytcht-es8316/$f"
        exit 1
    fi
done
if [ ! -f ${PROG_DIR}/rdp-es8316.conf ]; then
    echo "Missing file: ${PROG_DIR}/rdp-es8316.conf"
    exit 1
fi

\cp -frv ${PROG_DIR}/bytcht-es8316 /usr/share/alsa/ucm/
\cp -frv ${PROG_DIR}/rdp-es8316.conf /etc/modprobe.d/
