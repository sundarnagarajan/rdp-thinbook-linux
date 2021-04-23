#!/bin/bash
# $1: LIB_DIR - should contain directory named 'firmware'
#
# LIB_DIR should contain directory named 'firmware' - current firmware
# LIB_DIR/firmware is updated IN PLACE - so non-standard files (like edid/* etc) will remain
# In case of any failure, LIB_DIR/firmware will be unchanged
#
# 3 environment variables are used if present to decide which updates to pull
FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU=${FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU:-yes}
FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX=${FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX:-yes}
FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL=${FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL:-yes}


PROG_NAME=$(basename $0)
set -eu -o pipefail


function show_usage() {
    echo "- Usage:
    ${PROG_NAME} [-h|--help] <LIB_DIR>
        -h|--help : Show this help and exit

- LIB_DIR:
    Running as root, to update /lib/firmware, LIB_DIR should be /lib

    LIB_DIR should contain directory named firmware - current firmware
    Current firmware will be backed up to LIB_DIR/firmware-backups/firmware-YYYYMMDD_HHMMSS
    Most recent backed up firmware will be LIB_DIR/firmware-backups/latest (symlink)
    On successful update, new updated firmware will be in LIB_DIR/firmware
    In case of any failure, LIB_DIR/firmware will be unchanged

- Sample output:

    ubuntu-firmware-git   : Files added / updated :   889 (  379M)
    linux-firmware-git    : Files added / updated :   181 (   25M)
    iwlwifi-firmware-git  : Files added / updated :    13 ( -108K)
    Total                 : Files added / updated :  1945 (  402M)
    Started  with  1945 files
    Finished with  2563 files
    Original firmware backed up to /lib/firmware-backups/firmware-20210422_042105

- Needs: 
    git (git)
    bash (bash) (not sh / ksh / zsh etc)
    coreutils (df, numfmt)
    grep (grep)
    gawk (awk)
    sed (sed)
- Needs Internet access (for git clone)
- Takes about 5 - 6 mins to complete
"
}

function partition_bytes_used() {
    # $1: directory - defaults to $(pwd)
    # Outputs partition (df) bytes used to stdout
    # Returns:
    #   0 if successful (part_dir valid or unspecified ($(pwd) used)
    #   1 if part_dir invalid (outputs nothing)
    local part_dir=
    [[ $# -gt 0 ]] && part_dir=$1 || part_dir=$(pwd)
    [[ -d "$part_dir" ]] || return 1
    df --sync -B1 --output=used "$part_dir" | sed -e '1d'
}

function create_backup_dir() {
    # $1: parent directory - must exist
    # Outputs newly created backup directory to stdout
    # Returns: 0 if successful; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    local parent_dir=$1
    [[ -n "$parent_dir" ]] && [[ -d "$parent_dir" ]] || return 1
    local TS=$(date '+%Y%m%d_%H%M%S')
    while true
    do
        mkdir "$parent_dir"/firmware-${TS} && break || {
            sleep 2
            TS=$(date '+%Y%m%d_%H%M%S')
            continue
        }
    done
    echo "$parent_dir"/firmware-${TS}
}

function firmware_update_from_git(){
    # $1: Existing firmware dir - will be UPDATED !
    # $2: Directory in which to create tmp dir - will be created if it doesn't exist
    # $3: git clone URL
    # Echoes number of FILES with contents updated to stdout
    local tmp_parent_dir=
    local tmp_dir=
    local tmp_parent_created=no
    [[ $# -lt 3 ]] && return 1
    [[ -d "$1" ]] || return 2
    local target=$(readlink -e "$1")
    tmp_parent_dir=$(readlink -m "$2")
    local git_url=$3
    local num_files_updated=0
    if [[ ! -d "$tmp_parent_dir" ]]; then
        mkdir -p "$tmp_parent_dir" || return 3
        tmp_parent_created=yes
    fi

    function cleanup_firmware_update_from_git(){
        [[ -n "$tmp_dir" ]] && [[ -d "$tmp_dir" ]] && {
            \rm -rf "$tmp_dir"
        }
        [[ "$tmp_parent_created" = "yes" ]] && {
            [[ -n "$tmp_parent_dir" ]] && [[ -d "$tmp_parent_dir" ]] && {
                \rm -rf "$tmp_parent_dir"
            }
        }
    }
    trap cleanup_firmware_update_from_git RETURN 1 2 3 15

    tmp_dir=$(mktemp -d -p "$tmp_parent_dir" "update_firmware_from_git.XXXXXX")
    git clone --quiet --depth 1 "$git_url" "$tmp_dir"/new || return 4
    \rm -rf "$tmp_dir"/new/.git

    cd "$tmp_dir"/new
    num_files_updated=$(find -type f -printf '%P\n' | while read f
    do
        [[ -e "$target"/"$f" ]] && {
            diff --brief "$f" "$target"/"$f" 1>/dev/null || {
                # Update existing file
                \cp -af --parents "$f" "$target" 1>/dev/null
                echo "Updated"
            }
        } || {
            # New file
            \cp -af --parents "$f" "$target" 1>/dev/null
            echo "New"
        }   
    done | wc -l)
    cd - 1>/dev/null

    echo $num_files_updated
    rm -rf "$tmp_dir"/new
}

function firmware_update_iwlwifi_from_git() {
    # $1: Existing firmware dir - will be UPDATED !
    # $2: Directory in which to create tmp dir - will be created if it doesn't exist
    # Echoes number of FILES with contents updated to stdout
    local tmp_parent_dir=
    local tmp_dir=
    local tmp_parent_created=no
    [[ $# -lt 2 ]] && return 1
    [[ -d "$1" ]] || return 2
    local target=$(readlink -e "$1")
    tmp_parent_dir=$(readlink -m "$2")
    local git_url='https://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/linux-firmware.git'
    local num_files_updated=0
    if [[ ! -d "$tmp_parent_dir" ]]; then
        mkdir -p "$tmp_parent_dir" || return 3
        tmp_parent_created=yes
    fi

    function cleanup_firmware_update_iwlwifi_from_git(){
        [[ -n "$tmp_dir" ]] && [[ -d "$tmp_dir" ]] && {
            \rm -rf "$tmp_dir"
        }
        [[ "$tmp_parent_created" = "yes" ]] && {
            [[ -n "$tmp_parent_dir" ]] && [[ -d "$tmp_parent_dir" ]] && {
                \rm -rf "$tmp_parent_dir"
            }
        }
    }
    trap cleanup_firmware_update_iwlwifi_from_git RETURN 1 2 3 15

    tmp_dir=$(mktemp -d -p "$tmp_parent_dir" "update_firmware_iwlwifi_from_git.XXXXXX")
    git clone --quiet --depth 1 "$git_url" "$tmp_dir"/new || return 4
    \rm -rf "$tmp_dir"/new/.git
    mkdir -p "$target"/intel || return 5

    # iwlwifi-*.ucode
    cd "$tmp_dir"/new
    num_files_updated=$(( $num_files_updated + $(find -maxdepth 1 -type f -name 'iwlwifi-*.ucode' -printf '%P\n' | while read f
    do
        [[ -e "$target"/"$f" ]] && {
            diff --brief "$f" "$target"/"$f" 1>/dev/null || {
                # Update existing file
                \cp -af --parents "$f" "$target" 1>/dev/null
                echo "Updated"
            }
        } || {
            # New file
            \cp -af --parents "$f" "$target" 1>/dev/null
            echo "New"
        }   
    done | wc -l ) ))
    cd - 1>/dev/null

    # intel sub-directory
    [[ -d "$tmp_dir"/new/intel ]] && {
        cd "$tmp_dir"/new/intel
        num_files_updated=$(( $num_files_updated + $(find -type f -printf '%P\n' | while read f
        do
            [[ -e "$target"/intel/"$f" ]] && {
                diff --brief "$f" "$target"/intel/"$f" 1>/dev/null || {
                    # Update existing file
                    \cp -af --parents "$f" "$target"/intel 1>/dev/null
                    echo "Updated"
                }
            } || {
                # New file
                \cp -af --parents "$f" "$target"/intel 1>/dev/null
                echo "New"
            }   
        done | wc -l ) ))
    }
    cd - 1>/dev/null

    echo $num_files_updated
    rm -rf "$tmp_dir"/new
}

function firmware_update_all() {
    # $1: LIB_DIR - should contain dir firmware

    local UBUNTU_GIT_URL='git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux-firmware'
    local LINUX_GIT_URL='git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git'
    [[ $# -lt 1 ]] && {
        show_usage
        return 1
    }

    local LIB_DIR=

    while [[ $# -gt 0 ]];
    do
        case "$1" in
            h|--help)
                show_usage
                return 0
                ;;
            *)
                LIB_DIR=$1
                shift
                ;;
        esac
    done

    [[ -z "$LIB_DIR" ]] && {
        show_usage
        return 1
    }
    [[ -d "$LIB_DIR" ]] || {
        >&2 echo "Dir does not exist: $LIB_DIR"
        show_usage
        return 2
    }
    LIB_DIR=$(readlink -e "$LIB_DIR")
    BAK_DIR="$LIB_DIR"/firmware-backups
    mkdir -p "$BAK_DIR" || return 3

    local FIRMWARE_DIR="$LIB_DIR"/firmware
    local FIRMWARE_ORIG_DIR=$(create_backup_dir "$BAK_DIR")
    local FIRMWARE_NEW_DIR="$LIB_DIR"/firmware.new
    local TMP_DIR="$LIB_DIR"/tmp

    cd "$LIB_DIR"
    local ORIGINAL_SIZE=$(partition_bytes_used "$LIB_DIR")
    local TOT_UPDATED_FILES=0
    local TOT_STARTING_FILES=$(find "$FIRMWARE_DIR" -type f | wc -l)
    local UPDATE_DONE=no


    # firmware dir -------------------------------------------------------
    [[ -d "$FIRMWARE_DIR" ]] || {
        >&2 echo "Directory does not exist: $FIRMWARE_DIR"
        return 4
    }

    # firmware.orig dir --------------------------------------------------
    \cp -al "$FIRMWARE_DIR"/. "$FIRMWARE_ORIG_DIR"/.
    ( 
        cd "$FIRMWARE_ORIG_DIR"
        \rm -f WHENCE.* date.*
        local find_output=$(find . -type f -printf '%TY%Tm%Td_%TH%TM%TS %P\n' | sort -nr | head -1)
        local newest_file=$(echo "$find_output" | cut -d' ' -f2)
        local file_ts=$(echo "$find_output" | cut -d' ' -f1)
        echo "$file_ts" > date.orig
        touch --reference="$newest_file" date.orig
        [[ -f WHENCE ]] && \mv -f WHENCE WHENCE.orig
        chmod go-w date.orig
        cd - 1>/dev/null 
    )

    # firmware.new dir ---------------------------------------------------
    [[ -e "$FIRMWARE_NEW_DIR" ]] && {
        echo "Removing directory: $FIRMWARE_NEW_DIR"
        \rm -rf "$FIRMWARE_NEW_DIR" || return 4
    }
    \cp -al "$FIRMWARE_DIR" "$FIRMWARE_NEW_DIR"

    local NEW_SIZE=$ORIGINAL_SIZE
    local ORIG_SIZE_1=$ORIGINAL_SIZE
    local UPDATED_FILES_1=0
    local ret=0

    # ubuntu-git ---------------------------------------------------------
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_UBUNTU" = "yes" ]] && {
        UPDATE_DONE=yes
        UPDATED_FILES_1=$(firmware_update_from_git "$FIRMWARE_NEW_DIR" "$TMP_DIR" "$UBUNTU_GIT_URL" || {
            ret=$?
            >&2 echo "firmware_update_from_git failed: $UBUNTU_GIT_URL ($ret)"
            \rm -rf "$FIRMWARE_NEW_DIR" "$FIRMWARE_ORIG_DIR"
            return $(( 4 + $ret ))
        })
        [[ -f "$FIRMWARE_NEW_DIR"/WHENCE ]] && \mv -f "$FIRMWARE_NEW_DIR"/WHENCE "$FIRMWARE_NEW_DIR"/WHENCE.ubuntu
        date '+%Y%m%d-%H%M%S' > "$FIRMWARE_NEW_DIR"/date.ubuntu
        TOT_UPDATED_FILES=$(( $TOT_UPDATED_FILES + $UPDATED_FILES_1 ))
        ORIG_SIZE_1=$NEW_SIZE
        NEW_SIZE=$(partition_bytes_used "$LIB_DIR")
        printf "ubuntu-firmware-git   : Files added / updated : %5d (%6s)\n" $UPDATED_FILES_1 $( echo "$(( $NEW_SIZE - $ORIG_SIZE_1 ))" | numfmt --to=iec )
    }

    # linux-firmware-git --------------------------------------------------
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_LINUX" = "yes" ]] && {
        UPDATE_DONE=yes
        UPDATED_FILES_1=$(firmware_update_from_git "$FIRMWARE_NEW_DIR" "$TMP_DIR" "$LINUX_GIT_URL" || {
            ret=$?
            >&2 echo "firmware_update_from_git failed: $LINUX_GIT_URL ($ret)"
            \rm -rf "$FIRMWARE_NEW_DIR" "$FIRMWARE_ORIG_DIR"
            return $(( 4 + $ret ))
        })
        [[ -f "$FIRMWARE_NEW_DIR"/WHENCE ]] && \mv -f "$FIRMWARE_NEW_DIR"/WHENCE "$FIRMWARE_NEW_DIR"/WHENCE.linux-firmware
        date '+%Y%m%d-%H%M%S' > "$FIRMWARE_NEW_DIR"/date.linux-firmware
        TOT_UPDATED_FILES=$(( $TOT_UPDATED_FILES + $UPDATED_FILES_1 ))
        ORIG_SIZE_1=$NEW_SIZE
        NEW_SIZE=$(partition_bytes_used "$LIB_DIR")
        printf "linux-firmware-git    : Files added / updated : %5d (%6s)\n" $UPDATED_FILES_1 $( echo "$(( $NEW_SIZE - $ORIG_SIZE_1 ))" | numfmt --to=iec )
    }

    # iwlwifi-git --------------------------------------------------------
    [[ "$FIRMWARE_UPDATE_FIRMWARE_GIT_INTEL" = "yes" ]] && {
        UPDATE_DONE=yes
        UPDATED_FILES_1=$(firmware_update_iwlwifi_from_git "$FIRMWARE_NEW_DIR" "$TMP_DIR" || {
            ret=$?
            >&2 echo "firmware_update_iwlwifi_from_git failed: ($ret)"
            \rm -rf "$FIRMWARE_NEW_DIR" "$FIRMWARE_ORIG_DIR"
            return $(( 4 + $ret ))
        })
        [[ -f "$FIRMWARE_NEW_DIR"/WHENCE ]] && \mv -f "$FIRMWARE_NEW_DIR"/WHENCE "$FIRMWARE_NEW_DIR"/WHENCE.iwlwifi
        date '+%Y%m%d-%H%M%S' > "$FIRMWARE_NEW_DIR"/date.iwlwifi
        TOT_UPDATED_FILES=$(( $TOT_UPDATED_FILES + $UPDATED_FILES_1 ))
        ORIG_SIZE_1=$NEW_SIZE
        NEW_SIZE=$(partition_bytes_used "$LIB_DIR")
        printf "iwlwifi-firmware-git  : Files added / updated : %5d (%6s)\n" $UPDATED_FILES_1 $( echo "$(( $NEW_SIZE - $ORIG_SIZE_1 ))" | numfmt --to=iec )
    }

    [[ "$UPDATE_DONE" = "yes" ]] && {
        # Replace FIRMWARE_DIR with FIRMWARE_NEW_DIR -------------------------
        \rm -rf $FIRMWARE_DIR
        mv $FIRMWARE_NEW_DIR $FIRMWARE_DIR
        # create symlink 'latest'
        \rm -rf "$BAK_DIR"/latest && ln -sf $(basename "$FIRMWARE_ORIG_DIR") "$BAK_DIR"/latest || true

        local NEW_SIZE=$(partition_bytes_used "$LIB_DIR")
        printf "Total                 : Files added / updated : %5d (%6s)\n" $TOT_UPDATED_FILES $( echo "$(( $NEW_SIZE - $ORIGINAL_SIZE ))" | numfmt --to=iec )
        printf "Started  with %5d files\n" $TOT_STARTING_FILES
        printf "Finished with %5d files\n" $(find "$FIRMWARE_DIR" -type f | wc -l)
        echo "Original firmware backed up to $FIRMWARE_ORIG_DIR"
        echo ""
        echo "Now you NEED to run 'update-initramfs -u -k all'"
    } || {
        \rm -rf "$FIRMWARE_NEW_DIR" "$FIRMWARE_ORIG_DIR"
    }
}

# ------------------------------------------------------------------------
# Actual script starts after this
# ------------------------------------------------------------------------

firmware_update_all $@ || exit $?
