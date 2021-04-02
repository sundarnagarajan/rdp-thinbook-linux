#!/bin/bash
# Needs to be run as root
# $1 should be USB stick device - e.g. /dev/sdd

if [ $(id -u) -ne 0 ]; then
    echo "Must be run as \"sudo $0 <block_device_to_write>\""
    exit 1
fi

if [[ $# -lt 1 ]]; then
    lsblk -dtT -e 7,1,11 -o NAME,SIZE,MODEL,SERIAL,WWN,PHY-SEC,LOG-SEC,SCHED | sort
    echo ""
    echo ""

    read -p "Choose disk(/dev/sdX): " WRITE_DEV
else
    WRITE_DEV=$1
fi
if [ ! -b "$WRITE_DEV" ]; then
    echo "$WRITE_DEV is not a block-special device"
    exit 3
fi

start=$(date)

echo -n "Cleaning up ... "
# rm -rf bootutils ISO/extract ISO/out/modified.iso __kernel_build __zfs_build kernel_build
rm -rf ISO/extract ISO/out/modified.iso __kernel_build __zfs_build kernel_build
echo -e "done\n"

./make_rdp_iso.sh
ret=$?
if [ $ret -ne 0 ]; then
    echo "make_rdp_iso.sh exited with non-zero return code: $ret"
    exit 4
fi
if [ -f ISO/out/modified.iso ]; then
    if [ ! -b "$WRITE_DEV" ]; then
        echo "$WRITE_DEV is not a block-special device"
        exit 5
    fi
    dd if=ISO/out/modified.iso of=$WRITE_DEV bs=1M oflag=nocache status=progress
else
    echo "Output ISO not found: $(readlink -m ISO/out/modified.iso)"
    exit 6
fi

echo ""
echo "Start: $start"
echo "End: $(date)"
