#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

#EFI_DIR=${PROG_DIR}/../efi

#if [ ! -d ${EFI_DIR} ]; then
#    echo "EFI_DIR not a directory: $EFI_DIR"
#    exit 0
#fi
#EFI_DIR=$(readlink -e $EFI_DIR)

ISO_EXTRACT_DIR=${PROG_DIR}/../..
ISO_EXTRACT_DIR=$(readlink -e $ISO_EXTRACT_DIR)
#GRUB_CFG=${ISO_EXTRACT_DIR}/boot/grub/grub.cfg

#if [ -f ${GRUB_CFG} ]; then
#    \cp -f ${GRUB_CFG} ${EFI_DIR}/boot/grub/grub.cfg
#fi
# \cp -a ${EFI_DIR}/. ${ISO_EXTRACT_DIR}/.

# Create .efi files from scratch using grub-mkimage
GRUB_MODULES="ntfs hfs appleldr boot cat efi_gop efi_uga elf fat hfsplus iso9660 linux keylayouts memdisk minicmd part_apple ext2 extcmd xfs xnu part_bsd part_gpt search search_fs_file chain btrfs loadbios loadenv lvm minix minix2 reiserfs memrw mmap msdospart scsi loopback normal configfile gzio all_video efi_gop efi_uga gfxterm gettext echo boot chain eval"

mkdir -p ${ISO_EXTRACT_DIR}/EFI/BOOT
GRUB_DIR=/usr/lib/grub/i386-efi
GRUB_FORMAT=i386-efi
if [ -d $GRUB_DIR -a -f $GRUB_DIR/moddep.lst ]; then
    # GRUB_MODULES=$(for f in $(ls $GRUB_DIR/*.mod); do echo $(basename $f .mod); done)
    if [ -n "$GRUB_MODULES" ]; then
        \rm -f ${ISO_EXTRACT_DIR}/EFI/BOOT/bootia32.efi
        grub-mkimage -d $GRUB_DIR -o ${ISO_EXTRACT_DIR}/EFI/BOOT/bootia32.efi -O $GRUB_FORMAT -p /boot/grub $GRUB_MODULES
    else
        echo "No grub modules found in $GRUB_DIR"
    fi
else
    echo "grub directory or moddep.lst not found: $GRUB_DIR"
fi    

GRUB_DIR=/usr/lib/grub/x86_64-efi
GRUB_FORMAT=x86_64-efi
if [ -d $GRUB_DIR -a -f $GRUB_DIR/moddep.lst ]; then
    # GRUB_MODULES=$(for f in $(ls $GRUB_DIR/*.mod); do echo $(basename $f .mod); done)
    if [ -n "$GRUB_MODULES" ]; then
        \rm -f ${ISO_EXTRACT_DIR}/EFI/BOOT/bootx64.efi
        \rm -f ${ISO_EXTRACT_DIR}/EFI/BOOT/BOOTX64.efi
        \rm -f ${ISO_EXTRACT_DIR}/EFI/BOOT/grubx64.efi
        \rm -f ${ISO_EXTRACT_DIR}/EFI/BOOT/GRUBX64.efi
        grub-mkimage -d $GRUB_DIR -o ${ISO_EXTRACT_DIR}/EFI/BOOT/bootx64.efi -O $GRUB_FORMAT -p /boot/grub $GRUB_MODULES
        \cp ${ISO_EXTRACT_DIR}/EFI/BOOT/bootx64.efi ${ISO_EXTRACT_DIR}/EFI/BOOT/grubx64.efi
    else
        echo "No grub modules found in $GRUB_DIR"
    fi
else
    echo "grub directory or moddep.lst not found: $GRUB_DIR"
fi    
