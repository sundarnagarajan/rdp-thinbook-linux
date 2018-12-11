### How to report a problem
- Open an issue on github
- You will need a github account

**AT LEAST** provide the following information when you open an issue:
1. Did you use one of the pre-compiled remastered ISOs? If so, which one?
2. If you remastered your own ISO, what was the source ISO (distribution, version, 32-bit or 64-bit)?
3. Did you install on to the main SSD or to an external (USB) medium?
4. While partitioning your target disk during installation, did you create (and use) a **GPT** partition table and an EFI partition?
5. What was the **EXACT** error message you saw, if any, and **at what stage** of install etc
6. Which model of RDP Thinbook are you using? The 14-inch model with Intel Atom X5-8300 or the 11-inch model with Intel Atom X3-8350?

### Question: My bootable medium is not detected and the RDP Thinbook boots directly into the UEFI firmware (or alternate OS)
The UEFI Firmware on the RDP Thinbook is not always reliable at detecting the presence of a removable UEFI-compatible boot disk. 
Follow the following procedure to boot a disk created with ```make_rdp_iso.sh```:
- Make sure you have disabled secure boot in the UEFI:
    UEFI --> Security --> Secure Boot menu --> Secure Boot: Change Enabled --> Disabled
- Power down the RDP Thinbook
- Power on the RDP Thinbook and **ONLY when the RDP symbol appears**, press F7
- If your bootable disk does not appear as a boot option, press Ctrl-Alt-Del to reboot the RDP Thinbook
- Again: **ONLY when the RDP symbol appears**, press F7
I have always seen it work the first or second time. **This is a limitation with the RDP Thinbook firmware and there is nothing that can be done to fix it**

### Question: Why are there TWO sound cards listed in the Sound applet on the Hardware tab?
The card named ```Intel HDMI/DP LPE Audio``` **presumably** controls sound going out over HDMI. I have not tested this (yet), since I don't have a HDMI speaker / receiver that I can easily connect the RDP Thinbook to

### Question:Everything seems to work, but there is no sound output
This should now be fixed - in the remastered ISO (and in an install derived from it), I now explicitly
set the default output (sink) for Pulseaudio to be ```alsa_output.platform-bytcht_es8316.HiFi__hw_bytchtes8316__sink```

If this is still not working (unlikely), you can fix it as follows:
#### Method 1 using Sound applet
- Open the sound applet
- Go to ```Output``` tab
- Choose ```bytcht-es8316 Speakers``` as output
#### Method 2 using command line
- Open a command prompt (Applications --> System Tools --> Mate Terminal)
- Execute the following command as normal user (no sudo required):
      ```pactl set-default-sink alsa_output.platform-bytcht_es8316.HiFi__hw_bytchtes8316__sink```
  
Regardless of which method you choose, you need to do this only once inside your account 
(if you have installed to a hard disk) and **once each time you boot** if you are booting
to a Live session
  
### Question: No sound output and Sound preferences output tab only shows 'Dummy output'
Make sure you have this setting in UEFI:

UEFI --> Chipset --> Audio Configuration --> LPE Audio Support: Set to ```LPE Audio ACPI mode`` (default setting)

### Question: FN keys and backspace stop working after suspend-resume
Confirmed to be an issue on Ubuntu Mate 16.04.3 LTS. All the FN-Fx keys are detected, and out of the box after a fresh boot (or in live session) work perfectly - see below. However, after a suspend + resume, some of the keys - in particular F3 (Volume down), F4 (Volume Up), F5: Mute/Unmute stop working. This will manifest as:

Key does not produce OSD or have any effect, but the key combination can be detected under System --> Preferences --> Hardware --> Keyboard Shortcuts (in Ubuntu Mate) as a candidate for a key binding - often appearing as something like Mod4 + XF86AudioLowerVolume rather than XF86AudioLowerVolume. In such cases, even the Backspace key stops working

Permanent solution is underway. Until then, after **every** resume, press ```Super_L + Delete``` (```Win + Delete```). The problem will immediately be resolved. This is technically an upstream bug - I have just found a workaround.

### Question: dmesg error: axp288_fuel_gauge: ADC charge current read failed:-19
See [bugzilla comment](https://bugzilla.kernel.org/show_bug.cgi?id=155241#c61) by tagoreddy to Hans de Goode:
```
(In reply to Hans de Goede from comment #60)

Hello Hans,

I've recently noticed that whenever 'axp288_fuel_gauge' module loads before 'axp288_adc', its throwing the following error continuously until the later is loaded:

axp288_fuel_gauge: ADC charge current read failed:-19

Would you please add 'axp288_adc' as a dependency for 'axp288_fuel_gauge'.

Thanks,
Tagore
```

### Question: Installer fails with message 'grub-efi-ia32', package failed to install into /target/ , without GRUB boot loader, the installed system will not boot.'

Steps
- Insert the bootable Linux ISO USB disk that you created with Ubuntu Mate
- Turn on the RDP Thinbook, and as soon as the RDP symbol appears, press F7
- Choose your USB disk from the menu - it will look something like 'UEFI: disk_brand_model'. This is NOT the entry labelled 'ubuntu' - if such an entry appears
- If your USB disk does not appear, press Ctrl-Alt-Del and AGAIN press F7 as soon as the RDP symbol appears - your disk should apear at least the second time
- Boot into Ubuntu Mate choosing Try Ubuntu Mate without Installing
- Once inside Ubuntu Mate open a Terminal by using the menu Applications --> System Tools --> Mate Terminal
- Read and follow the following instructions very carefully:

```sudo parted /dev/mmcblk0 print```

The output of the parted command should look something like this:

```
Model: MMC NCard (sd/mmc)
Disk /dev/mmcblk0: 31.0GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system     Name  Flags
 5      17.4kB  1049kB  1031kB                  bios  bios_grub
 1      1049kB  106MB   105MB   fat16           EFI   boot, esp
 2      106MB   21.6GB  21.5GB  ext4            root
 3      21.6GB  24.8GB  3221MB  linux-swap(v1)  swap
 4      24.8GB  31.0GB  6236MB                  data
```

We are going to to run the script ```/root/remaster/scripts/make_bootable.py```

That script needs two parameters:
- The disk device - we know this - it is /dev/mmcblk0
- The root partition - usually the partition with filesystem == 'ext4'

In the example output above, the root partition would be partition 2

Run the following command:
```
/root/remaster/scripts/make_bootable.py /dev/mmcblk0 /dev/mmcblk0p2
```


