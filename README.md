# rdp-thinbook-linux
Linux on the [RDP Thinbook](http://www.rdp.in/thinbook/)

The RDP Thinbook is a new ultra-portable laptop produced by RDP Workstations Pvt. Ltd. in India. It is marketed as India's most affordable laptop, and is sold for around US$ 140 - 160 (when you choose the option of buying it without Windows installed).

It has [impressive specs](http://www.rdp.in/thinbook/technical-features.html):
- Intel Atom X5-Z8300 1.84 GHz CPU (Cherry Trail)
- 2 GB DDR3L RAM
- 32 GB SSD built in
- 14.1 inch 1366x768 display (16x9)
- Intel HD graphics with 12 cores (Linux-friendly)
- Realtek Wifi and bluetooth (RTL 8723bs chipset)
- 802.11 b/g/n (2.4 GHz) Wifi
- Bluetooth 4.0
- Micro-SD card slot
- 1 x USB 3.0 port
- 1x USB 2.0 port
- Audio out (3.5 mm)
- Multitouch capacitative touchpad
- Dual HD speakers
- 10000 mAh Li-polymer battery
- 5V 2A power adapter
- Rated at upto 8.5 hours battery life, 4-5 hours with Wifi connected
- Dimensions: 233mm x 351mm x 20mm
- Weight: 1.45 kgs

I bought this a few months ago without Windows installed, with the intention of using Linux on it (I use Linux on **EVERYTHNIG**).

## Experience and journey so far in brief
### Booting
Out of the box it wouldn't boot any Linux distro. This is because, like many other newer low-priced Cherry Trail laptops, the UEFI firmware has a 32-bit EFI loader. Most (all that I could find) Linux distributions only provide 64-bit UEFI-compatible ISO images. This is a MISTAKE by the upstream Linux distributions, and one that I hope to influence.

Getting it to boot wasn't very hard - it required making a multiboot disk image that was 32-bit and 64-bit EFI loader compatible.

Only additional step to boot was to turn secure boot off.

### What worked out of the box in Linux
----------------------------
- Display (Intel i915 driver) 1366x768: Works perfectly
- Touchpad:
    - Mouse pointer: Works perfectly
    - Tap-to-click: Works perfectly
    - Tap and drag (click lower left corner): Works perfectly
    - Right-click (two-finger tap): Works perfectly
    - Two-finger scroll: works perfectly
    - Right-click and drag (click lower right corner): works perfectly
    - Left button double-click (one finger double tap): works perfectly

- USB 3.0 port: works. detected as USB 3.0. Have not tested speeds
- USB 2.0 port: works

- SD Card reader: 
    - Read, write works. 
    - I believe this UEFI firmware **CANNOT** boot from miceo-SD card. It appears to be a limitation of the firmware itself - since it does not even show the **option**

- SSD: Works fine. Was seen by linux

- Blue FN button capabilities:
    - ESC: Sleep / suspend: Works to suspend
    - F2: Disable / enable touchpad: works perfectly
    - F3: Volume down: detected, OSD works. See sound card driver issue below
    - F4: Volume up: detected, OSD works. See sound card driver issue below
    - F5: Mute/Unmute: detected, OSD works. See sound card driver issue below
    - F6: Play/Pause: Not tested. See sound card driver issue below
    - F7: Previous track: Not tested. See sound card driver issue below
    - F8: Next track: Not tested. See sound card driver issue below
    - F9: Pause: Works (tested with xev)
    - F10: Insert: Works perfectly
    - F11: PrtSc: Works
    - F12: NumLock: works
    - Up: PgUp: Works perfectly
    - Down: PgDown: Works perfectly
    - Left: Home: Works perfectly
    - Right: End: Works perfectly

### Things that needed BIOS settings
- Booting: Turn off secure boot:
    UEFI --> Security --> Secure Boot menu --> Secure Boot
        Change Enabled --> Disabled

- Suspend / resume
    - UEFI --> Advanced --> ACPI Settings --> Enable ACPI Auto Configuration
        Change from Enabled --> Disabled

    - With JUST the one change above, suspend / resume works perfectly
    - Have tried with Wifi and Bluetooth audio active, on resume Wifi reconnects and audio stream resumes

    - Have **NOT** tried with USb 3.0 peripherals plugged while suspending

### Things that needed work, but which work perfectly now
- Wifi:
- Bluetooth:
- Battery level sensing
- Battery charge / discharge rate sensing
- Battery time-to-full and time-to-empty calculation

### What is not working yet
- Sound:
    - Not working (yet)
    - Seems to be fixed [kernel bug 98001](https://bugzilla.kernel.org/show_bug.cgi?id=98001)
    - Also see [kernel bug 115531](https://bugzilla.kernel.org/show_bug.cgi?id=115531)

# Getting Linux to rock on the RDP Thinbook

## Disk space requirements
You need quite a lot of disk space, because you are going to:
- Compile an upstream kernel - 3 GB or more
- Remaster an Ubuntu ISO - about 7 GB
    - Original ISO: 1.6 GB
    - Extracted ISO 3 GB+
    - Modified ISO: 1.6 GB

So you will need about 10 GB+ free space.

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
Read the documentation on the [ISO remastering model](docs/ubuntu_iso_remaster.md)

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

## Write ISO to USB drive
Assuming that your USB drive is ```/dev/sdk```

```
# Change next line:
DEV=/dev/sdk
sudo dd if=${TOP_DIR}/ISO/out/modified.iso of=$DEV bs=128k status=progress oflag=direct
sync
```

Now boot into the new ISO. In the live session, everything (except sound) should just work!
