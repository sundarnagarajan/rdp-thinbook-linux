
### Plugable USB 3.0 to 10/100/1000 Gigabit Ethernet LAN Network Adapter - ASIX AX88179 chipset

Just works out of the box. I highly recommend plugable devices - they are very knowledgeable about Linux and clearly indicate which devices may have issues on linux and why.

iperf shows 918 Mbits/sec throughput (install iperf with ```sudo apt-get install iperf```)

[Buy on Amazon](https://www.amazon.com/gp/product/B00AQM8586)

#### journalctl -fk output
```
kernel: usb 1-1: new high-speed USB device number 9 using xhci_hcd
kernel: usb 1-1: New USB device found, idVendor=0b95, idProduct=1790
kernel: usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
kernel: usb 1-1: Product: AX88179
kernel: usb 1-1: Manufacturer: ASIX Elec. Corp.
kernel: usb 1-1: SerialNumber: 008CAE4CF4CF43
kernel: ax88179_178a 1-1:1.0 eth0: register 'ax88179_178a' at usb-0000:00:14.0-1, ASIX AX88179 USB 3.0 Gigabit Ethernet, 8c:ae:4c:f4:cf:43
kernel: ax88179_178a 1-1:1.0 enx8cae4cf4cf43: renamed from eth0
kernel: IPv6: ADDRCONF(NETDEV_UP): enx8cae4cf4cf43: link is not ready
kernel: IPv6: ADDRCONF(NETDEV_UP): enx8cae4cf4cf43: link is not ready
kernel: ax88179_178a 1-1:1.0 enx8cae4cf4cf43: ax88179 - Link status is: 1
kernel: IPv6: ADDRCONF(NETDEV_CHANGE): enx8cae4cf4cf43: link becomes ready
```

### Sabrent Premium 3-Port Aluminum Mini USB 3.0 Rotatable Hub

Uses one USB 3.0 port and expands to 3 USB 3.0 ports.
Also backward-compatible with USB 2.0 (but speeds will be limited to USB 2.0 speeds).
Plug can rotate, allowing to use in different orientations.
Connecting [Plugable USB 3.0 to 10/100/1000 Gigabit Ethernet LAN Network Adapter - ASIX AX88179 chipset](https://github.com/sundarnagarajan/rdp-thinbook-linux/new/master#plugable-usb-30-to-101001000-gigabit-ethernet-lan-network-adapter---asix-ax88179-chipset) on one of the ports:

iperf shows 918 Mbits/sec throughput (install iperf with ```sudo apt-get install iperf```)

[Buy on Amazon](https://www.amazon.com/gp/product/B013XGK53E)

#### journalctl -fk output
```
kernel: usb 1-1: new high-speed USB device number 10 using xhci_hcd
kernel: usb 1-1: New USB device found, idVendor=0bda, idProduct=5411
kernel: usb 1-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
kernel: usb 1-1: Product: 4-Port USB 2.0 Hub
kernel: usb 1-1: Manufacturer: Generic
kernel: hub 1-1:1.0: USB hub found
kernel: hub 1-1:1.0: 4 ports detected
kernel: usb 2-1: new SuperSpeed USB device number 5 using xhci_hcd
kernel: usb 2-1: New USB device found, idVendor=0bda, idProduct=0411
kernel: usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
kernel: usb 2-1: Product: 4-Port USB 3.0 Hub
kernel: usb 2-1: Manufacturer: Generic
kernel: hub 2-1:1.0: USB hub found
kernel: hub 2-1:1.0: 4 ports detected
kernel: usb 2-1.4: new SuperSpeed USB device number 6 using xhci_hcd
kernel: usb 2-1.4: New USB device found, idVendor=0b95, idProduct=1790
kernel: usb 2-1.4: New USB device strings: Mfr=1, Product=2, SerialNumber=3
kernel: usb 2-1.4: Product: AX88179
kernel: usb 2-1.4: Manufacturer: ASIX Elec. Corp.
kernel: usb 2-1.4: SerialNumber: 008CAE4CF4CF43
kernel: ax88179_178a 2-1.4:1.0 eth0: register 'ax88179_178a' at usb-0000:00:14.0-1.4, ASIX AX88179 USB 3.0 Gigabit Ethernet, 8c:ae:4c:f4:cf:43
kernel: ax88179_178a 2-1.4:1.0 enx8cae4cf4cf43: renamed from eth0
kernel: IPv6: ADDRCONF(NETDEV_UP): enx8cae4cf4cf43: link is not ready
kernel: IPv6: ADDRCONF(NETDEV_UP): enx8cae4cf4cf43: link is not ready
kernel: ax88179_178a 2-1.4:1.0 enx8cae4cf4cf43: ax88179 - Link status is: 1
kernel: IPv6: ADDRCONF(NETDEV_CHANGE): enx8cae4cf4cf43: link becomes ready
```
