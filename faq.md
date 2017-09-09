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
