#!/bin/bash


function check_required_pkgs {
    REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl curl"
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
        echo "$REQD_PKGS" | fmt -w 70 | sed -e 's/^/    /'
        echo ""
    fi
}

function check_avail_disk_space {
    REQD_SPACE_BYTES=10000000000
    AVAIL_SPACE_BYTES=$(df -B1 --output=avail . | sed -e '1d')
    printf "Required space : %18d\n" $REQD_SPACE_BYTES
    printf "Available space: %18d\n" $AVAIL_SPACE_BYTES
    if [ $AVAIL_SPACE_BYTES -lt $REQD_SPACE_BYTES ]; then
        echo "You do not have enough disk space"
        exit 1
    fi
    echo ""
}

function update_from_git {
    cd $TOP_DIR
    rm -rf bootutils rdp-thinbook-linux kernel_build
    echo "Cloning bootutils..."
    git clone --depth 1 https://github.com/sundarnagarajan/bootutils.git 2>/dev/null
    echo "Cloning rdp-thinbook-linux..."
    git clone --depth 1 https://github.com/sundarnagarajan/rdp-thinbook-linux.git 2>/dev/null
    echo "Cloning kernel_build"
    git clone --depth 1 'https://github.com/sundarnagarajan/kernel_build.git' 2>/dev/null
}

function compile_kernel {
    cd $TOP_DIR
    cd $TOP_DIR/kernel_build
    ./patch_and_build_kernel.sh
    if [ $? -ne 0 ]; then
        exit 1
    fi
    mv debs/*.deb $TOP_DIR/rdp-thinbook-linux/remaster/chroot/kernel-debs/

    cd $TOP_DIR
}

function remaster_iso {
    if [ $(id -u) -ne 0 ]; then
        echo "Must be run as root"
        exit 1
    fi
    if [ ! -f "$INPUT_ISO" ]; then
        echo "INPUT_ISO not found: $INPUT_ISO"
        exit 1
    fi
    
    if [ -n "${OUTPUT_ISO}" -a -f "${OUTPUT_ISO}" ]; then
        sudo rm -f ${OUTPUT_ISO}
    fi
    if [ -n "$ENABLE_REBRAND" ]; then
        if [ -f $TOP_DIR/rdp-thinbook-linux/remaster/chroot/commands/00_rebrand.sh ]; then
            chmod +x $TOP_DIR/rdp-thinbook-linux/remaster/chroot/commands/00_rebrand.sh
        fi
    fi
    sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
}


START_TIME=$(date)
export TOP_DIR=$(readlink -e $(dirname $0))
export R_DIR=${TOP_DIR}/rdp-thinbook-linux/remaster
export INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
export EXTRACT_DIR=${TOP_DIR}/ISO/extract
export OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso
if [ "$1" = "--rebrand" ]; then
    echo "Enabling rebranding"
    export ENABLE_REBRAND=yes
else
    echo "Rebranding is disabled"
    unset ENABLE_REBRAND
fi

check_required_pkgs
check_avail_disk_space

update_from_git
compile_kernel
remaster_iso
echo "Start: $START_TIME" ; echo "Ended: $(date)"
