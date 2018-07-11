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

## Clone three of my github repos:
```
git clone --depth 1 https://github.com/sundarnagarajan/bootutils.git
git clone --depth 1 https://github.com/sundarnagarajan/rdp-thinbook-linux.git
git clone --depth 1 https://github.com/sundarnagarajan/kernel_build.git
```

I will assume that you have enough space in the filesystem where you cloned the [RDP-Thinbook-Linux](https://github.com/sundarnagarajan/rdp-thinbook-linux.git) repository.

Further the steps below assume that:
- You compile the kernel under ```rdp-thinbook-linux/kernel_compile```
- You remaster the ISO under ```rdp-thinbook-linux/ISO``` - need to create this dir

## Compile kernel 4.13+ from kernel.org
You need this kernel to get:
- Battery level and charging current sensing [Intel Whiskey Cove PMIC AXP288](https://lkml.org/lkml/2017/4/19/300)
- Realtek RTL8723bs Wifi available to enable under staging drivers - needed for Wifi as well as Bluetooth
- Get sound working with es8316 driver

### Steps
- Read more details on capabilities and configuration options for the kernel_build script in the [kernel_build README.md](https://github.com/sundarnagarajan/kernel_build/blob/master/README.md)
- The script to call is ```scripts/patch_and_build_kernel.sh``` inthe kernel_build repository
- Read [how to download, patch and compile kernel](kernel_compile.md)
- Edit a file called ```kernel_build.config``` (can be anywhere to contain the following
```
KERNEL_TYPE=stable
KERNEL_BUILD_DIR=$TOP_DIR/debs
KERNEL__NO_SRC_PKG=yes
```
- Run ```KERNEL_BUILD_CONFIG=<path/to/kernel_build.config> kernel_build/scripts/patch_and_build_kernel.sh```

It should take a while - go get a coffee. Time will depend on your machine configuration (CPU, memory, disk speed) and network speeds.

Once it completes, it should have built 4 DEB files under ```kernel_compile/debs```

Copy (or move) these DEB files to ```remaster/chroot/kernel-debs/```

## Remaster Ubuntu ISO
Read the documentation on the [ISO remastering model](ubuntu_remaster_iso.md)

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
        │   │   ├── 00_rebrand.sh
        │   │   ├── 01_install_kernels.sh
        │   │   ├── 02_remove_old_kernels.sh
        │   │   ├── 03_update_all_packages.sh
        │   │   ├── 04_install_sound.sh
        │   │   ├── 05_install_r8723_bluetooth.sh
        │   │   ├── 06_install_firmware.sh
        │   │   ├── 07_install_grub_packages.sh
        │   │   ├── 08_apt_cleanup.sh
        │   │   └── 09_copy_scripts.sh
        │   │
        │   └── kernel-debs
        │
        │
        ├── iso_post
        │   │
        │   ├── commands
        │   │   ├── 01_update_iso_kernel.sh
        │   │   ├── 02_remove_existing_grub_efi.sh
        │   │   └── 03_update_grub_efi.sh
        │   │
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

It will take a while and it should create ```ISO/out/modified.iso```

# The easy way
Just download and run ```make_rdp_iso.sh``` in the top-level of this repository in the top-level directory where you want remaster your ISO (TOP_DIR as described above)

# Write ISO to USB drive
Assuming that your USB drive is ```/dev/sdk```

```
# Change next line:
DEV=/dev/sdk
sudo dd if=${TOP_DIR}/ISO/out/modified.iso of=$DEV bs=128k status=progress oflag=direct
sync
```

Now boot into the new ISO. In the live session, everything (except sound) should just work!
