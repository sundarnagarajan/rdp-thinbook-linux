# rdp-thinbook-linux
Linux on the RDP Thinbook

#linuxium-kernel
Contains Zappety kernel back-ported and pathed to support Wifi on the RDP Thinbook.
From: http://www.linuxium.com.au/how-tos/runningubuntuontheintelcomputestick
linuxium hhas not provided sources.
To use these, easiest (or only ?) method:
- Clone this repository and write the DEBs ont to a removable disk
- Create a UEFI-compatible boot medium containing Ubuntu linux distro ISO. Can consider https://github.com/sundarnagarajan/uefi_multiboot
- Install Ubuntu - either on on-board SSD or on a removable drive
- Reboot into newly installed Ubuntu
- Mount the removable disk with the patched kernel DEBs
- Install the patched kernel DEBs
- Reboot - WiFi should work


#hardware
Other fixes forhardware on the RDP Thinbook - WIP

