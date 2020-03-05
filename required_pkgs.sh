#!/bin/bash


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
}

function check_required_pkgs {
    local REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl curl"
    $(dirname $0)/pkgs_missing_from.sh $REQD_PKGS
    ret=$?
    if [ $ret -ne 0 ]; then
        return $ret
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


check_required_pkgs
