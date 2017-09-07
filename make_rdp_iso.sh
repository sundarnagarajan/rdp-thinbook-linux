#!/bin/bash


function check_required_pkgs {
    REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl"
    MISSING_PKGS=$(dpkg -l $REQD_PKGS 2>/dev/null | sed -e '1,4d'| grep -v '^ii' | awk '{printf("%s ", $2)}')
    MISSING_PKGS="$MISSING_PKGS $(dpkg -l $REQD_PKGS 2>&1 1>/dev/null | sed -e 's/^dpkg-query: no packages found matching //')"
    MISSING_PKGS="${MISSING_PKGS%% *}"
    if [ -n "${MISSING_PKGS}" ]; then
        echo "You do not have all required packages installed"
        echo ""
        echo "sudo apt-get install $MISSING_PKGS"
        exit 1
    else
        echo "All required packages are already installed"
        echo "Required packages:"
        for p in $REQD_PKGS
        do
            echo "    $p"
        done
        echo ""
    fi
}

function check_avail_disk_space {
    REQD_SPACE_BYTES=10000000000
    AVAIL_SPACE_BYTES=$(df -B1 --output=avail . | sed -e '1d')
    echo "Required space: $REQD_SPACE_BYTES"
    echo "Available space: $AVAIL_SPACE_BYTES"
    if [ $AVAIL_SPACE_BYTES -lt $REQD_SPACE_BYTES ]; then
        echo "You do not have enough disk space"
        exit 1
    fi
    echo ""
}


START_TIME=$(date)
TOP_DIR=$(pwd)
R_DIR=${TOP_DIR}/rdp-thinbook-linux/remaster
INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
EXTRACT_DIR=${TOP_DIR}/ISO/extract
OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso

check_required_pkgs
check_avail_disk_space
if [ ! -f "$INPUT_ISO" ]; then
    echo "INPUT_ISO not found: $INPUT_ISO"
    exit 1
fi

rm -rf bootutils rdp-thinbook-linux "$OUTPUT_ISO"
git clone --depth 1 https://github.com/sundarnagarajan/bootutils.git
git clone --depth 1 https://github.com/sundarnagarajan/rdp-thinbook-linux.git

cp -rv rdp-thinbook-linux/kernel_compile $TOP_DIR/
cd $TOP_DIR/kernel_compile
./patch_and_build_kernel.sh
if [ $? -ne 0 ]; then
    exit 1
fi
mv debs/*.deb $TOP_DIR/rdp-thinbook-linux/remaster/chroot/kernel-debs/

cd $TOP_DIR
rm -rf kernel_compile

sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
echo "Start: $START_TIME" ; echo "Ended: $(date)"
