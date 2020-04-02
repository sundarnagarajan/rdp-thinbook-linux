#!/bin/bash

function check_host_arch() {
    # We _NEED_ x86_64 (amd64)
    # Returns: 0 if host architecture is x86_64; 1 otherwise
    local host_arch=$(arch)
    if [ "$host_arch" != "x86_64" ]; then
        echo "Need x86_64 architecture (current: $host_arch)"
        return 1
    fi
    return 0
}

check_host_arch
if [ $? -ne 0 ]; then
    exit 1
fi

function check_pkg_integrity() {
    # $1: package name
    # Returns: 0 if all files OK, 1 otherwise
    # If files are not OK, package name and output of md5sum is printed to stdout
    local old_pwd=$(pwd)
    local pkg=$1
    if [ -z "$pkg" ]; then
        echo "No package specified"
        return 1
    fi

    local md5sum_file=/var/lib/dpkg/info/${pkg}.md5sums
    if [ ! -f "$md5sum_file" ]; then
        md5sum_file=/var/lib/dpkg/info/${pkg}:amd64.md5sums
        if [ ! -f "$md5sum_file" ]; then
            echo "$pkg : md5sums not found"
            return 1
        fi
    fi

    cd /
    # files under /usr/share/man in .gz format are sometimes not avaailable
    # we ignore these errors

    errors=$(md5sum -c "$md5sum_file" 2>&1 1>/dev/null | grep -v '^md5sum: usr/share/man.*: No such file or directory$' | grep -v '^md5sum: WARNING: .* listed files could not be read$')
    if [ -n "$errors" ]; then
        echo "${pkg}:"
        echo -e "$errors" | sed -e 's/^/    /'
        return 1
    fi
    cd $old_pwd
}

function check_required_pkgs {
    local REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl curl"
    local MISSING_PKGS=$(dpkg -l $REQD_PKGS 2>/dev/null | sed -e '1,4d'| grep -v '^ii' | awk '{printf("%s ", $2)}')
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

    local FAILED_PKGS=""
    for p in $REQD_PKGS
    do
        check_pkg_integrity "$p"
        if [ $? -ne 0 ]; then
            FAILED_PKGS="$FAILED_PKGS $p"
        fi
    done
    if [ -n "$FAILED_PKGS" ]; then
        echo ""
        echo "The following packages are installed, but failed the integrity test"
        echo $FAILED_PKGS | fmt -w 70 | sed -e 's/^/    /'
        echo ""
        echo "You should reinstall these packages using the command:"
        echo "    sudo apt-get install --reinstall $FAILED_PKGS"
        exit 1
    fi
    echo "All required packages passed the integrity test"
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

function copy_linuxutils()
{
    local LINUXUTILS_DIR=/usr/local/bin/linuxutils
    if [ ! -d "$LINUXUTILS_DIR" ]; then
        echo "Directory not found: $LINUXUTILS_DIR"
        return
    fi
    cp -a "$LINUXUTILS_DIR" $TOP_DIR/rdp-thinbook-linux/remaster/chroot/
    for file_dir in .git fixrandr.py fixrandr_wrapper.py get_hosts_from_router ipmimon.py ipmimon_type_fan ipmimon_type_temperature ipmimon_type_voltage movewindow_fixes rdp.py repo_ppa_lib.py sas2ircu show_lsisas show_scanners sign_sha256_dir_hierarchy.sh show_ssh ssh_functions.sh sudoers.txt watch_md_iostat.sh xrandr_settings
    do
        rm -rf $TOP_DIR/rdp-thinbook-linux/remaster/chroot/$(basename "$LINUXUTILS_DIR")/$file_dir
    done
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

function download_virtualbox_guest_dkms_deb() {
    # We need virtualbox-guest-dkms version 6.1.2+
    # Only available in focal fossa
    # So we download it into chroot/virtualbox IFF commands/25_virtualbox_integration.sh
    # is executable
    if [ -x $TOP_DIR/rdp-thinbook-linux/remaster/chroot/commands/25_virtualbox_integration.sh ]; then
        if [ -x $TOP_DIR/rdp-thinbook-linux/remaster/chroot/virtualbox ]; then
            echo "Downloading virtualbox-guest DEBs"
            local oldpwd=$(pwd)
            cd $TOP_DIR/rdp-thinbook-linux/remaster/chroot/virtualbox
            wget -q -nd 'http://archive.ubuntu.com/ubuntu/pool/multiverse/v/virtualbox/virtualbox-guest-dkms_6.1.4-dfsg-2_all.deb' -O virtualbox-guest-dkms.deb
            wget -q -nd 'http://archive.ubuntu.com/ubuntu/pool/multiverse/v/virtualbox/virtualbox-guest-utils_6.1.4-dfsg-2_amd64.deb' -O virtualbox-guest-utils.deb
            wget -q -nd 'http://archive.ubuntu.com/ubuntu/pool/multiverse/v/virtualbox/virtualbox-guest-x11_6.1.4-dfsg-2_amd64.deb' -O virtualbox-guest-x11.deb
            ls -l *.deb 2>/dev/null | sed -e 's/^/    /'
            cd "$oldpwd"
        fi
    fi
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
copy_linuxutils
download_virtualbox_guest_dkms_deb
# compile_kernel
remaster_iso
echo "Start: $START_TIME" ; echo "Ended: $(date)"
