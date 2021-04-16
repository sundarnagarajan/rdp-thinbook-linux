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

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}


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
    rm -rf $FIRMWARE_DIR_LINUX_NEW $FIRMWARE_DIR_INTEL_NEW    
    [[ "$GIT_REMOVE_REQUIRED" = "yes" ]] && {
        apt-get autoremove -y --purge git 1>/dev/null 2>/dev/null
    }
}

function update_firmware_package(){
    echo "Updating linux-firmware package"
    apt upgrade -y linux-firmware 1>/dev/null 2>&1 || {
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
        apt-get -y install --no-install-recommends --no-install-suggests git 1>/dev/null 2>&1 || {
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
    for f in $FIRMWARE_DIR_INTEL_NEW/iwlwifi-*.ucode
    do
        local bn=$(basename $f)
        [[ -f $FIRMWARE_DIR_LINUX_NEW/$bn ]] && {
            diff --brief $f $FIRMWARE_DIR_LINUX_NEW/$bn || {
                \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn && echo "    $f" || {
                    echo "Copy failed: $f"
                    cd "$oldpwd"
                    return 1
                }
            }
        } || {
            \cp -f $f $FIRMWARE_DIR_LINUX_NEW/$bn && echo "    $f" || {
                echo "Copy failed: $f"
                cd "$oldpwd"
                return 1
            }
        }
    done
    
    # intel/*
    [[ -d $FIRMWARE_DIR_LINUX_NEW/intel ]] || {
        mkdir -p $FIRMWARE_DIR_LINUX_NEW/intel
    }
    cd $FIRMWARE_DIR_INTEL_NEW/intel
    for f in $(find -type f)
    do
        [[ -f $FIRMWARE_DIR_LINUX_NEW/$f ]] && {
            diff --brief $f $FIRMWARE_DIR_LINUX_NEW/$f || {
                \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/$f && echo "    $f" || {
                    echo "Copy failed: $f"
                    cd "$oldpwd"
                    return 1
                }
            }
        } || {
            \cp --parents -f $f $FIRMWARE_DIR_LINUX_NEW/$f && echo "    $f" || {
                echo "Copy failed: $f"
                cd "$oldpwd"
                return 1
            }
        }
    done

    echo "Updated firmware from iwlwfi firmware git"
    cd "$oldpwd"
}



set_opts

[[ "$FIRMWARE_UPDATE_PACKAGE" = "yes" ]] && {
    update_firmware_package || exit 1
}

# Setup trap to cleanup
trap cleanup_firmware_dirs 1 2 3 15


# Install git if required and not installed
[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT" = "yes" || "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
    install_git_if_required || exit 1
}

[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT" = "yes" ]] && {
    update_firmware_linux_firmware_git || exit 1
}

[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
    update_firmware_intel_firmware_git || exit 1
}

# Flip FIRMWARE_DIR_LINUX_NEW to /lib/firmware if all was successful
mv /lib/firmware /lib/firmware-old
mv $FIRMWARE_DIR_LINUX_NEW /lib/firmware
rm -rf /lib/firmware-old
