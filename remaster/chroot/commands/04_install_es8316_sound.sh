#!/bin/bash
# Install files related to making es8316 sound work

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

ES8316_SCRIPTS_DIR=${PROG_DIR}/../es8316-sound

if [ ! -d ${ES8316_SCRIPTS_DIR} ]; then
    echo "ES8316_SCRIPTS_DIR not a directory: $ES8316_SCRIPTS_DIR"
    exit 0
fi
ES8316_SCRIPTS_DIR=$(readlink -e $ES8316_SCRIPTS_DIR)
test "$(ls -A $ES8316_SCRIPTS_DIR)"
if [ $? -ne 0 ]; then
    echo "No files to copy: $ES8316_SCRIPTS_DIR"
    exit 0
fi

mkdir -p /root
cp -r ${ES8316_SCRIPTS_DIR}/. /root/

if [ ! -x /root/hardware/sound/install.sh ]; then
    echo "Not found or not executable: /root/hardware/sound/install.sh"
    exit 0
fi

/root/hardware/bluetooth/install.sh
