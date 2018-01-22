#!/bin/bash
REQD_PKGS="grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common grub-common util-linux parted gdisk mount xorriso genisoimage squashfs-tools rsync git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache libfile-fcntllock-perl curl python-pexpect libelf-dev"

$(dirname $0)/pkgs_missing_from.sh $REQD_PKGS
