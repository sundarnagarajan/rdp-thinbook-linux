#!/bin/bash
# To see look devices use the command: losetup -l

# Expected max TOTAL size of EFI files in bytes
NEW_EFI_IMG_SIZE_BYTES=3145728

# List of grub modules to build into EFI images
# Module names should NOT have '.mod' ending!
GRUB_BUILTIN_MODLIST="iso9660 memdisk extcmd search search_fs_file minix normal configfile"
GRUB_REMOVE_MODULES="affs.mod afs.mod extcmd.mod fshelp.mod functional_test.mod hello.mod nilfs2.mod search_fs_file.mod search_fs_uuid.mod search_label.mod search.mod sfs.mod tar.mod zfsinfo.mod zfs.mod"

# grub prefix - used with grub-mkimage
GRUB_PREFIX="/boot/grub"

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)


SCRIPT_DIR=${PROG_DIR}

# All changes happen in GRUB_DIR
GRUB_DIR=${ISO_EXTRACT_DIR}/boot/grub

# All mounts happen in MOUNT_DIR
MOUNT_DIR=${GRUB_DIR}

# original image filename as it is in the ISO
# JUST the filename - without full path
OLD_IMG_FILE=efi.img

# (Temporary) new image filename - should be different from OLD_IMG_FILE
# JUST the filename - without full path
NEW_IMG_FILE=new.img

# Mount point under SCRIPT_DIR for existing image
# JUST the directory name - without full path
# This directory will be DELETED and re-created
MOUNT_OLD_DIR=old

# Mount point under SCRIPT_DIR for NEW image
# JUST the directory name - without full path
# This directory will be DELETED and re-created
MOUNT_NEW_DIR=new

# ------------------------------------------------------------------------
# Should not have to change anything below this
# ------------------------------------------------------------------------

OLD_IMG_FILE=${GRUB_DIR}/$(basename ${OLD_IMG_FILE})
NEW_IMG_FILE=${GRUB_DIR}/$(basename ${NEW_IMG_FILE})
MOUNT_OLD_DIR=$MOUNT_DIR/$(basename ${MOUNT_OLD_DIR})
MOUNT_NEW_DIR=$MOUNT_DIR/$(basename ${MOUNT_NEW_DIR})

function exit_if_not_root {
    if [ $(id -u) -ne 0 ]; then
        echo "Need to be root" 
        exit 1
    fi      
}
  

function setup_loop_dev {
    # $1: Path to file to use for loop device
    # Outputs loop device path on stdout
    local local_loopdev=$(losetup -f)
    if [ -z "$local_loopdev" ]; then
        return
    fi
    losetup -f $1
    if [ $? -eq 0 ]; then
        echo $local_loopdev
    fi
}

function tear_down_loop_dev {
    # $1: full path to loop device - e.g. /dev/loop0
    losetup --noheadings -l | awk '{print $1}' | fgrep -xq $1
    if [ $? -ne 0 ]; then
        return 1
    fi
    losetup -d $1 2>/dev/null
    sleep 2
    return $?
}

function create_1_efi_file {
    # Creates a single EFI type of the desired format
    # $1: EFI/BOOT Directory
    # $2: format: must be either i386-efi or x86_64-efi
    # $3: /boot/grub directory - to delete built-in modules
    if [ -z "$1" -o ! -d "$1" ]; then
        echo "Invalid EFI directory: $1"
        return 1
    fi
    local efi_directory=$1
    local grub_format=$2
    local boot_grub_dir=$3
    local efi_filename=""
    local grub_embedded_cfg=${boot_grub_dir}/grub_embedded.cfg

    case $grub_format in
        i386-efi)
            efi_filename=bootia32.efi
            ;;
        x86_64-efi)
            efi_filename=bootx64.efi
            ;;
        *)
            echo "Invalid format: $grub_format"
            return 1
    esac
    echo "Creating EFI image: $efi_filename"

    \rm -f $grub_embedded_cfg
    echo 'set root=(hd0)' > $grub_embedded_cfg
    echo 'set prefix=/boot/grub' >> $grub_embedded_cfg
    echo 'normal' >> $grub_embedded_cfg
    grub-mkimage --prefix=$GRUB_PREFIX --format=$grub_format --config=$grub_embedded_cfg --output=${efi_directory}/${efi_filename} ${GRUB_BUILTIN_MODLIST}
    if [ $? -ne 0 ]; then
        echo "grub-mkimage failed"
        return 1
    fi
    \rm -f $grub_embedded_cfg

    # Delete builtin modules
    if [ -n "$boot_grub_dir" -a -d "${boot_grub_dir}/${grub_format}" ]; then
        for m in $GRUB_BUILTIN_MODLIST
        do
            \rm -f ${boot_grub_dir}/${grub_format}/$(basename $m .mod)
        done
    fi
}

function create_reqd_efi_files {
    # Creates any missing EFI files - does not overwrite existing files
    # $1: EFI/BOOT Directory
    # $2: /boot/grub directory - to delete built-in modules
    if [ -z "$1" -o ! -d "$1" ]; then
        echo "Invalid EFI directory: $1"
        return 1
    fi
    local efi_directory=$1
    local boot_grub_dir=$2

    if [ -f "${efi_directory}/bootx64.efi" ]; then
        echo "bootx64.efi already exists: ${efi_directory}/bootx64.efi"
    else
        create_1_efi_file ${efi_directory} x86_64-efi "$boot_grub_dir"
        if [ $? -ne 0 ]; then
            echo "FAILED: create_1_efi_file ${efi_directory} x86_64-efi $boot_grub_dir"
            return 1
        fi
    fi
    if [ -f "${efi_directory}/grubx64.efi" ]; then
        echo "grubx64.efi already exists: ${efi_directory}/grubx64.efi"
    else
        echo "Creating grubx64.efi"
        cp ${efi_directory}/bootx64.efi ${efi_directory}/grubx64.efi
    fi
    if [ -f "${efi_directory}/bootia32.efi" ]; then
        echo "bootia32.efi already exists: ${efi_directory}/bootia32.efi"
    else
        create_1_efi_file ${efi_directory} i386-efi "$boot_grub_dir"
        if [ $? -ne 0 ]; then
            echo "FAILED: create_1_efi_file ${efi_directory} i386-efi $boot_grub_dir"
            return 1
        fi
    fi
}
function create_1_grub_module_dir {
    # Creates one grub module dir of the desired format
    # $1: /boot/grub directory
    # $2: format: must be either i386-efi or x86_64-efi
    if [ -z "$1" -o ! -d "$1" ]; then
        echo "Invalid EFI directory: $1"
        return 1
    fi
    local boot_grub_dir=$1
    local grub_format=$2
    local template_dir=""

    case $grub_format in
        i386-efi)
            template_dir=${boot_grub_dir}/x86_64-efi
            ;;
        x86_64-efi)
            template_dir=${boot_grub_dir}/i386-efi
            ;;
        *)
            echo "Invalid format: $grub_format"
            return 1
    esac
    local grub_src_dir=/usr/lib/grub/${grub_format}
    local target_dir=${boot_grub_dir}/${grub_format}
    if [ ! -d "$grub_src_dir" ]; then
        echo "Directory not found: $grub_src_dir"
        return 1
    fi
    echo "Emptying and creating grub module dir: $target_dir"
    find ${target_dir} -exec rm -rf {} \; 2>/dev/null
    mkdir -p $target_dir

    if [ -d "${template_dir}" ]; then
        echo "Copying from template_dir: $template_dir"
        for f in $template_dir/*.mod $template_dir/*.lst $template_dir/grub.cfg
        do
            local fn=$(basename $f)
            if [ -f $grub_src_dir/$fn ]; then
                \cp -f $grub_src_dir/$fn $target_dir/
            fi
        done
        if [ -f "$template_dir/grub.cfg" ]; then
            \cp -f $template_dir/grub.cfg $target_dir/
        fi
    else
        echo "Copying from grub_src_dir: $grub_src_dir"
        # Only copy .mod and .lst
        \cp -fa $grub_src_dir/*.mod $target_dir/
        \cp -fa $grub_src_dir/*.lst $target_dir/
        # Remove some modules that are not normally present
        for m in $GRUB_REMOVE_MODULES
        do
            \rm -f  $target_dir/$m
        done
    fi
}

function create_reqd_grub_module_dirs {
    # Creates missing grub module dirs (x86_64-efi or i386-efi only)
    # $1: /boot/grub Directory
    #
    # If either x86_64-efi or i386-efi directory exists, the other
    # directory is created using existing one as a template
    # If NEITHER exists, both are created from corresponding directory
    # under /usr/lib/grub with ALL modules
    # For any EFI images that we create, modules built into the EFI
    # image will be automatically deleted from corresponding dir
    # When EFI image is created
    #
    # If either directory exists, but is populated incompletely or
    # is empty, no attempt is made to correct

    if [ -z "$1" -o ! -d "$1" ]; then
        echo "Invalid grub directory: $1"
        return 1
    fi
    local grub_dir=$1

    if [ -d $grub_dir/x86_64-efi ]; then
        if [ -d $grub_dir/i386-efi ]; then
            echo "All grub module directories exist"
        else
            create_1_grub_module_dir $grub_dir i386-efi || return 1
            if [ $? -ne 0 ]; then
                echo "FAILED: create_1_grub_module_dir $grub_dir i386-efi"
                return 1
            fi
        fi
    elif [ -d $grub_dir/i386-efi ]; then
        create_1_grub_module_dir $grub_dir x86_64-efi || return 1
        if [ $? -ne 0 ]; then
            echo "FAILED: create_1_grub_module_dir $grub_dir x86_64-efi"
            return 1
        fi
    else
        create_1_grub_module_dir $grub_dir x86_64-efi
        if [ $? -ne 0 ]; then
            echo "FAILED: create_1_grub_module_dir $grub_dir x86_64-efi"
            return 1
        fi
        create_1_grub_module_dir $grub_dir i386-efi
        if [ $? -ne 0 ]; then
            echo "FAILED: create_1_grub_module_dir $grub_dir i386-efi"
            return 1
        fi
    fi
}

function cleanup_mounts_loopdevs {
    echo "Cleaning up mounts and loop devices"
    if [ -n "$MOUNT_OLD_DIR" -a -d "$MOUNT_OLD_DIR" ]; then
        umount $MOUNT_OLD_DIR 2>/dev/null
        \rm -rf "$MOUNT_OLD_DIR"
    fi
    if [ -n "$MOUNT_NEW_DIR" -a -d "$MOUNT_NEW_DIR" ]; then
        umount $MOUNT_NEW_DIR 2>/dev/null
        \rm -rf "$MOUNT_NEW_DIR"
    fi

    if [ -n "$OLD_LOOPDEV" ]; then
        tear_down_loop_dev $OLD_LOOPDEV
    fi
    if [ -n "$NEW_LOOPDEV" ]; then
        tear_down_loop_dev $NEW_LOOPDEV
    fi
}

function all_efi_files_present {
    # $1: EFI/BOOT Directory
    if [ -z "$1" -o ! -d "$1" ]; then
        echo "Invalid EFI directory: $1"
        return 1
    fi
    local efi_directory=$1
    local old_pwd=$(readlink -f $(pwd))
    local efi_files="BOOTIA32.EFI BOOTX64.EFI GRUBX64.EFI"
    local efi_files_present=""

    cd $efi_directory
    for f in $efi_files
    do
        found_1="$(find . -iname $f | sed -e 's/^\.\///')"
        echo "$found_1" | fgrep -qxi "${f}"
        if [ $? -ne 0 ]; then
            cd $old_pwd
            echo "Missing EFI file: $f"
            return 1
        fi
        efi_files_present="$efi_files_present $found_1"
    done

    cd $old_pwd
    echo "All required EFI files already present:$efi_files_present"
    return 0
}
# ------------------------------------------------------------------------
# Main program starts after this
# ------------------------------------------------------------------------

exit_if_not_root
trap cleanup_mounts_loopdevs EXIT

if [ -f "$OLD_IMG_FILE" ]; then
    IMG_FOUND=yes

    OLD_LOOPDEV=$(setup_loop_dev $OLD_IMG_FILE)
    \rm -rf "$MOUNT_OLD_DIR"; mkdir -p "$MOUNT_OLD_DIR"
    mount $OLD_LOOPDEV "$MOUNT_OLD_DIR"
    if [ $? -ne 0 ]; then
        echo "Could not mount $OLD_LOOPDEV on $MOUNT_OLD_DIR"
        exit 1
    fi
    # We don't need a new image if all EFI files are already present
    EFI_BOOT_DIR=$(find ${MOUNT_OLD_DIR} -ipath ${MOUNT_OLD_DIR}/EFI/BOOT)
    all_efi_files_present "$EFI_BOOT_DIR" && EFI_FILES_OK=yes || EFI_FILES_OK=no
else
    IMG_FOUND=no
    EFI_FILES_OK=no
fi


if [ "$EFI_FILES_OK" = "no" ]; then
    NEW_SIZE=$NEW_EFI_IMG_SIZE_BYTES
    echo "Creating new image: $NEW_IMG_FILE"
    # Avoid oflag=direct in case we are using tmpfs
    dd if=/dev/zero of=$NEW_IMG_FILE bs=$NEW_SIZE count=1 status=progress 2>/dev/null

    NEW_LOOPDEV=$(setup_loop_dev $NEW_IMG_FILE)
    mkfs.vfat $NEW_LOOPDEV 1>/dev/null

    \rm -rf "$MOUNT_NEW_DIR"; mkdir -p "$MOUNT_NEW_DIR"
    mount $NEW_LOOPDEV "$MOUNT_NEW_DIR"

    if [ "$IMG_FOUND" = "yes" ]; then
        cp -a $MOUNT_OLD_DIR/. $MOUNT_NEW_DIR/.
        umount $MOUNT_OLD_DIR
        tear_down_loop_dev $OLD_LOOPDEV
    else
        mkdir -p $MOUNT_NEW_DIR/efi/boot
    fi
fi

create_reqd_grub_module_dirs "$GRUB_DIR" || exit 1

if [ "$EFI_FILES_OK" = "no" ]; then
    EFI_BOOT_DIR=$(find ${MOUNT_NEW_DIR} -ipath ${MOUNT_NEW_DIR}/EFI/BOOT)
    if [ -z "$EFI_BOOT_DIR" ]; then
        mkdir -p ${EFI_BOOT_DIR}
    fi
    create_reqd_efi_files "$EFI_BOOT_DIR" "$GRUB_DIR"
    echo "Space remaining in new image: $(df -B1 $MOUNT_NEW_DIR | sed -e '1d' | awk '{print $4}') bytes"

    umount $MOUNT_NEW_DIR
    tear_down_loop_dev $NEW_LOOPDEV

    # Replace OLD_IMG_FILE with NEW_IMG_FILE
    \rm -f $OLD_IMG_FILE
    mv $NEW_IMG_FILE $OLD_IMG_FILE
fi
