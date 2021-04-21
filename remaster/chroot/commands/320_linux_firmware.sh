#!/bin/bash
# ------------------------------------------------------------------------
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions
#
# 3 guard variables - all can be 'no (default) or 'yes:
# FIRMWARE_UPDATE_PACKAGE:
#   - update linux-firmware PACKAGE from repository
#   - Meaningless if FIRMWARE_UPDATE_FIRMWARE_GIT is set
# FIRMWARE_UPDATE_FIRMWARE_GIT:
#   - Pull firmware directly from linux-firmware git repo
#   - If this is set, FIRMWARE_UPDATE_PACKAGE is IGNORED
# FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL:
#   - Pull Intel firmware (ONLY) from iwlwifi firmware git
#   - FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL implies FIRMWARE_UPDATE_FIRMWARE_GIT
#       and automatically ignores FIRMWARE_UPDATE_PACKAGE
#
# Requires 020_set_dns.sh if ANY of the guard variables are set to "yes"
# Requires 045_apt_update.sh if FIRMWARE_UPDATE_PACKAGE = "yes"
# ------------------------------------------------------------------------

# ------------------------------------------------------------------------
# The README for xterm said:
#   Abandon All Hope, Ye Who Enter Here
#
# Restrict to setting:
#   FIRMWARE_UPDATE_PACKAGE
#   FIRMWARE_UPDATE_FIRMWARE_GIT
#   FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL
#
# Luckily commands in this directory are executed within the chroot, so
# the worst case is yout remastered ISO will have no kernel or no
# firmware and will fail to boot
# ------------------------------------------------------------------------


PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
APT_CMD=apt-get
REMASTER_DIR=/root/remaster
FAILED_EXIT_CODE=1


set -eu -o pipefail


FIRMWARE_UPDATE_PACKAGE=no
FIRMWARE_UPDATE_FIRMWARE_GIT=no
FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL=no
# Was git installed in this script
GIT_REMOVE_REQUIRED=no
# Temporary firmware dirs
FIRMWARE_DIR_LINUX_NEW=/lib/firmware-new
FIRMWARE_DIR_INTEL_NEW=/lib/firmware-intel


# Utility function that compares 2 version values and returns 0 if $2 >= $1
function compare_versions() {
    # $1: Version to compare with (min version)
    # $2: Version to evaluate (current version)
    [[ $# -lt 2 ]] && return 1
    [[ "$( (echo $1; echo $2) | sort -Vr | tail -1)" = "$1" ]]
}

# Function that sets the 3 guard variables
function set_opts(){
    # Following lines are where we set the guard variables
    FIRMWARE_UPDATE_PACKAGE=yes
    FIRMWARE_UPDATE_FIRMWARE_GIT=yes
    FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL=yes

    # Override (if desired) based on current Ubuntu release and / or current kernel version
    local MIN_RELEASE=20.10
    local MIN_KERNEL=5.8
    local CUR_RELEASE=$(cat /etc/os-release | grep '^VERSION_ID' | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//')
    local MAX_KERNEL_VER_INSTALLED=$(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $3}' |sort -Vr | head -1)

    compare_versions $MIN_RELEASE $CUR_RELEASE && compare_versions $MIN_KERNEL $MAX_KERNEL_VER_INSTALLED && {
        # echo "Current kernel (${MAX_KERNEL_VER_INSTALLED}) meets minimum requirements (${MIN_KERNEL})"
        # echo "Current release (${CUR_RELEASE}) meets minimum release (${MIN_RELEASE})"
        printf ""    # Null operation
    }

    # Remaining should be sane dependencies
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
        FIRMWARE_UPDATE_FIRMWARE_GIT=yes
        FIRMWARE_UPDATE_PACKAGE=no
    }
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT" = "yes" ]] && FIRMWARE_UPDATE_PACKAGE=no
}

function cleanup_firmware_dirs(){
    rm -rf $FIRMWARE_DIR_LINUX_NEW $FIRMWARE_DIR_INTEL_NEW || true
    [[ "$GIT_REMOVE_REQUIRED" = "yes" ]] && {
        echo "Uninstalling git"
        DEBIAN_FRONTEND=noninteractive $APT_CMD autoremove --purge git 1>/dev/null 2>&1 || true
    }
}

function update_firmware_package(){
    echo "Updating linux-firmware package"
    DEBIAN_FRONTEND=noninteractive $APT_CMD upgrade -y linux-firmware 1>/dev/null 2>&1 || {
        echo "linux-firmware upgrade failed"
        return 1
    }
}

function install_git_if_required(){
    # Sets global variable GIT_REMOVE_REQUIRED to "yes" if git was installed
    # Returns:
    #   0: if git was already installed or was installed successfully
    #   1: otherwise
    GIT_REMOVE_REQUIRED=no
    local GIT_ALREADY_INSTALLED=$(dpkg-query -W --showformat='${Package}\n' | fgrep -x git)
    if [ -z "$GIT_ALREADY_INSTALLED" ]; then
        echo "Installing git"
        $APT_CMD -y install --no-install-recommends --no-install-suggests git 1>/dev/null 2>&1 || {
            echo "Install failed: git"
            return 1
        }
        GIT_REMOVE_REQUIRED=yes
    fi
}

function update_firmware_linux_firmware_git(){
    local LINUX_FIRMWARE_GIT='https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git'
    rm -rf $FIRMWARE_DIR_LINUX_NEW
    git clone --depth 1 "$LINUX_FIRMWARE_GIT" $FIRMWARE_DIR_LINUX_NEW 1>/dev/null 2>&1 || {
        echo "git clone of linux-firmware git failed"
        return 1
    }
    echo "Updated firmware from linux firmware git"
}

function update_firmware_intel_firmware_git(){
    # ASSUMES that update_firmware_linux_firmware_git would have been called and
    # dir FIRMWARE_DIR_LINUX_NEW was already created
    local INTEL_FIRMWARE_GIT='https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/linux-firmware.git'
    rm -rf $FIRMWARE_DIR_INTEL_NEW
    git clone --depth 1 "$INTEL_FIRMWARE_GIT" $FIRMWARE_DIR_INTEL_NEW 1>/dev/null 2>&1 || {
        echo "git clone of intel-firmware git failed"
        return 1
    }

    
    # iwlwifi-*.ucode
    echo "Updating iwlwifi microcode"
    for f in $FIRMWARE_DIR_INTEL_NEW/iwlwifi-*.ucode
    do
        f=$(echo "$f" | sed -e 's/^\.\///')
        local bn=$(basename $f)
        [[ -f $FIRMWARE_DIR_LINUX_NEW/$bn ]] && {
            diff --brief $f $FIRMWARE_DIR_LINUX_NEW/$bn || {
                # Users will not be interested in actual firmware files updated
                # \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn && echo "    $f" || {
                \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn || {
                    echo "Copy failed: $f"
                    cd "$oldpwd"
                    return 1
                }
            }
        } || {
            # Users will not be interested in actual firmware files updated
            # \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn && echo "    $f" || {
            \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn || {
                echo "Copy failed: $f"
                cd "$oldpwd"
                return 1
            }
        }
    done
    
    # intel/*
    echo 'Updating intel-firmware/intel/'
    [[ -d $FIRMWARE_DIR_LINUX_NEW/intel ]] || {
        mkdir -p $FIRMWARE_DIR_LINUX_NEW/intel
    }
    cd $FIRMWARE_DIR_INTEL_NEW/intel
    for f in $(find -type f)
    do
        f=$(echo "$f" | sed -e 's/^\.\///')
        [[ -f $FIRMWARE_DIR_LINUX_NEW/$f ]] && {
            diff --brief $f $FIRMWARE_DIR_LINUX_NEW/$f || {
                # Users will not be interested in actual firmware files updated
                # \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/ && echo "    $f" || {
                \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/ || {
                    echo "Copy failed: $f"
                    return 1
                }
            }
        } || {
            # Users will not be interested in actual firmware files updated
            # \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/ && echo "    $f" || {
            \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/ || {
                echo "Copy failed: $f"
                return 1
            }
        }
    done

    cd /lib
    \rm -rf  $FIRMWARE_DIR_INTEL_NEW
    echo "Updated firmware from iwlwifi firmware git"
}


# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

set_opts

[[ "$FIRMWARE_UPDATE_PACKAGE" = "yes" ]] && {
    update_firmware_package || exit $FAILED_EXIT_CODE
    # Meaning less to download linux-firmware-git after updating linux-firmware package
    exit 0
}

# Setup trap to cleanup
trap cleanup_firmware_dirs 1 2 3 15


# Install git if required and not installed
[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT" = "yes" || "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
    install_git_if_required || exit $FAILED_EXIT_CODE
}

[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT" = "yes" ]] && {
    update_firmware_linux_firmware_git || exit $FAILED_EXIT_CODE
}

[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
    update_firmware_intel_firmware_git || exit $FAILED_EXIT_CODE
}

# Remove linux-firmware package if dependent kernels were removed
# cp -al FIRMWARE_DIR_LINUX_NEW to /lib/firmware if all was successful
# Use mark placed by 310_kernel_related.sh

# In future we COULD use pkg_apt_op_analysis to check whether removing
# linux-firmware WOULD remove any other package instead of using marker
[[ -f "$REMASTER_DIR"/ubuntu_kernels_removed ]] && {
    # No dependent kernels left - we can remove linux-firmware safely

    DEBIAN_FRONTEND=noninteractive $APT_CMD remove -y --purge linux-firmware 1>/dev/null 2>&1 && {
        echo "Removed package linux-firmware"
        mv /lib/firmware /lib/firmware-old-remaster || true
        mv $FIRMWARE_DIR_LINUX_NEW /lib/firmware 
    } || {
        echo "Could not remove package linux-firmware"
    }
} || {
    # linux-firmware needs to be held - no updates or deletion
    apt-mark hold linux-firmware
    echo "linux-firmware package held"
    mv /lib/firmware /lib/firmware-old-remaster
    mv $FIRMWARE_DIR_LINUX_NEW /lib/firmware
}
