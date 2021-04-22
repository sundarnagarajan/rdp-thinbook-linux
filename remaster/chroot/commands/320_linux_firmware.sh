#!/bin/bash
# ------------------------------------------------------------------------
# This only assumes that linux firmware is under /lib/firmware
# should be true for most / all distributions
#
# 3 guard variables - all can be 'no (default) or 'yes:
# FIRMWARE_UPDATE_PACKAGE:
#   - update linux-firmware PACKAGE from repository
#   - If this is set, the following are IGNORED:
#       FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU
#       FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX
#       FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL
# FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU:
#   - Pull firmware from ubuntu-firmware git repo
# FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX:
#   - Pull firmware from linux-firmware git repo
# FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL:
#   - Pull Intel firmware from iwlwifi firmware git
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
#   FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU
#   FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX
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

UPDATE_FIRMWARE_DIR=${PROG_DIR}/../update_firmware
UPDATE_FIRMWARE_SCRIPT=${UPDATE_FIRMWARE_DIR}/update_firmware.sh
UPDATE_FIRMWARE_SCRIPT=$(readlink -m "$UPDATE_FIRMWARE_SCRIPT")
[[ -f "$UPDATE_FIRMWARE_SCRIPT" ]] || {
    echo "Firmware update script not found: $UPDATE_FIRMWARE_SCRIPT"
    exit $FAILED_EXIT_CODE
}


FIRMWARE_UPDATE_PACKAGE=no
FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU=yes
FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX=yes
FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL=yes
# TODO: add code to source prefs file
# Was git installed in this script
GIT_REMOVE_REQUIRED=no


# Utility function that compares 2 version values and returns 0 if $2 >= $1
function compare_versions() {
    # $1: Version to compare with (min version)
    # $2: Version to evaluate (current version)
    [[ $# -lt 2 ]] && return 1
    [[ "$( (echo $1; echo $2) | sort -Vr | tail -1)" = "$1" ]]
}

# Function that sets the 3 guard variables
function set_opts(){

    # Remaining should be sane dependencies
    [[ "$FIRMWARE_UPDATE_PACKAGE" = "yes" ]] && {
        FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU="no"
        FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX="no"
        FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL="no"
        return
    }
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU" = "yes" ]] && FIRMWARE_UPDATE_PACKAGE=no
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX" = "yes" ]] && FIRMWARE_UPDATE_PACKAGE=no
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && FIRMWARE_UPDATE_PACKAGE=no
}

function cleanup_uninstall_git() {
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
trap cleanup_uninstall_git 1 2 3 15


# Install git if required and not installed
[[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU" = "yes" || \
    "$FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX" = "yes" || \
    "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" \
    ]] && {
        install_git_if_required || exit $FAILED_EXIT_CODE
    }

export FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL
$UPDATE_FIRMWARE_SCRIPT /lib || exit $FAILED_EXIT_CODE
\cp $UPDATE_FIRMWARE_SCRIPT "$REMASTER_DIR"/
