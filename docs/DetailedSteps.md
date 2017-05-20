# Detailed steps
## Disk space requirements
You need quite a lot of disk space, because you are going to:
- Compile an upstream kernel - 3 GB or more
- Remaster an Ubuntu ISO - about 7 GB
    - Original ISO: 1.6 GB
    - Extracted ISO 3 GB+
    - Modified ISO: 1.6 GB

## Install required packages
Run ```required_pkgs.sh``` to get a list of required packages that are missing and need to be installed.

## Clone two of my github repos:
```
git clone --depth 1 https://github.com/sundarnagarajan/bootutils.git
git clone --depth 1 https://github.com/sundarnagarajan/rdp-thinbook-linux.git
```

I will assume that you have enough space in the filesystem where you cloned the [RDP-Thinbook-Linux](https://github.com/sundarnagarajan/rdp-thinbook-linux.git) repository.

Further the steps below assume that:
- You compile the kernel under ```rdp-thinbook-linux/kernel_compile```
- You remaster the ISO under ```rdp-thinbook-linux/ISO``` - need to create this dir

## Compile the 20170518 linux-next snapshot
You need this (unreleased) kernel to get:
- Battery level and charging current sensing [Intel Whiskey Cove PMIC AXP288](https://lkml.org/lkml/2017/4/19/300)
- Realtek RTL8723bs Wifi available to enable under staging drivers - needed for Wifi as well as Bluetooth

### Steps
- Read [how to download, patch and compile kernel](docs/kernel_compile.md)
- Edit ```kernel_compile/patch_linux-next_build.sh``` to check (should be OK):
    - CONFIG_FILE
    - PATCH_FILE
- Run ```kernel_compile/patch_linux-next_build.sh```

It should take a while - go get a coffee. It takes about 12 mins on my 32-core 112GB RAM 2 GB/sec NVME HDD machine. It may take a little less or more depending on your machine and network speed.

Once it completes, it should have built 4 DEB files under ```kernel_compile```

Copy (or move) these DEB files to ```remaster/chroot/kernel-debs/```

## Remaster Ubuntu ISO
Read the documentation on the [ISO remastering model](docs/ubuntu_remaster_iso.md)

The steps below assume that you have a directory structure like this:
(only most relevant dir / files are shown)

```
Top-level dir
│
├── ISO
│   │
│   ├── in ------- put your source ISO here
│   │
│   ├── out ------ remastered ISO will be written here
│   │
│   └── extract -- source ISO will be extracted here
│
│
│
├── bootutils ----------------- cloned from github
│   │
│   └── scripts
│       └── ubuntu_remaster_iso.sh
│
└── rdp-thinbook-linux   ----- cloned form github
    │
    ├── kernel_compile
    │   ├── 0001_linux-next-rdp_bluetooth.patch
    │   ├── config.4.12
    │   └── patch_linux-next_build.sh
    │
    └── remaster
        ├── chroot
        │   │
        │   ├── commands
        │   │   ├── 01_install_firmware.sh
        │   │   ├── 02_install_kernels.sh
        │   │   ├── 03_remove_old_kernels.sh
        │   │   ├── 04_install_r8723_bluetooth.sh
        │   │   ├── 05_update_all_packages.sh
        │   │   ├── 06_install_grub_packages.sh
        │   │   ├── 07_apt_cleanup.sh
        │   │   └── 08_copy_scripts.sh
        │   │
        │   └── kernel-debs
        │
        │
        ├── iso_post
        │   │
        │   ├── commands
        │   │   ├── 01_update_iso_kernel.sh
        │   │   └── 02_update_efi.sh
        │   │
        │   └── efi
        │       ├── boot
        │       │   └── grub
        │       └── EFI
        │           └── BOOT
        └── iso_pre
            └── commands
```

### Create required dirs
```
mkdir -p ISO/in ISO/out ISO/extract
```
### Get source ISO
Grab your favorite Ubuntu flavor ISO (**only Ubuntu ISO images can be remastered for now**)

Put it under ISO/in

### Start remaster
Assuming working dir is `Top-level dir`. Change paths if your layout is different
Assuming your source ISO filename is **source.iso** and output ISO name is **modified.iso**

```
# Edit TOP_DIR to be full path to `Top-level dir`
TOP_DIR=.
R_DIR=${TOP_DIR}/rdp-thinbook-linux/remaster
INPUT_ISO=${TOP_DIR}/ISO/in/source.iso
EXTRACT_DIR=${TOP_DIR}/ISO/extract
OUTPUT_ISO=${TOP_DIR}/ISO/out/modified.iso

sudo REMASTER_CMDS_DIR=${R_DIR} ${TOP_DIR}/bootutils/scripts/ubuntu_remaster_iso.sh ${INPUT_ISO} ${EXTRACT_DIR} ${OUTPUT_ISO}
```

It will take a while (takes about 30 mins for me including updating all packages), and it should create ```ISO/out/modified.iso```

# Write ISO to USB drive
Assuming that your USB drive is ```/dev/sdk```

```
# Change next line:
DEV=/dev/sdk
sudo dd if=${TOP_DIR}/ISO/out/modified.iso of=$DEV bs=128k status=progress oflag=direct
sync
```

Now boot into the new ISO. In the live session, everything (except sound) should just work!
