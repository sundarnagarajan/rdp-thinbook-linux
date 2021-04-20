#!/bin/bash
# This only assumes Ubuntu/Debian naming convention for kernel
# and initrd files. Also assumes Ubuntu-specific location for
# kernel and initrd in ISO (/casper)
# Expects env var REMASTER_ISO_CHROOT_DIR to be set

# ------------------------------------------------------------------------
# The README for xterm said:
#   Abandon All Hope, Ye Who Enter Here
#
# Restrict to setting:
#
#
# Unlike chroot/commands, the scripts in this directory are executed
# OUTSIDE the chroot and AS ROOT! Mistakes in these scripts could make
# unintended changes to your HOST machine environment
#
# 1. Check that ISO_EXTRACT_DIR env var is set and is not empty or '/'
# 2. Identify ALL directories the script uses at the TOP (globals)
# 3. For EACH directory used in the script (globals):
#       a. Check that the variable is set and is not empty and not '/'
#       b. Check that the value starts with $ISO_EXTRACT_DIR
#
# If any of above conditions are not met, bail with exit code 127
# ------------------------------------------------------------------------


PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}


function dd_with_skip() {
    # $1: file path
    # $2 blocks to skip - defaults to zero
    local BLOCKSIZE=512
    local SKIP=0
    if [ -n "$2" ]; then
        SKIP=$2
    fi
    dd if="$1" bs=$BLOCKSIZE skip=$SKIP 2>/dev/null
}

function filetype_with_skip() {
    # $1: file path
    # $2 blocks to skip - defaults to zero
    # Outputs filetype from 'file -b'
    dd_with_skip "$1" $2 | file -b -
}

function cpio_blocks_with_skip() {
    # $1: file path
    # $2 blocks to skip - defaults to zero
    # Outputs number of blocks used by cpio archive
    dd_with_skip "$1" $2 | cpio -it 2>&1 1>/dev/null | awk '{print $1}'
}

function decomp_for_filetype() {
    # $1: file type as returned by 'file -b'
    # If file type is recognized:
    #   if required decompress command is available:
    #       outputs: extract command, returns 0
    #   else
    #       outputs package required, returns 1
    # else
    #   outputs nothing, returns 2
    local CPIO_EXTRACT="cpio --quiet -id 2>/dev/null"
    local ft=$1
    local major_ubuntu_release=$(cat /etc/lsb-release | grep '^DISTRIB_RELEASE=' | cut -d= -f2 | cut -d. -f1)

    # uncompressed cpio archive
    echo "$ft" | grep -q '^ASCII cpio archive'
    if [ $? -eq 0 ]; then
        echo "$CPIO_EXTRACT"
        return 0
    fi

    # gzipped
    echo "$ft" | grep -q '^gzip compressed data'
    if [ $? -eq 0 ]; then
        which gzip 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "gzip"
            return 1
        fi
        echo "gzip -dc | $CPIO_EXTRACT"
        return 0
    fi

    # bzip2
    echo "$ft" | grep -q '^cwbzip2LZMA compressed data'
    if [ $? -eq 0 ]; then
        which bzip2 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "bzip2"
            return 1
        fi
        echo "bzip2 -dc | $CPIO_EXTRACT"
        return 0
    fi

    # XZ
    echo "$ft" | grep -q '^XZ compressed data'
    if [ $? -eq 0 ]; then
        which xz 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "xz-utils"
            return 1
        fi
        echo "xz -dc | $CPIO_EXTRACT"
        return 0
    fi

    # LZMA
    echo "$ft" | grep -q '^LZMA compressed data'
    if [ $? -eq 0 ]; then
        which lzma 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "xz-utils"
            return 1
        fi
        echo "lzma -dc | $CPIO_EXTRACT"
        return 0
    fi

    # lz4
    echo "$ft" | grep -q '^LZ4 compressed data'
    if [ $? -eq 0 ]; then
        which lzma 1>/dev/null
        if [ $? -ne 0 ]; then
            if [ $major_ubuntu_release -ge 20 ]; then
                echo "lz4"
            else
                echo "liblz4-tool"
            fi
            return 1
        fi
        echo "lz4 -dc | $CPIO_EXTRACT"
        return 0
    fi

    # lzop
    echo "$ft" | grep -q '^lzop compressed data'
    if [ $? -eq 0 ]; then
        which lzop 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "lzop"
            return 1
        fi
        echo "lzop -dc | $CPIO_EXTRACT"
        return 0
    fi

    # Zstandard
    # zstd -dc seems to extract cpio archive anyway !
    # So Zstdnard initramfs extraction is not (yet) really working
    echo "$ft" | grep -q '^Zstandard compressed data'
    if [ $? -eq 0 ]; then
        which zstd 1>/dev/null
        if [ $? -ne 0 ]; then
            echo "zstd"
            return 1
        fi
        echo "zstd -dc | $CPIO_EXTRACT"
        return 0
    fi


    # Unrecognized file format
    return 2
}

function decomp_command() {
    # $1: file path
    # $2 blocks to skip - defaults to zero
    # Outputs:
    #   If file path (or FIRST archive in file path) is an ASCII cpio archive
    #       outputs: <cpio archive size in blocks> <decompress command>, returns 0
    #   Else (compressed cpio archive of any type
    #       outputs: -1 <decompress command>
    #   If end of file
    #       outputs zero empty + returns 1
    #   If decompress command for file type not installed
    #       outputs -2 package_required + returns 2
    #   If file type is not recognized
    #       outputs -3 false + returns 2
    # Returns:
    #   0: If file type was recognized
    #   1: End of file
    #   2: decompress command for file type not installed
    #   3: file type was not recognized

    local ft=$(filetype_with_skip "$1" $2)

    if [ "ft" = "empty" ]; then
        echo "0 empty"
        return 1
    fi
    echo "$ft" | grep -q '^ASCII cpio archive'
    if [ $? -eq 0 ]; then
        local cpio_blocks=$(cpio_blocks_with_skip "$1" $2)
        echo "$cpio_blocks cpio --quiet -id 2>/dev/null"
        return 0
    fi

    local dc=$(decomp_for_filetype "$ft")
    local ret=$?
    case $ret in
        2)
            # Unrecognized file format
            echo "-3 false"
            return 3
            ;;
        1)
            # decompress command for file type not installed
            echo "-2 $dc"
            return 2
            ;;
        0)
            echo "-1 $dc"
            return 0
            ;;
    esac
}

function unpack_pipeline() {
    # $1: INITRD file path - must exist
    # Outputs: command pipeline to extract $INITRD

    [ -z "$1" ] && return 1

    local INITRD=$(readlink -m "$1")

    if [ ! -f "$INITRD" ]; then
        echo "INITRD is not a file: $INITRD"
        return 2
    fi

    local pipeline=""
    local skip=0
    local ret=0

    while [ $ret -eq 0 ]
    do
        local dc_out=$(decomp_command "$INITRD" $skip)
        ret=$?
        if [ $ret -eq 1 ]; then
            break
        fi
        local blocks=$(echo $dc_out | cut -d' ' -f1)
        local dc_cmd=$(echo $dc_out | cut -d' ' -f2-)

        case $ret in
            0)
                if [ -z "$pipeline" ]; then
                    pipeline=$dc_cmd
                else
                    pipeline="$pipeline ; $dc_cmd"
                fi
                if [ $blocks -le 0 ]; then
                    break
                fi
                skip=$(( $skip + $blocks ))
                ;;
            1)
                break
                ;;
            2)
                # decompress command for file type not installed
                return 1
                ;;
            3)
                # Unrecognized file format
                return 2
                ;;
        esac
    done
    echo "$pipeline"
    return 0
}

function unpack_initramfs() {
    # $1: EXTRACT_DIR - must exist
    # $2: INITRD file path - must exist

    [ -z "$2" ] && return 1

    local EXTRACT_DIR=$(readlink -m "$1")
    local INITRD=$(readlink -m "$2")

    if [ ! -d "$EXTRACT_DIR" ]; then
        echo "EXTRACT_DIR is not a file: $EXTRACT_DIR"
        return 2
    fi
    if [ ! -f "$INITRD" ]; then
        echo "INITRD is not a file: $INITRD"
        return 3
    fi

    local cmd_pipeline=$(unpack_pipeline "$INITRD")
    if [ $? -ne 0 ]; then
        return 4
    fi

    local oldpwd=$(pwd)
    cd "$EXTRACT_DIR"
    cmd="cat \"$INITRD\" | ( $cmd_pipeline )"
    eval $cmd
    cd "$oldpwd"
}

function merge_initramfs() {
    # $1: EXTRACT_DIR file path - must exist
    # $2: OLD_INITRD file path - must exist
    # $3: NEW_INITRD file path- must exist
    # $4: OUT_INITRD file path - can exist will be created / overwritten
    #     OUT_INITRD path directory must exist
    #     OUT_INITRD COULD be OLD_INITRD or NEW_INITRD, since
    #       OLD_INITRD and NEW_INITRD are extracted before merging
    #       and writing OUT_INITRD
    #
    # MERGE_DIRS are removed from OLD_INITRD and replaced with
    # MERGE_DIRS from NEW_INITRD - only if MERGE_DIRS exist in NEW_INITRD
    # REMOVE_FILE_DIRS are removed from OLD_INITRD if they exist

    MERGE_DIRS="usr/lib/modules usr/lib/firmware"
    REMOVE_FILE_DIRS=""

    INITRD_COMPRESS_CMD="gzip -c"
    # LZ4
    #INITRD_COMPRESS_CMD="lz4 -zc"


    if [ -z "$4" ]; then
        echo "Usage: merge_initramfs <EXTRACT_DIR> <OLD_INITRD> <NEW_INITRD> <OUT_INITRD>"
        return 1
    fi

    local EXTRACT_DIR=$(readlink -m "$1")
    local OLD_INITRD=$(readlink -m "$2")
    local NEW_INITRD=$(readlink -m "$3")
    local OUT_INITRD=$(readlink -m "$4")

    if [ ! -d "$EXTRACT_DIR" ]; then
        echo "EXTRACT_DIR is not a file: $EXTRACT_DIR"
        return 2
    fi
    if [ ! -f "$OLD_INITRD" ]; then
        echo "OLD_INITRD is not a file: $OLD_INITRD"
        return 3
    fi
    if [ ! -f "$NEW_INITRD" ]; then
        echo "NEW_INITRD is not a file: $NEW_INITRD"
        return 4
    fi
    local OUT_INITRD_DIR=$(dirname "$OUT_INITRD")
    if [ ! -d "$OUT_INITRD_DIR" ]; then
        echo "OUT_INITRD_DIR is not a file: $OUT_INITRD_DIR"
        return 5
    fi

    local D_OLD=$(mktemp -d -p "$EXTRACT_DIR")
    local D_NEW=$(mktemp -d -p "$EXTRACT_DIR")

    echo "Unpacking $OLD_INITRD"
    unpack_initramfs "$D_OLD" "$OLD_INITRD"
    if [ $? -ne 0 ]; then
        rm -rf $D_OLD $D_NEW
        return 6
    fi
    echo "Unpacking $NEW_INITRD"
    unpack_initramfs "$D_NEW" "$NEW_INITRD"
    if [ $? -ne 0 ]; then
        rm -rf $D_OLD $D_NEW
        return 7
    fi

    for d in $MERGE_DIRS
    do
        # Remove leading slash if any
        d=$(echo "$d" | sed -e 's/^\///')
        local target=$(dirname "$d")
        if [ -d "${D_NEW}/${d}" ]; then
            echo "Replacing ${d}"
            rm -rf "${D_OLD}/${d}"
            mv "${D_NEW}/${d}" "${D_OLD}/${target}/"
        fi
    done
    for df in $REMOVE_FILE_DIRS
    do
        df=$(echo "$df" | sed -e 's/^\///')
        echo "Removing ${df}"
        rm -rf "${D_OLD}/${df}"
    done

    # Create new initrd
    echo "Creating $OUT_INITRD"
    local oldpwd=$(pwd)
    cd "${D_OLD}"
    ( find . | cpio --quiet -o -H newc | $INITRD_COMPRESS_CMD ) > "$OUT_INITRD"
    cd "$oldpwd"
    \rm -rf "$D_OLD" "$D_NEW"
}



ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)
REMASTER_DIR=/root/remaster
KP_LIST=kernel_pkgs.list

if [ -z "$REMASTER_ISO_CHROOT_DIR" ]; then
    echo "REMASTER_ISO_CHROOT_DIR not set"
    exit 0
fi
if [ ! -d "$REMASTER_ISO_CHROOT_DIR" ]; then
    echo "REMASTER_ISO_CHROOT_DIR not a directory: $REMASTER_ISO_CHROOT_DIR"
    exit 0
fi

cd ${REMASTER_ISO_CHROOT_DIR}/boot/
# Get highest version vmlinuz and initrd
SRC_VMLINUZ=$(ls -L1 vmlinuz-* 2>/dev/null | tail -1)
if [ -z "$SRC_VMLINUZ" ]; then
    echo "No vmlinuz found under $(pwd)"
    exit 0
fi
SRC_VER=$(echo $SRC_VMLINUZ | cut -d- -f2-)
if [ -z "$SRC_VER" ]; then
    echo "vmlinuz did not contain version: $(pwd)/$SRC_VMLINUZ"
    exit 0
fi

SRC_INITRD=initrd.img-${SRC_VER}
if [ ! -f "$SRC_INITRD" ]; then
    echo "initrd not found: $(pwd)/$SRC_INITRD"
    exit 0
fi
echo "Using vmlinuz: $SRC_VMLINUZ"
echo "Using initrd: $SRC_INITRD"

SRC_VMLINUZ="$(pwd)/$SRC_VMLINUZ"
SRC_INITRD="$(pwd)/$SRC_INITRD"
for f in $SRC_VMLINUZ $SRC_INITRD
do
    if [ ! -f "$f" ]; then
        echo "file not found: $f"
        exit 0
    fi
done

# On 18.04 grub.cfg references vmlinuz and not vmlinuz.efi
# On 18.04 live server ISO initrd is called initrd.gz and not initrd.lz!
# Find each file named vmlinuz* and initrd* and overwrite them if they
# are different from SRC_VMLINUZ and SRC_INITRD respectively

for f in ${ISO_EXTRACT_DIR}/casper/vmlinuz*
do
    SRC_FILE=$SRC_VMLINUZ
    diff --brief $SRC_FILE $f 1>/dev/null
    if [ $? -ne 0 ]; then
        \cp -f $SRC_FILE $f
        echo "replaced $(basename $f)"
    else
        echo "$(basename $f) unchanged - not overwriting"
    fi
done

for f in ${ISO_EXTRACT_DIR}/casper/initrd*
do
    SRC_FILE=$SRC_INITRD
    merge_initramfs /tmp "$f" "$SRC_INITRD" "$f"
done
exit 0


for f in ${ISO_EXTRACT_DIR}/casper/initrd*
do
    SRC_FILE=$SRC_INITRD
    diff --brief $SRC_FILE $f 1>/dev/null
    if [ $? -ne 0 ]; then
        \cp -f $SRC_FILE $f
        echo "replaced $(basename $f)"
    else
        echo "$(basename $f) unchanged - not overwriting"
    fi
done
