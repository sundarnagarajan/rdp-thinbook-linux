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

### Things that needed BIOS settings
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
- Wifi:
- Bluetooth:
- Battery level sensing
- Battery charge / discharge rate sensing
- Battery time-to-full and time-to-empty calculation

### What is not working yet
**Everything on the RDP Thinbook now works perfectly in Linux.**
All files, scripts and documentation on this repository have been updated and tested.

This was the bug that held up sound support - fixed with es8316 driver: [Bug 189261 - Chuwi hi10/hi12 (Cherry Trail tablet) soundcard not recognised - rt5640](https://bugzilla.kernel.org/show_bug.cgi?id=189261)

# Getting Linux to rock on the RDP Thinbook
You will need about 10 GB+ free space.

## Simplified single-script method
- Download make_rdp_iso.sh from this repository
- Login to a root shell using ```sudo -i```
- Create a new directory and copy ```do_all.sh``` from this repository inside the new empty directory
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
