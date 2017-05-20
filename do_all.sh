#!/bin/bash

START_TIME=$(date)
TOP_DIR=$(pwd)
R_DIR=${TOP_DIR}/rdp-thinbook-linux/remaster
INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
EXTRACT_DIR=${TOP_DIR}/ISO/extract
OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso

if [ ! -f "$INPUT_ISO" ]; then
    echo "INPUT_ISO not found: $INPUT_ISO"
    exit 1
fi

rm -rf bootutils rdp-thinbook-linux "$OUTPUT_ISO"
git clone --depth 1 https://github.com/sundarnagarajan/bootutils.git
git clone --depth 1 https://github.com/sundarnagarajan/rdp-thinbook-linux.git

cp -rv rdp-thinbook-linux/kernel_compile $TOP_DIR/
cd $TOP_DIR/kernel_compile
./patch_linux-next_build.sh
mv *.deb $TOP_DIR/rdp-thinbook-linux/remaster/chroot/kernel-debs/

cd $TOP_DIR
rm -rf kernel_compile

sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
echo "Start: $START_TIME" ; echo "Ended: $(date)"
