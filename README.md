# rdp-thinbook-linux
Linux on the [RDP Thinbook](http://www.rdp.in/thinbook/)

The RDP Thinbook is a new ultra-portable laptop produced by RDP Workstations Pvt. Ltd. in India. It is marketed as India's most affordable laptop, and is sold for around US$ 140 - 160 (when you choose the option of buying it without Windows installed).

# EVERYTHING on this laptop works perfectly in Linux

It has [impressive specs](http://www.rdp.in/thinbook/technical-features.html):
- CPU, Memory, storage:
    - Original Thinbook shipped with Intel Atom X5-Z8300 1.84 GHz CPU (Cherry Trail). Later models ship with Intel Atom X5-Z8350 1.92 GHz CPU (Cherry Trail)
    - 2 GB DDR3L RAM
    - 32 GB SSD built in
    - Micro-SD card slot
- Display:
    - Original Thinbook shipped with 14.1 inch 1366x768 display (16x9). Later the 11.6 inch 1366x768 display (16x9) model was added
    - Intel HD graphics with 12 cores (Linux-friendly)
- Networking:
    - 802.11 b/g/n (2.4 GHz) Wifi - Realtek Wifi and bluetooth (RTL 8723bs chipset)
    - Bluetooth 4.0
- USB:
    - 1 x USB 3.0 port
    - 1x USB 2.0 port
- Audio:
    - Audio out (3.5 mm)
    - Dual HD speakers
- Multitouch capacitative touchpad
- Power:
    - 10000 mAh Li-polymer battery
    - 5V 2A power adapter
    - Rated at upto 8.5 hours battery life, 4-5 hours with Wifi connected
- Size, weight:
    - Dimensions: 233mm x 351mm x 20mm
    - Weight: 1.45 kgs

## Other cool features:
- Power supply is 5V/2A, so (if) you can make your own USB cable with a compatible barrel adapter, you can charge / power it from a 2A USB wall power supply, or even a good Power Bank! I plan to do this, so wahct this repo for results and instructions once I do
- TPM 2.0 - haven't played with it yet

## Limitations
- RAM (2 GB) is soldered on, cannot be replaced / expanded
- SSD (32 GB) is soldered on, cannot be replaced / expanded
- Battery charging / charged and suspend state LED is not visible when the top is closed
- Home, End, PgUp, PgDn keys are accessed using Fn-Arrow keys
- No dedicated numeric keypad
- No special keys to control screen brightness. BUT screen brightness applet in Ubuntu works **perfectly**

I bought the original 14.1 inch RDP Thinbook in Nov-2016 without Windows installed, with the intention of using Linux on it (I use Linux on **EVERYTHNIG**).

# Getting Linux to rock on the RDP Thinbook
You will need a machine running a recent version of Ubuntu (tested on Ubuntu 16.04.3 Xenial Xerus LTS). 

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

## Get or build a remastered ISO with linux kernel 4.13 (or newer)
I highly recommend you use the **Simplified single-script method** below to download and build your own kernel and remaster the ISO yourself. Downloading and using / installing ISOs created by people you do not know or trust is **BAD SECURITY PRACTICE**.

That said, many people provide pre-built ISOs for users to eaily try / use, and I have provided one too. I **try** to mitigate **some** of your risk by providing a GPG signature.

Remastering your own ISO can take a while. It takes about 30 mins on a 32 x Intel Xeon e5-2670 server with 112GB of RAM and a Sansung 960 EVO NVME disk. On a more 'standard desktop' machine it could take several hours. You will need about 10 GB+ free space to build the kernel and remaster the ISO. 

### Simplified single-script method
You will need about 10 GB+ free space to build the kernel and remaster the ISO.

Download [make_rdp_iso.sh](https://github.com/sundarnagarajan/rdp-thinbook-linux/blob/master/make_rdp_iso.sh) from this repository

#### Packages required
    grub-efi-ia32-bin grub-efi-amd64-bin grub-pc-bin grub2-common
    grub-common util-linux parted gdisk mount xorriso genisoimage
    squashfs-tools rsync git build-essential kernel-package fakeroot
    libncurses5-dev libssl-dev ccache libfile-fcntllock-perl

For the most up-to-date list of required packages:
    - Download make_rdp_iso.sh from this directory
    - Run './make_rdp_iso.sh' (no need to be root)
    - Follow the instructions to install missing packages, if any

- Login to a root shell using ```sudo -i```
- Create a new directory and copy ```make_rdp_iso.sh``` from this repository inside the new empty directory
- cd to the new directory
- mkdir -p ISO/in ISO/out
- Copy your favorite Ubuntu flavor ISO to ISO/in/source.iso (**filename is important**)

Your directory structure should look like this:
```
new_dir  ---------- TOPLEVEL DIR
│
├── make_rdp_iso.sh
│
└── ISO
    ├── in
    │   │
    │   └── source.iso  - you need to rename source ISO to 'source.iso'
    │
    └─── out
```
Run the following command to create the remastered ISO:
```
sudo ./make_rdp_iso.sh
```

Remastered ISO will be ```ISO/out/modified.iso```


### Alternative - download pre-built remastered ISO for RDP Thinbook
Use this method **ONLY** if you are willing to trust my pre-compiled kernel and remastered ISO (at least on a test machine). You will need about 2GB free disk space to download the ISO. 

Note: **DO NOT** rely on the **same** ISO being available and linked from this github repo. Periodically, as new kernels come out, I intend to test and update the ISOs I link to from here.

[Available ISOs](https://drive.google.com/drive/folders/0ByKDyYCckXqDQmN2emE4M1V1NlE):

| ISO | Signature |
| --- | --------- |
| [Ubuntu Mate 16.04 with kernel 4.13.1](https://drive.google.com/file/d/0ByKDyYCckXqDUk9GRlJJM3NsREU/view?usp=sharing) | [GPG Signature](https://drive.google.com/file/d/0ByKDyYCckXqDTDAyREZIRVRtWEE/view?usp=sharing) |
| [Ubuntu 16.04.3 with kernel 4.13.1](https://drive.google.com/open?id=0ByKDyYCckXqDbFV2X3lydVYzdzQ) | [GPG Signature](https://drive.google.com/open?id=0ByKDyYCckXqDQjhfbHEyZ3FhSnM) |
| [xubuntu 16.04.3 with kernel 4.13.1](https://drive.google.com/open?id=0ByKDyYCckXqDamNoazNIVm5JYU0) | [GPG Signature](https://drive.google.com/open?id=0ByKDyYCckXqDdXpVbGpjNDQxTXc) |

    
Download both the ISO and the signature (```.sign``` file). Use the following command to verify the GPG signature **BEFORE** using the ISO

```
gpg --verify <signature_file> <ISO_file>
```

The output should be something like:

```
gpg: Signature made Sun 10 Sep 2017 08:49:50 PM PDT using RSA key ID 857CADBD
```

You can find my GPG public key [here](https://pgp.mit.edu/pks/lookup?op=get&search=0xDF2AC095857CADBD). If you want to add my public key to your GPG keychain, use the following command:
```
gpg --keyserver pgp.mit.edu --recv-keys F0C3CE69C8C00D1E4D8834F5DF2AC095857CADBD
```

Once you have imported my public key with the command above (note: you are **not TRUSTING** my public key for anything), if you rerun the ```gpg --verify``` command above, the output should look like:
```
gpg: Signature made Sun 10 Sep 2017 08:49:50 PM PDT using RSA key ID 857CADBD
gpg: Good signature from "Sundar Nagarajan <sun.nagarajan@gmail.com>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: F0C3 CE69 C8C0 0D1E 4D88  34F5 DF2A C095 857C ADBD
```

The message ```This key is not certified with a trusted signature!``` is because you have not attached any level of 'trust' to my public key. That should be OK for this purpose.

Once you have verified the signature, you can delete my public key using the command, to avoid cluttering your keyring:
```
gpg --yes --delete-key F0C3CE69C8C00D1E4D8834F5DF2AC095857CADBD
```

For a **weak** indication that this key belongs to me, search for me on [pgp.mit.edu](https://pgp.mit.edu/). Enter my email ```sun.nagarajan@gmail.com``` in the ```Search string``` field, and you should find this key as one of the results.

## Write ISO to USB drive
Assuming that your USB drive is ```/dev/sdk``` and you downloaded to a filenamed ```modified.iso```

```
# cd to the directory containing the ISO
# DOUBLE CHECK that DEV is set to your removable devices' name
# Change next line:
DEV=/dev/sdk
sudo dd if=modified.iso of=$DEV bs=128k status=progress oflag=direct
sync
```

Now boot into the new ISO. In the live session, everything should just work!

To know more about the steps involved, read [DetailedSteps.md](docs/DetailedSteps.md)

# What do you get
- Everything listed as working above **WORK IN THE LIVE SESSION**
- If you install from the Ubuntu ISO created, everything listed as working will work in the installed image also
- You get a copy of all the scripts under ```/root/remaster/scripts```
- The log of all steps during remastering is in ```/root/remaster/remaster.log```

# Distributions, models, testing done
If you have tested a distribution-model not listed here, open an issue, and I will list your observations here. If you had problems with a distribution (Ubuntu-based only for now), open an issue.

| Distribution | RDP Thinbook Model | Issues, if any | Tested by |
| ------------ | ------------------ | -------------- | --------- |
| Ubuntu Mate 16.04 | Original 14.1-inch RDP Thinbook (X5-Z8300) | None | Me |
| Ubuntu Mate 16.04 | New 14.1-inch RDP Thinbook (X5-Z8350) | None | RDP staff |
| Ubuntu Mate 16.04 | 11.6-inch RDP Thinbook (X5-Z8350) | None | RDP staff |
| Ubuntu 16.04.3 | Original 14.1-inch RDP Thinbook (X5-Z8300) | Bluetooth issues - investigating | Me |
| xubuntu 16.04.3 | Original 14.1-inch RDP Thinbook (X5-Z8300) | None | Me |

# Problems?
- Read the [FAQ](faq.md)
- Open an issue

# Journey so far in brief
## Booting
Out of the box it wouldn't boot any Linux distro. This is because, like many other newer low-priced Cherry Trail laptops, the UEFI firmware has a 32-bit EFI loader. Most (all that I could find) Linux distributions only provide 64-bit UEFI-compatible ISO images. This is a MISTAKE by the upstream Linux distributions, and one that I hope to influence.

Getting it to boot wasn't very hard - it required making a multiboot disk image that was 32-bit and 64-bit EFI loader compatible.

Only additional step to boot was to turn secure boot off.

## What worked out of the box in Linux
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

## UEFI (BIOS) settings that needed to be changed
- Booting: Turn off secure boot:
    UEFI --> Security --> Secure Boot menu --> Secure Boot: Change Enabled --> Disabled

- Suspend / resume
    - UEFI --> Advanced --> ACPI Settings --> Enable ACPI Auto Configuration: Change from Enabled --> Disabled

    - With JUST the one change above, suspend / resume works perfectly
    - Have tried with Wifi and Bluetooth audio active, on resume Wifi reconnects and audio stream resumes

    - Have **NOT** tried with USB 3.0 peripherals plugged while suspending

- Sound
    - UEFI --> Chipset --> Audio Configuration --> LPE Audio Support: Set to ```LPE Audio ACPI mode`` (default setting)

## Things that needed work, but which work perfectly now
- Wifi
- Bluetooth
- Battery level sensing
- Battery charge / discharge rate sensing
- Battery time-to-full and time-to-empty calculation
- Sound: Speakers and headphone jack both work. Microphone (sound recording) works

## What is not working yet
**Everything on the RDP Thinbook now works perfectly in Linux.**

All files, scripts and documentation on this repository have been updated and tested.

This was the bug that held up sound support - fixed with es8316 driver: [Bug 189261 - Chuwi hi10/hi12 (Cherry Trail tablet) soundcard not recognised - rt5640](https://bugzilla.kernel.org/show_bug.cgi?id=189261)
