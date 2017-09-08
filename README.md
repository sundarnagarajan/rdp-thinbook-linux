# rdp-thinbook-linux
Linux on the [RDP Thinbook](http://www.rdp.in/thinbook/)

The RDP Thinbook is a new ultra-portable laptop produced by RDP Workstations Pvt. Ltd. in India. It is marketed as India's most affordable laptop, and is sold for around US$ 140 - 160 (when you choose the option of buying it without Windows installed).

# EVERYTHING on this laptop works perfectly in Linux

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

- Webcam: works (tested with Cheese)

- USB 3.0 port: works. detected as USB 3.0. Have not tested speeds
- USB 2.0 port: works

- SD Card reader: 
    - Read, write works. 
    - I believe this UEFI firmware **CANNOT** boot from miceo-SD card. It appears to be a limitation of the firmware itself - since it does not even show the **option**

- SSD: Works fine. Was seen by linux

- Blue FN button capabilities:
    - ESC: Sleep / suspend: Works to suspend
    - F2: Disable / enable touchpad: works perfectly
    - F3: Volume down: works perfectly
    - F4: Volume up: works perfectly
    - F5: Mute/Unmute: works perfectly
    - F6: Play/Pause: works perfectly
    - F7: Previous track: works perfectly
    - F8: Next track: works perfectly
    - F9: Pause: Works (tested with xev)
    - F10: Insert: Works perfectly
    - F11: PrtSc: Works
    - F12: NumLock: works
    - Up: PgUp: Works perfectly
    - Down: PgDown: Works perfectly
    - Left: Home: Works perfectly
    - Right: End: Works perfectly

### UEFI (BIOS) settings that need to be changed
- Booting: Turn off secure boot:
    UEFI --> Security --> Secure Boot menu --> Secure Boot
        Change Enabled --> Disabled

- Suspend / resume
    - UEFI --> Advanced --> ACPI Settings --> Enable ACPI Auto Configuration
        Change from Enabled --> Disabled

    - With JUST the one change above, suspend / resume works perfectly
    - Have tried with Wifi and Bluetooth audio active, on resume Wifi reconnects and audio stream resumes

    - Have **NOT** tried with USB 3.0 peripherals plugged while suspending

- Sound
    - UEFI --> Chipset --> Audio Configuration --> LPE Audio Support
        Set to ```LPE Audio ACPI mode`` (default setting)

### Things that needed work, but which work perfectly now
- Wifi
- Bluetooth
- Battery level sensing
- Battery charge / discharge rate sensing
- Battery time-to-full and time-to-empty calculation
- Sound: Speakers and headphone jack both work. Microphone (sound recording) works

### What is not working yet
**Everything on the RDP Thinbook now works perfectly in Linux.**

All files, scripts and documentation on this repository have been updated and tested.

This was the bug that held up sound support - fixed with es8316 driver: [Bug 189261 - Chuwi hi10/hi12 (Cherry Trail tablet) soundcard not recognised - rt5640](https://bugzilla.kernel.org/show_bug.cgi?id=189261)

# Getting Linux to rock on the RDP Thinbook
You will need about 10 GB+ free space.

## Make UEFI (BIOS) changes
### Entering UEFI
- Reboot the RDP Thinbook
- When the RDP symbol appears on screen, press **ESCAPE**
### UEFI (BIOS) changes required
- UEFI --> Security --> Secure Boot menu --> Secure Boot
    Change Enabled --> Disabled

- UEFI --> Advanced --> ACPI Settings --> Enable ACPI Auto Configuration
    Change from Enabled --> Disabled
- UEFI --> Chipset --> Audio Configuration --> LPE Audio Support
    Set to ```LPE Audio ACPI mode`` (default setting)

## Simplified single-script method
- Download [make_rdp_iso.sh](https://github.com/sundarnagarajan/rdp-thinbook-linux/blob/master/make_rdp_iso.sh) from this repository
- Login to a root shell using ```sudo -i```
- Create a new directory and copy ```make_rdp_iso.sh``` from this repository inside the new empty directory
- cd to the new directory
- mkdir -p ISO/in ISO/out
- Copy your favorite Ubuntu flavor ISO to ISO/in/source.iso (**filename is important**)
- run sudo ./make_rdp_iso.sh

## Write ISO to USB drive
Assuming that your USB drive is ```/dev/sdk```

```
# Change next line:
DEV=/dev/sdk
sudo dd if=${TOP_DIR}/ISO/out/modified.iso of=$DEV bs=128k status=progress oflag=direct
sync
```

Now boot into the new ISO. In the live session, everything (except sound) should just work!

To know more about the steps involved, read [DetailedSteps.md](docs/DetailedSteps.md)

# What do you get
- Everything listed as working above **WORK IN THE LIVE SESSION**
- If you install from the Ubuntu ISO created, everything listed as working will work in the installed image also
- You get a copy of all the scripts under ```/root/remaster/scripts```
- The log of all steps during remastering is in ```/root/remaster/remaster.log```

# Sample output of make_rdp_iso.sh
```
All required packages are already installed
Required packages:
    grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common
    grub-common util-linux parted gdisk mount xorriso genisoimage
    squashfs-tools rsync git build-essential kernel-package fakeroot
    libncurses5-dev libssl-dev ccache libfile-fcntllock-perl

Required space: 10000000000
Available space: 17490198528

Cloning bootutils...
Cloning rdp-thinbook-linux...
INFO: Using 32 threads
INFO: Hiding stderr output from kernel build
Retrieve kernel source start           : Wed Sep  6 20:34:58 PDT 2017
Retrieve kernel source finished        : Wed Sep  6 20:35:25 PDT 2017 (00:00:27)
INFO: Building kernel 4.13.0 in /home/sundar/rdp/kernel_compile/debs/linux-4.13
Applying patches from /home/sundar/rdp/kernel_compile/./all_rdp_patches.patch
    patching file net/rfkill/rfkill-gpio.c
    Hunk #1 succeeded at 160 (offset -3 lines).
INFO: Restored config: seems to be from version 4.13.0
Kernel build start                     : Wed Sep  6 20:35:27 PDT 2017
Kernel bzImage build finished          : Wed Sep  6 20:36:44 PDT 2017 (00:01:17)
Kernel modules build finished          : Wed Sep  6 20:42:46 PDT 2017 (00:06:02)
Kernel deb build finished              : Wed Sep  6 20:46:10 PDT 2017 (00:03:24)
-------------------------- Kernel compile time -------------------------------
Retrieve kernel source start           : Wed Sep  6 20:34:58 PDT 2017
Retrieve kernel source finished        : Wed Sep  6 20:35:25 PDT 2017 (00:00:27)
Kernel build start                     : Wed Sep  6 20:35:27 PDT 2017
Kernel bzImage build finished          : Wed Sep  6 20:36:44 PDT 2017 (00:01:17)
Kernel modules build start             : Wed Sep  6 20:36:44 PDT 2017
Kernel modules build finished          : Wed Sep  6 20:42:46 PDT 2017 (00:06:02)
Kernel deb build start                 : Wed Sep  6 20:42:46 PDT 2017
Kernel deb build finished              : Wed Sep  6 20:46:10 PDT 2017 (00:03:24)
Kernel build finished                  : Wed Sep  6 20:46:10 PDT 2017
------------------------------------------------------------------------------
Kernel DEBS: (in /home/sundar/rdp/kernel_compile/debs)
    linux-firmware-image-4.13.0_4.13.0-1_amd64.deb
    linux-headers-4.13.0_4.13.0-1_amd64.deb
    linux-image-4.13.0_4.13.0-1_amd64.deb
    linux-libc-dev_4.13.0-1_amd64.deb
------------------------------------------------------------------------------
(extract_iso): Extracting ISO ... source.iso
(extract_iso): Completed
(extract_squashfs): Extracting squashfs <-- filesystem.squashfs
(extract_squashfs): Completed
01_install_firmware.sh [chroot]: Starting
    '/remaster_tmp/firmware/./rtlwifi/rtl8723bs_nic.bin' -> '/lib/firmware/./rtlwifi/rtl8723bs_nic.bin'
01_install_firmware.sh [chroot]: Completed
02_install_kernels.sh [chroot]: Starting
    update-initramfs: Generating /boot/initrd.img-4.13.0
    New kernel packages installed:
        linux-firmware-image-4.13.0
        linux-headers-4.13.0
        linux-image-4.13.0
        linux-libc-dev
02_install_kernels.sh [chroot]: Completed
03_remove_old_kernels.sh [chroot]: Starting
    Removing following packages:
        linux-image-4.4.0-31-generic
        linux-image-extra-4.4.0-31-generic
        linux-image-generic
        linux-headers-4.4.0-31
        linux-headers-4.4.0-31-generic
        linux-headers-generic
        linux-signed-image-generic
        linux-generic
    Kernel-related packages remaining:
        linux-headers-4.13.0
        linux-image-4.13.0
03_remove_old_kernels.sh [chroot]: Completed
04_install_es8316_sound.sh [chroot]: Starting
    '/root/hardware/sound/bytcht-es8316' -> '/usr/share/alsa/ucm/bytcht-es8316'
    '/root/hardware/sound/bytcht-es8316/HiFi' -> '/usr/share/alsa/ucm/bytcht-es8316/HiFi'
    '/root/hardware/sound/bytcht-es8316/bytcht-es8316.conf' -> '/usr/share/alsa/ucm/bytcht-es8316/bytcht-es8316.conf'
    '/root/hardware/sound/rdp-es8316.conf' -> '/etc/modprobe.d/rdp-es8316.conf'
04_install_es8316_sound.sh [chroot]: Completed
05_install_r8723_bluetooth.sh [chroot]: Starting
    
    ---------------------------------------------------------------------------
    Making r8723bs Bluetooth work
    
    Most of this is from https://github.com/lwfinger/rtl8723bs_bt.git
    This source is licensed under the same terms as the original.
    If there is no LICENSE specified by the original author, this
    source is hereby licensed under the GNU General Public License version 2.
    
    See /root/hardware/LICENSE and for license details
    See /root/hardware/bluetooth/rtl8723bs_bt/LICENSE and for license details
    ---------------------------------------------------------------------------
    
    '/root/hardware/bluetooth/scripts/bluetooth_r8723bs.rules' -> '/etc/udev/rules.d/bluetooth_r8723bs.rules'
    '/root/hardware/bluetooth/scripts/r8723bs_bluetooth.service' -> '/etc/systemd/system/r8723bs_bluetooth.service'
    '/etc/systemd/system/bluetooth.service.wants/r8723bs_bluetooth.service' -> '/etc/systemd/system/r8723bs_bluetooth.service'
05_install_r8723_bluetooth.sh [chroot]: Completed
06_update_all_packages.sh [chroot]: Starting
Extracting templates from packages: 100%
06_update_all_packages.sh [chroot]: Completed
07_install_grub_packages.sh [chroot]: Starting
07_install_grub_packages.sh [chroot]: Completed
08_apt_cleanup.sh [chroot]: Starting
    Reading package lists...
    Building dependency tree...
    Reading state information...
    Reading package lists...
    Building dependency tree...
    Reading state information...
    0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
08_apt_cleanup.sh [chroot]: Completed
09_copy_scripts.sh [chroot]: Starting
09_copy_scripts.sh [chroot]: Completed
01_update_iso_kernel.sh [iso_post]: Starting
01_update_iso_kernel.sh [iso_post]: Completed
02_update_efi.sh [iso_post]: Starting
02_update_efi.sh [iso_post]: Completed
(run_remaster_commands): Completed
(update_squashfs): Creating squashfs --> filesystem.squashfs
(update_squashfs): Completed
(update_iso): Creating ISO ... /home/sundar/rdp/ISO/out/modified.iso
(update_iso): Creating MBR- and EFI-compatible ISO
(update_iso): Completed

--------------------------------------------------------------------------
Source ISO=/home/sundar/rdp/ISO/in/source.iso
Output ISO=/home/sundar/rdp/ISO/out/modified.iso
VolID=Ubuntu-MATE 16.04.1 LTS amd64

--------------------------------------------------------------------------

Start: Wed Sep  6 20:34:54 PDT 2017
Ended: Wed Sep  6 20:57:21 PDT 2017
```
