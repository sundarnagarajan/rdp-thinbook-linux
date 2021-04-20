#!/bin/bash
# ------------------------------------------------------------------------
# This script ASSUMES a Debian-derived distro (that uses dpkg, apt-get)
# It also assumes Ubuntu-like initramfs commands / config
#
# 3 guard variables:
# NEED_ZSYS
#   - Defaults to "no"
#   - Do not (yet) know how to compile zsys from https://github.com/ubuntu/zsys
#   - zsys from Ubuntu repo cannot work with custom ZFS
#   - ZFS from Ubuntu repo cannot work with custom kernel
#   - Implies WANT_CUSTOM_ZFS=no
#   - Implies WANT_CUSTOM_KERNEL=no
#
# WANT_CUSTOM_KERNEL
#   - Defaults to "no"
#   - Expected to be used by top-level remastering script (also)
#       to decide whether to compile custom kernel
#   - This script uses WANT_CUSTOM_KERNEL AS WELL AS presence of DEBS
#     in kernel-debs dir
#   WANT_CUSTOM_KERNEL="yes" IGNORED if no DEBS found in kernel-debs dir
#
# WANT_CUSTOM_ZFS
#   - Defaults to "no"
#   - Expected to be used by top-level remastering script (also)
#       to decide whether to compile custom ZFS
#   - This script uses WANT_CUSTOM_ZFS AS WELL AS presence of DEBS
#     in zfs-kernel-debs and zfs-userspace-debs directories
#   - WANT_CUSTOM_ZFS="yes" IGNORED if DEBs are NOT found in EITHER of:
#       - zfs-kernel-debs dir
#       - zfs-userspace-debs dir
#
# This script replaces the following existing scripts:
#   - 360_install_kernels.sh 
#   - 362_install_kernel_cherrytux_ppa.sh
#   - 365_remove_old_kernels.sh
#   - 367_install_zfs_kernel_module.sh
#   - 369_install_zfs_userspace.sh
#
# Logic:
# if NEED_ZSYS = "yes" - this script does NOTHING
#   - Except status messages
#
# Otherwise NEED_ZSYS = "no"
#
# If WANT_CUSTOM_ZFS = "yes"
#   if EITHER zfs-kernel-debs OR zfs-userspace-debs do not contain DEBs
#       Exit with error
#
#   Implies WANT_CUSTOM_KERNEL = "yes"
#   If kernel-debs dir does not contain DEBs
#       Exit with error
#
# Otherwise WANT_CUSTOM_ZFS = "no"
#
# If WANT_CUSTOM_KERNEL = "yes"
#   If kernel-debs dir contains DEBs
#       Install all DEBs from kernel-debs dir
#   elif cherrytux_ppa_trusted :
#       Install cherrytux-iage cherrytux-headers
#   else
#       Exit with error
#
# Otherwise WANT_CUSTOM_KERNEL = "no"
#   Do nothing - except status messages
#
# postpone update-initramfs to 920_update_initramfs.sh
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# The README for xterm said:
#   Abandon All Hope, Ye Who Enter Here
#
# Restrict to setting NEED_ZSYS WANT_CUSTOM_KERNEL WANT_CUSTOM_ZFS
#
# Luckily commands in this directory are executed within the chroot, so
# the worst case is yout remastered ISO will have no kernel or no
# firmware and will fail to boot
# ------------------------------------------------------------------------

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster
FAILED_EXIT_CODE=127

KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs
ZFS_KERNEL_DEB_DIR=${PROG_DIR}/../zfs-kernel-debs
ZFS_USERSPACE_DEB_DIR=${PROG_DIR}/../zfs-userspace-debs
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)
ZFS_KERNEL_DEB_DIR=$(readlink -e $ZFS_KERNEL_DEB_DIR)
ZFS_USERSPACE_DEB_DIR=$(readlink -e $ZFS_USERSPACE_DEB_DIR)
INSTALLED_TXT="$REMASTER_DIR"/installed.txt
UNINSTALLED_TXT="$REMASTER_DIR"/uninstalled.txt
KP_LIST=kernel_pkgs.list
KP_LIST=${KERNEL_DEB_DIR}/$KP_LIST

# ------------------------------------------------------------------------
# Source these from prefs file
NEED_ZSYS=no
WANT_CUSTOM_KERNEL=yes
WANT_CUSTOM_ZFS=yes
# ------------------------------------------------------------------------
NEED_ZSYS=${NEED_ZSYS:-no}
WANT_CUSTOM_KERNEL=${WANT_CUSTOM_KERNEL:-no}
WANT_CUSTOM_ZFS=${WANT_CUSTOM_ZFS:-no}


function dir_contains_debs(){
    # $1: directory path
    # Returns: 0 if dir contains '*.deb' files; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ -d "$1" ]] || return 1
    local ret=1
    for f in "$1"/*.deb
    do
        [[ -f "$f" ]] && {
            ret=0
        break
        }
    done
    return $ret
}

function install_debs_in_dir() {
    # $1: directory path
    # Returns: 0 if all debs in dir were installed; 1 otherwise
    # Returns 0 if directory did not contain any debs
    [[ $# -lt 1 ]] && return 1
    [[ -d "$1" ]] || return 1
    dir_contains_debs "$1" || return 0
    ( cd "$1" && dpkg -i *.deb 1>/dev/null 2>&1 ) || return 1
    return 0
}

function package_names_from_debs() {
    # $1: directory path
    # Outputs (stdout) package names of all DEB files in dir
    [[ $# -lt 1 ]] && return 0
    [[ -d "$1" ]] || return 0
    dir_contains_debs "$1" || return 0
    for f in "$1"/*.deb
    do
        [[ -f "$f" ]] || continue
        dpkg-deb -f $f Package
    done
}

function filter_installed_pkgs() {
    # Parameters: Package name pattern (if any) - can be multiple package names also
    # Outputs package names on stdout - 1 per line WITHOUT ':$ARCH'
    dpkg-query -W --showformat='${db:Status-Status} ${Section} ${Package}\n' $* 2>/dev/null | awk '$1=="installed" {print $3}'
}

function filter_installed_pkgs_by_section() {
    # $1: section name (optional)
    # Outputs package names on stdout - 1 per line WITHOUT ':$ARCH'
    if [ -z "$1" ]; then
        dpkg-query -W --showformat='${db:Status-Status} ${Package}\n' $* 2>/dev/null | awk '$1=="installed" {print $2}'
    else
        dpkg-query -W --showformat='${db:Status-Status} ${Section} ${Package}\n' 2>/dev/null | awk '$1=="installed" && $2=="kernel" {print $3}'
    fi
}

function pkgs_installed_among() {
    # $@: package names
    # Outputs (to stdout) packages that are installed - 1 per line
    ( dpkg -l $@ 2>/dev/null || true ) | grep '^ii' | awk '{print $2}'
}

function set_opts() {
    # Sets NEED_ZSYS , WANT_CUSTOM_ZFS, WANT_CUSTOM_KERNEL
    # Returns: 0 if script can continue; 1 otherwise

    local KERNEL_DEBS_AVAIL=no
    local ZFS_KERNEL_DEBS_AVAIL=no
    local ZFS_USERSPACE_DEBS_AVAIL=no

    # We check these up front ONLY to emit status messages (if NEED_ZSYS = "yes")
    [[ -d "$KERNEL_DEB_DIR" ]] && dir_contains_debs "$KERNEL_DEB_DIR" ]] && KERNEL_DEBS_AVAIL=yes
    [[ -d "$ZFS_KERNEL_DEB_DIR" ]] && dir_contains_debs "$ZFS_KERNEL_DEB_DIR" && ZFS_KERNEL_DEBS_AVAIL=yes
    [[ -d "$ZFS_USERSPACE_DEB_DIR" ]] && dir_contains_debs "$ZFS_USERSPACE_DEB_DIR" && ZFS_USERSPACE_DEBS_AVAIL=yes

    for v in NEED_ZSYS WANT_CUSTOM_KERNEL WANT_CUSTOM_ZFS KERNEL_DEBS_AVAIL ZFS_KERNEL_DEBS_AVAIL ZFS_USERSPACE_DEBS_AVAIL
    do
        printf '%-32s  : %s\n' $v ${!v}
    done

    [[ "$NEED_ZSYS" = "yes" ]] && {
        [[ "$KERNEL_DEBS_AVAIL" = "yes" ]] && {
            echo "NEED_ZSYS=yes: Ignoring kernel DEBS in $KERNEL_DEB_DIR"
            for f in "$KERNEL_DEB_DIR"/*.deb
            do
                echo $(basename "$f") | sed -e 's/^/    /'
            done
        }    
        [[ "$ZFS_KERNEL_DEBS_AVAIL" = "yes" ]] && {
            echo "NEED_ZSYS=yes: Ignoring kernel DEBS in $ZFS_KERNEL_DEB_DIR"
            for f in "$ZFS_KERNEL_DEB_DIR"/*.deb
            do
                echo $(basename "$f") | sed -e 's/^/    /'
            done
        }    
        [[ "$ZFS_USERSPACE_DEBS_AVAIL" = "yes" ]] && {
            echo "NEED_ZSYS=yes: Ignoring kernel DEBS in $ZFS_USERSPACE_DEB_DIR"
            for f in "$ZFS_USERSPACE_DEB_DIR"/*.deb
            do
                echo $(basename "$f") | sed -e 's/^/    /'
            done
        }    
        echo "Not installing custom kernel or custom ZFS because NEED_ZSYS=yes"
        WANT_CUSTOM_ZFS=no
        WANT_CUSTOM_KERNEL=no
        return 0
    }

    [[ "$WANT_CUSTOM_ZFS" = "yes" ]] && {
        [[ "$ZFS_KERNEL_DEBS_AVAIL" = "no" ]] && {
            echo "WANT_CUSTOM_ZFS=yes, but no DEBs in $ZFS_KERNEL_DEB_DIR"
            return 1
        }    
        [[ "$KERNEL_DEBS_AVAIL" = "no" ]] && {
            echo "WANT_CUSTOM_ZFS=yes, but no DEBs in $KERNEL_DEB_DIR"
            return 1
        }    
        [[ "$ZFS_USERSPACE_DEBS_AVAIL" = "no" ]] && {
            echo "WANT_CUSTOM_ZFS=yes, but no DEBs in $ZFS_USERSPACE_DEB_DIR"
            return 1
        }    
        [[ "$WANT_CUSTOM_KERNEL" = "no" ]] && {
            echo "WANT_CUSTOM_ZFS=yes : Setting WANT_CUSTOM_KERNEL=yes"
        }
        WANT_CUSTOM_KERNEL=yes
        return 0
    }
    [[ "$WANT_CUSTOM_KERNEL" = "yes" ]] && {
        [[ "$KERNEL_DEBS_AVAIL" = "no" ]] && {
            echo "WANT_CUSTOM_KERNEL=yes, but no DEBs in $KERNEL_DEB_DIR"
            return 1
        }
    }
}

function cherrytux_ppa_trusted(){
    # Returns 0 if cherrytux PPA is trusted; 1 otherwise
    local CHERRYTUX_PPA_GPG_KEYID=ABF7C302A5B662BDE68E0EFE883F04480A577E61
    local APT_KEY_OUT=$(apt-key list $CHERRYTUX_PPA_GPG_KEYID 2>/dev/null)
    [[ -n "$APT_KEY_OUT" ]]
}

function install_kernel_cherrytux() {
    # Used to be 362_install_kernel_cherrytux_ppa.sh
    if [ -f $KP_LIST -a -s $KP_LIST ]; then
        grep -q '^linux-image' $KP_LIST
        if [ $? -eq 0 ]; then
            echo "Kernels already installed - not using cherrytux PPA"
            echo "cherrytux PPA setup and ready to use"
            exit 0
        fi
    fi

    local REQUIRED_PKGS="cherrytux-image cherrytux-headers"
    echo "Installing $REQUIRED_PKGS"
    apt install -y --no-install-recommends --no-install-suggests $REQUIRED_PKGS 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Install failed: $REQUIRED_PKGS"
        exit $FAILED_EXIT_CODE
    fi
    # Add kernel we installed to $KP_LIST
    mkdir -p $KERNEL_DEB_DIR
    touch $KP_LIST

    dpkg -l linux-image-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST
    dpkg -l linux-headers-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST
    cat "$KP_LIST" >> "$INSTALLED_TXT"

    echo "Installed following packages:"
    dpkg -l cherrytux-image | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
    dpkg -l cherrytux-headers | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
    cat $KP_LIST | sed -e 's/^/    /'
    dpkg -l linux-libc-dev | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
}

function install_kernel() {
    # Used to be 360_install_kernels.sh 
    local KERNEL_DEBS_AVAIL=no
    [[ -d "$KERNEL_DEB_DIR" ]] && dir_contains_debs "$KERNEL_DEB_DIR" ]] && KERNEL_DEBS_AVAIL=yes && {
        install_debs_in_dir "$KERNEL_DEB_DIR" || return 1        
        \cp -f /dev/null ${KP_LIST}
        package_names_from_debs "$KERNEL_DEB_DIR" >> ${KP_LIST}
        if [ -f ${KP_LIST} ]; then
            echo "New kernel packages installed:"
            cat ${KP_LIST} | sed -u -e 's/^/    /'
            cat "$KP_LIST" >> "$INSTALLED_TXT"
        else
            exit 0
        fi
    } || {
        cherrytux_ppa_trusted && {
            install_kernel_cherrytux || return 1
        } || {
                echo "No DEBs in $KERNEL_DEB_DIR, but cherrytux PPA is not trusted"
                return 1
        }
    }
    
}

function remove_old_kernels() {
    # Used to be 365_remove_old_kernels.sh
    # ASSUMES install_kernel was called and succeeded
    if [ ! -f $KP_LIST ]; then
        echo "kernel_pkgs.list not found: $KP_LIST"
        return 0
    fi

    # First check that all new kernel packages are actually installed
    for p in $(cat $KP_LIST | cut -d_ -f1)
    do
        local inst=$(filter_installed_pkgs $p)
        if [ "$p" != "$inst" ]; then
            echo "Expected package not installed: $p"
            echo "Not uninstalling anything"
            return 0
        fi
    done

    # Remove kernel-related packages EXCEPT those in $KP_LIST
    local REMOVE_LIST=""
    # for p in $(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
    for p in $(filter_installed_pkgs 'linux-image*')
    do
        fgrep -qx $p $KP_LIST
        if [ $? -ne 0 ]; then
            REMOVE_LIST="$REMOVE_LIST $p"
        fi
    done
    # for p in $(dpkg -l 'linux-modules-*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
    for p in $(filter_installed_pkgs 'linux-modules-*')
    do
        fgrep -qx $p $KP_LIST
        if [ $? -ne 0 ]; then
            REMOVE_LIST="$REMOVE_LIST $p"
        fi
    done
    # for p in $(dpkg -l 'linux-headers*' | grep '^ii' | awk '{print $2}' | cut-d: -f1)
    for p in $(filter_installed_pkgs 'linux-headers*')
    do
        fgrep -qx $p $KP_LIST
        if [ $? -ne 0 ]; then
            REMOVE_LIST="$REMOVE_LIST $p"
        fi
    done
    # for p in linux-signed-image-generic linux-generic
    for p in $(filter_installed_pkgs linux-signed-image-generic linux-generic)
    do
        fgrep -qx $p $KP_LIST
        if [ $? -ne 0 ]; then
            REMOVE_LIST="$REMOVE_LIST $p"
        fi
    done

    if [ -n "$REMOVE_LIST" ]; then
        echo "Removing following packages:"
        for p in $REMOVE_LIST
        do
            echo $p | sed -e 's/^/    /'
        done
        apt-get autoremove -y --purge $REMOVE_LIST 2>/dev/null 1>/dev/null || return 1
        echo "$REMOVE_LIST" | tr ' ' '\n' >> "$UNINSTALLED_TXT"
        # Store state for 320_linux_firmware.sh
        touch "$REMASTER_DIR"/ubuntu_kernels_removed
    else
        echo "No kernel packages to remove"
    fi

    # While we check not to DIRECTLY remove any package in $KP_LIST,
    # because we use apt-get autoremove, the autoremove may remove
    # things like linux-firmware-image - happens when linux-firmware-image
    # we are installing in 01_install_kernels.sh is the SAME as the 
    # linux-firmware-image version shipped by the distro
    # To deal with this, we RE-CHECK and REINSTALL any debs in
    # $KERNEL_DEB_DIR that are no longer installed!

    ls ${KERNEL_DEB_DIR}/ | grep -q '\.deb$'
    if [ $? -ne 0 ]; then
        echo "No deb files in $KERNEL_DEB_DIR"
    else
        local REINSTALLED=no
        for f in ${KERNEL_DEB_DIR}/*.deb
        do
            local PKG_VER=$(dpkg-deb -W --showformat '${Package}___${Version}\n' $f)
            dpkg-query -W --showformat '${Package}___${Version}\n' 2>/dev/null | fgrep -q "${PKG_VER}"
            if [ $? -ne 0 ]; then
                echo "Reinstalling ${PKG_VER}"
                dpkg -i $f
                REINSTALLED=yes
            fi
        done
        if [ "${REINSTALLED}" = "yes" ]; then
            echo "Some packages needed reinstallation"
        fi
    fi

    echo "Kernel-related packages remaining:"
    filter_installed_pkgs_by_section kernel  | grep '^linux' | sed -e 's/^/    /' 
}

function install_zfs_kernel_module() {
    # Used to be 367_install_zfs_kernel_module.sh
    if [ ! -f $KP_LIST ]; then
        echo "kernel_pkgs.list not found: $KP_LIST"
        return 1
    fi

    # First check that all new kernel packages are actually installed
    for p in $(cat $KP_LIST | cut -d_ -f1)
    do
        local inst=$(filter_installed_pkgs $p)
        if [ "$p" != "$inst" ]; then
            echo "Expected package not installed: $p"
            echo "Not installing ZFS kernel DEBs"
            return 1
        fi
    done

    # We need dkms and dkms needs python3-distutils (undeclared ?)
    local NEW_INSTALLED="build-essential dkms python3-distutils"
    apt install --no-install-recommends --no-install-suggests -y $NEW_INSTALLED 1>/dev/null 2>&1 || {
        echo "Install failed: $NEW_INSTALLED"
        return 1
    } && {
        echo "$NEW_INSTALLED" | tr ' ' '\n' >> $INSTALLED_TXT
    }
    # Stop zsys if it is running
    sudo systemctl stop zsysd.service zsysd.socket zsys-commit.service zsys-gc.service zsys-gc.timer 1>/dev/null 2>&1
    
    # Remove zfsutils-linux that conflicts with zfs-dkms
    local ZFS_REMOVE_PKGS="zsys zfs-zed zfsutils-linux libnvpair3linux libuutil3linux"
    ZFS_REMOVE_PKGS=$(pkgs_installed_among $ZFS_REMOVE_PKGS)
    [[ -n "$ZFS_REMOVE_PKGS" ]] && {
        echo "install_zfs_kernel_module : Removing packages that conflict with zfs-dkms:"
        echo "$ZFS_REMOVE_PKGS" | sed -e 's/^/    /'
        apt autoremove --purge -y $ZFS_REMOVE_PKGS 1>/dev/null 2>&1
        echo "$ZFS_REMOVE_PKGS" >> $UNINSTALLED_TXT
    } || {
        echo "install_zfs_kernel_module : No packages to remove"
    }

    echo "Installing ZFS kernel DEBs"
    install_debs_in_dir "$ZFS_KERNEL_DEB_DIR" || {
        echo "Install of ZFS kernel DEBs failed"
        return 1
    }

    echo "New ZFS kernel packages installed:"
    package_names_from_debs "$ZFS_KERNEL_DEB_DIR" | sed -e 's/^/    /'
    package_names_from_debs "$ZFS_KERNEL_DEB_DIR" >> "$INSTALLED_TXT"
}

function install_zfs_userspace_packages() {
    # Used to be 369_install_zfs_userspace.sh
    local UNINSTALL_PKGS=$(package_names_from_debs "$ZFS_USERSPACE_DEB_DIR")
    # Remove packages with 'alternative' names that get in the way
    UNINSTALL_PKGS="$UNINSTALL_PKGS libnvpair1linux libuutil1linux libzpool2linux zsys zfs-zed zfsutils-linux libnvpair3linux libuutil3linux"
    UNINSTALL_PKGS=$( pkgs_installed_among "$UNINSTALL_PKGS")
    if [ -n "$UNINSTALL_PKGS" ]; then
        echo "install_zfs_userspace_packages : Removing:"
        echo "$UNINSTALL_PKGS" | sed -e 's/^/    /'
        apt autoremove -y $UNINSTALL_PKGS 1>/dev/null 2>&1 || return 1
        echo "$UNINSTALL_PKGS" | tr ' ' '\n' >> $UNINSTALLED_TXT
    else
        echo "install_zfs_userspace_packages : No packages to remove"
    fi

    install_debs_in_dir "${ZFS_USERSPACE_DEB_DIR}" || return 1
    echo "New ZFS userspace packages installed:"
    local ZFS_PKG_LIST=$(package_names_from_debs "$ZFS_USERSPACE_DEB_DIR")
    echo "$ZFS_PKG_LIST" | sed -e 's/^/    /'
    echo "$ZFS_PKG_LIST" >> "$INSTALLED_TXT"

    # Create script to uninstall ZFS packages installed

    UNINSTALL_ZFS_DIR=${REMASTER_DIR}/zfs
    UNINSTALL_ZFS_SCRIPT="$UNINSTALL_ZFS_DIR"/uninstall_new_zfs.sh

    mkdir -p "$UNINSTALL_ZFS_DIR" || {
        >&2 echo "Could not create dir: $UNINSTALL_ZFS_DIR"
        return 0
    }
    ZFS_PKG_LIST=$(echo -e "$ZFS_PKG_LIST" | tr '\n' ' ')
    echo '#!/bin/bash' > "$UNINSTALL_ZFS_SCRIPT"
    echo "sudo apt autoremove --purge -y $ZFS_PKG_LIST" >> "$UNINSTALL_ZFS_SCRIPT"
    chmod +x "$UNINSTALL_ZFS_SCRIPT"
}




# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

set_opts || exit $FAILED_EXIT_CODE

mkdir -p $REMASTER_DIR
if [ -x /etc/grub.d/30_os-prober ]; then
    chmod -x /etc/grub.d/30_os-prober
fi


[[ "$WANT_CUSTOM_KERNEL" = "yes" ]] && {
    install_kernel || exit $FAILED_EXIT_CODE
    remove_old_kernels || exit $FAILED_EXIT_CODE
}

[[ "$WANT_CUSTOM_ZFS" = "yes" ]] && {
    install_zfs_kernel_module || exit $FAILED_EXIT_CODE
    install_zfs_userspace_packages || exit $FAILED_EXIT_CODE
}
