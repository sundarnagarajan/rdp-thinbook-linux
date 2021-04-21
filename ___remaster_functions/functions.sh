#!/bin/bash
# NEEDS bash (and not sh / ksh / zsh etc)


# The directory containing generic remastering recpies
GIT_REMASTER_DIR=rdp-thinbook-linux


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

function check_pkg_integrity() {
    # $1: package name
    # Returns: 0 if all files OK, 1 otherwise
    # If files are not OK, package name and output of md5sum is printed to stdout
    [[ $# -lt 1 ]] && return 1
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

    # Assume package integrity if $md5sum_file is zero-sized - this is true
    # for some packages, such as python3-dev imagemagick-common python-all-dev libpython-all-dev libpython3-all-dev g++ python3-all
    # Find them using this command: find /var/lib/dpkg/info -name '*.md5sums' -size 0
    # All such packages I found so far do not contain FILES - only symlinks etc
    [[ ! -s "$md5sum_file" ]] && return 0

    cd /
    # files under /usr/share/man in .gz format are sometimes not available
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
    # Returns: 0 on sucecss; 1 otherwise
    # IDEALLY REQD_PKGS should be calculated based on whether kernel compilation is requested
    local REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl curl "
    # ZFS compilation additionally requries:
    REQD_PKGS="$REQD_PKGS autoconf automake libtool gawk alien dkms libblkid-dev uuid-dev libudev-dev zlib1g-dev libaio-dev libattr1-dev libelf-dev python3 python3-setuptools python3-cffi libffi-dev python3-dev"
    local MISSING_PKGS=$(dpkg -l $REQD_PKGS 2>/dev/null | sed -e '1,4d'| grep -v '^ii' | awk '{printf("%s ", $2)}')
    MISSING_PKGS="$MISSING_PKGS $(dpkg -l $REQD_PKGS 2>&1 1>/dev/null | sed -e 's/^dpkg-query: no packages found matching //')"
    MISSING_PKGS="${MISSING_PKGS%% *}"
    if [ -n "${MISSING_PKGS}" ]; then
        echo "You do not have all required packages installed"
        echo ""
        echo "sudo apt-get install $MISSING_PKGS"
        return 1
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
        return 1
    fi
    echo "All required packages passed the integrity test"
}

function check_avail_disk_space {
    # Returns: 0 on sucecss; 1 otherwise
    # IDEALLY REQD_SPACE_BYTES should be calculated based on whether kernel compilation is requested
    REQD_SPACE_BYTES=10000000000
    AVAIL_SPACE_BYTES=$(df -B1 --output=avail . | sed -e '1d')
    printf "Required space : %18d\n" $REQD_SPACE_BYTES
    printf "Available space: %18d\n" $AVAIL_SPACE_BYTES
    if [ $AVAIL_SPACE_BYTES -lt $REQD_SPACE_BYTES ]; then
        echo "You do not have enough disk space"
        return 1
    fi
    echo ""
}

function update_gitdir {
    # Returns: 0 on sucecss; 1 otherwise
    # $1: directory
    # $2: git url
    local oldpwd=$(pwd)
    local gitdir=$1
    local git_url=$2

    if [ -z "$2" ]; then
        echo "Usage: update_gitdir <directory_path> <git_url>"
        return 1
    fi
    gitdir=$(basename "$gitdir")

    cd "$TOP_DIR"
    if [ -d "$1" ]; then
        cd "$1"
        echo "Pulling latest changes to $gitdir"
        git pull
        if [ $? -ne 0 ]; then
            echo "Could not update $gitdir"
            cd "$oldpwd"
            return 1
        fi
    else
        echo "Cloning to $gitdir"
        git clone --depth 1 "$git_url" 2>/dev/null "$gitdir"
    fi
    cd $oldpwd
}

function update_from_git {
    # Returns: 0 on sucecss; 1 otherwise
    # Remote git URLs are ONLY in this function
    cd $TOP_DIR
    update_gitdir bootutils 'https://github.com/sundarnagarajan/bootutils.git' || return 1
    update_gitdir $GIT_REMASTER_DIR 'https://github.com/sundarnagarajan/rdp-thinbook-linux.git' || return 1

    # Copy scripts from bootutils
    \rm -rf $TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/scripts
    cp -a $TOP_DIR/bootutils/scripts $TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/
}

function copy_linuxutils()
{
    local LINUXUTILS_DIR=/usr/local/bin/linuxutils
    if [ ! -d "$LINUXUTILS_DIR" ]; then
        echo "Directory not found: $LINUXUTILS_DIR"
        return
    fi
    cp -a "$LINUXUTILS_DIR" $TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/
    for file_dir in .git fixrandr.py fixrandr_wrapper.py get_hosts_from_router ipmimon.py ipmimon_type_fan ipmimon_type_temperature ipmimon_type_voltage movewindow_fixes rdp.py repo_ppa_lib.py sas2ircu show_lsisas show_scanners sign_sha256_dir_hierarchy.sh show_ssh ssh_functions.sh sudoers.txt watch_md_iostat.sh xrandr_settings
    do
        rm -rf $TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/$(basename "$LINUXUTILS_DIR")/$file_dir
    done
}


function compile_kernel {
    # Returns: 0 on sucecss; 1 otherwise
    # Config values are in kernel_build.config
    \rm -rf "$TOP_DIR/__kernel_build" "$TOP_DIR/__zfs_build"
    \rm -rf "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/kernel-debs" "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-kernel-debs" "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-userspace-debs"

    cd $TOP_DIR
    update_gitdir kernel_build 'https://github.com/sundarnagarajan/kernel_build.git' || return 1
    KERNEL_BUILD_CONFIG="$TOP_DIR/kernel_build.config" $TOP_DIR/kernel_build/scripts/patch_and_build_kernel.sh
    if [ $? -ne 0 ]; then
        return 1
    fi

    # Copy kernel DEBs
    if [ $(ls -1 "$TOP_DIR/__kernel_build/debs"/*.deb 2>/dev/null | wc -l) -gt 0 ]; then
        echo "Moving kernel DEBs:"
        mkdir -p "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/kernel-debs"
        mv "$TOP_DIR/__kernel_build/debs/"*.deb "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/kernel-debs"/
        ( cd "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/kernel-debs"; ls -1 *.deb 2>/dev/null | sed -e 's/^/  /')
    else
        return 1
    fi

    # Copy ZFS debs if present
    if [ $(ls -1 "$TOP_DIR/__zfs_build/zfs_kernel_debs"/*.deb 2>/dev/null | wc -l) -gt 0 ]; then
        echo "Moving ZFS kernel DEBs:"
        mkdir -p "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-kernel-debs"
        mv "$TOP_DIR/__zfs_build/zfs_kernel_debs"/*.deb "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-kernel-debs"/
        ( cd "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-kernel-debs"; ls -1 *.deb 2>/dev/null | sed -e 's/^/  /')
    fi
    if [ $(ls -1 "$TOP_DIR/__zfs_build/zfs_userspace_debs"/*.deb 2>/dev/null | wc -l) -gt 0 ]; then
        echo "Moving ZFS userspace DEBs:"
        mkdir -p "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-userspace-debs"
        mv "$TOP_DIR/__zfs_build/zfs_userspace_debs"/*.deb "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-userspace-debs"/
        ( cd "$TOP_DIR/$GIT_REMASTER_DIR/remaster/chroot/zfs-userspace-debs"; ls -1 *.deb 2>/dev/null | sed -e 's/^/  /')
    fi
    cd $TOP_DIR
}

function remaster_iso {
    # Returns: 0 on sucecss; 1 otherwise
    if [ $(id -u) -ne 0 ]; then
        echo "Must be run as root"
        return 1
    fi
    if [ ! -f "$INPUT_ISO" ]; then
        echo "INPUT_ISO not found: $INPUT_ISO"
        return 1
    fi
    
    if [ -n "${OUTPUT_ISO}" -a -f "${OUTPUT_ISO}" ]; then
        sudo rm -f ${OUTPUT_ISO}
    fi
    sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
}
