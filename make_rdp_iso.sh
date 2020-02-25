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

function update_gitdir {
    # $1: directory
    # $2: git url
    local oldpwd=$(pwd)
    local gitdir=$1
    local git_url=$2

    if [ -z "$2" ]; then
        echo "Usage: update_gitdir <directory_path> <git_url>"
        return 1
    fi
    if [ -d "$1" ]; then
        cd "$1"
        echo "Pulling latest changes to $(basename $gitdir)"
        git pull
        if [ $? -ne 0 ]; then
            echo "Could not update $gitdir"
            cd $oldpwd
            exit 1
        fi
        cd $oldpwd
    else
        cd $(dirname $gitdir)
        echo "Cloning $(basename $gitdir)"
        git clone --depth 1 "$git_url" 2>/dev/null
        cd $oldpwd
    fi
}

function update_from_git {
    cd $TOP_DIR
    update_gitdir ${TOP_DIR}/bootutils 'https://github.com/sundarnagarajan/bootutils.git' || exit 1
    update_gitdir ${TOP_DIR}/kernel_build 'https://github.com/sundarnagarajan/kernel_build.git' || exit 1
    update_gitdir ${TOP_DIR}/rdp-thinbook-linux 'https://github.com/sundarnagarajan/rdp-thinbook-linux.git' || exit 1

    # Copy scripts from bootutils
    \rm -rf $TOP_DIR/rdp-thinbook-linux/remaster/chroot/scripts
    cp -a $TOP_DIR/bootutils/scripts $TOP_DIR/rdp-thinbook-linux/remaster/chroot/
}

function compile_kernel {
    cd $TOP_DIR
    # We only need kernel_build if we are compiling the kernel
    #update_gitdir ${TOP_DIR}/kernel_build 'https://github.com/sundarnagarajan/kernel_build.git' || exit 1

    # Config values are in kernel_build.config
    # Avoid kernel 4.17 - has issues with RDP 1130i
    # Because 4.17 had a huge set of ALSA changes?
    # export KERNEL_TYPE=stable
    # export KERNEL_BUILD_DIR=$TOP_DIR/kernel_build/debs
    # KERNEL_BUILD_CONFIG="./kernel_build.config" KERNEL__NO_SRC_PKG=yes KERNEL_BUILD_DIR=$TOP_DIR/kernel_build/debs ./patch_and_build_kernel.sh
    
    KERNEL_BUILD_CONFIG="$TOP_DIR/kernel_build.config" $TOP_DIR/kernel_build/scripts/patch_and_build_kernel.sh

    if [ $? -ne 0 ]; then
        exit 1
    fi
    echo "Moving compiled debs:"
    ls $TOP_DIR/__kernel_build/debs/*.deb | sed -e 's/^/    /'
    rm -f $TOP_DIR/rdp-thinbook-linux/remaster/chroot/kernel-debs/*.deb
    mv $TOP_DIR/__kernel_build/debs/*.deb $TOP_DIR/rdp-thinbook-linux/remaster/chroot/kernel-debs/

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
    sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
}

# ------------------------------------------------------------------------
# Main script starts after this
# ------------------------------------------------------------------------

START_TIME=$(date)
export TOP_DIR=$(readlink -e $(dirname $0))
export R_DIR=${TOP_DIR}/rdp-thinbook-linux/remaster
export INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
export EXTRACT_DIR=${TOP_DIR}/ISO/extract
export OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso

function cleanup_mounts()
{
    if [ -z "$EXTRACT_DIR" ]; then
        return
    fi
    which findmnt 1>/dev/null 2>&1 || return
    for d in $(findmnt -n -l | grep "$EXTRACT_DIR" | awk '{print $1}' | sort -r)
    do
        echo "Unmounting $d"
        umount $d
    done
    rm -rf "$EXTRACT_DIR"
}

trap cleanup_mounts 1 2 3 15


check_required_pkgs
check_avail_disk_space

update_from_git
# compile_kernel
remaster_iso
echo "Start: $START_TIME" ; echo "Ended: $(date)"
