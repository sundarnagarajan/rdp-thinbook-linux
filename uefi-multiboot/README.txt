Concepts
--------

 GUID Patition Table (versus 'legacy' or 'DOS' partition table
	Making a UEFI-compatible boot disk REQUIRES creating a GUID partition
	table. To my knowledge, it is IMPOSSIBLE to make a UEFI-compatible
	boot disk with a 'legacy' or 'DOS' partition table

- EFI System Partition
	The SYSTEM BOOTLOADER (or 'EFI Applications') need to be on a partition
	of a SPECIAL PARTITION TYPE. In ADDITION, this partition needs to be
	formatted as type 'vfat' (FAT32 in Microsoft-language).

	In Linux, creating and manipulating GPT partitions requires 'gdisk'. You
	CANNOT use the traditional 'fdisk' to create ot manipulate GPT partitions.

	Using gdisk, the partition type for the EFI System Partition must be 'EF00'

- EFI System Partition layout
	TYPICALLY the EFI system partition is mounted on /boot/efi
	This is not REQUIRED - can pass the loation to grub-install with the 
	--efi-directory= parameter

	WITHIN the EFI System partition, the layout MUST be as follows:

		├── EFI                      - top of EFI System Patition
		│   └── BOOT                 - directory
		│       ├── bootia32.efi     - 32-bit EFI application
		│       └── bootx64.efi      - 64-bit EFI application
		└── HDD-Ubuntu               - directory (named EFI target)
		    ├── grubia32.efi         - 32-bit EFI application
		    └── grubx64.efi          - 64-bit EFI application


Links
=====
	-  How to Create a EFI/UEFI GRUB2 Multiboot USB drive to boot ISO images
		https://ubuntuforums.org/showthread.php?t=2276498

	   I started with this forum post and modified:
			- List of files required
			- grub.cfg





  
