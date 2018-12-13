## Important
See [my policy on product links](/docs/external_links.md)

### Plugable USB 3.0 to 10/100/1000 Gigabit Ethernet LAN Network Adapter - ASIX AX88179 chipset

Just works out of the box. I highly recommend plugable devices - they are very knowledgeable about Linux and clearly indicate which devices may have issues on linux and why.

iperf shows 918 Mbits/sec throughput (install iperf with ```sudo apt-get install iperf```)

See on [Amazon](https://www.amazon.com/gp/product/B00AQM8586)

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
Connecting [Plugable USB 3.0 to 10/100/1000 Gigabit Ethernet LAN Network Adapter - ASIX AX88179 chipset](https://plugable.com/products/USB3-E1000) on one of the ports:

iperf shows 918 Mbits/sec throughput (install iperf with ```sudo apt-get install iperf```)


### Sabrent Premium 3-Port Aluminum Mini USB 3.0 Rotatable Hub

Uses one USB 3.0 port and expands to 3 USB 3.0 ports.
Also backward-compatible with USB 2.0 (but speeds will be limited to USB 2.0 speeds).
Plug can rotate, allowing to use in different orientations.

Buy on [Amazon](https://www.amazon.com/gp/product/B013XGK53E)

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

### Bluetooth 4.x (BLE) USB dongles reported to be Linux-compatible

#### Plugable USB Bluetooth 4.0 Low Energy Micro Adapter (Windows 10, 8.1, 8, 7, Raspberry Pi, Linux Compatible; Classic Bluetooth, and Stereo Headset Compatible)
See on [Amazon](https://www.amazon.com/Plugable-Bluetooth-Adapter-Windows-Compatible/dp/B009ZIILLI)

See on [plugable.com](https://plugable.com/products/usb-bt4le/)

#### UtechSmart Bluetooth Adapter, (Broadcom BCM20702 chipset) UtechSmart USB Bluetooth 4.0 Low Energy Micro Adapter (Windows 10, 8.1, 8, 7, Raspberry Pi, Linux Compatible; Classic Bluetooth, and Stereo Headset Compatible)
See on [Amazon](https://www.amazon.com/gp/product/B00DDH4TYA) - update currently unavailable

#### Kinivo BTD-400 Bluetooth 4.0 Low Energy USB Adapter - Works With Windows 10 / 8.1 / 8 / Windows 7 / Vista, Raspberry Pi , Linux
See on [Amazon](https://www.amazon.com/Kinivo-BTD-400-Bluetooth-4-0-adapter/dp/B007Q45EF4)

#### GXG-1987 BTA-402 USB Bluetooth 4.0 Micro Adapter Dongle Mini Bluetooth 4.0 Adapter Dongle With CSR8510 Controller
See on [Amazon](https://www.amazon.com/ORICO-BTA-402-Bluetooth-Adapter-Controller/dp/B00AKO7XOW)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R2J8WIYSQCMOQ6/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00AKO7XOW)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/R34Q1FDDG2CEDK/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00AKO7XOW)
* [Comment 3](https://www.amazon.com/gp/customer-reviews/R1ZIR5WA5A4EW/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00AKO7XOW)

#### IOGEAR Bluetooth 4.0 USB Micro Adapter, GBU521
See on [Amazon](https://www.amazon.com/IOGEAR-Bluetooth-Micro-Adapter-GBU521/dp/B007GFX0PY)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R20XGEUHBC7ZVR/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B007GFX0PY)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/R11766D37LKAGN/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B007GFX0PY)
* [Comment 3](https://www.amazon.com/gp/customer-reviews/RETNVCAKZ2CJG/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B007GFX0PY)
* [Comment 4](https://www.amazon.com/gp/customer-reviews/R1QVF375L6NSY3/ref=cm_cr_getr_d_rvw_ttl?ie=UTF8&ASIN=B007GFX0PY)

### USB Ethernet adapters reported to be Linux-compatible

#### Plugable USB 2.0 10/100 Ethernet adapter
See on [Amazon](https://www.amazon.com/dp/B00484IEJS)

See on [plugable.com](https://plugable.com/products/usb2-e100/)

#### Plugable USB-C to 10/100/1000 Gigabit Ethernet LAN Network Adapter (Compatible with Windows, Mac OS, Linux, Chrome OS)
See on [Amazon](https://www.amazon.com/dp/B011DDXGVC)

See on [plugable.com](https://plugable.com/products/usbc-e1000/)

#### Plugable USB 2.0 to 10/100/1000 Gigabit Ethernet LAN Wired Network Adapter for Windows, Mac, Chromebook, Linux/Unix (ASIX AX88178 Chipset)
See on [Amazon](https://www.amazon.com/dp/B003VSTDFG)

See on [plugable.com](https://plugable.com/products/usb2-e1000/)

#### USB Network Adapter,TechRise USB 3.0 to RJ45 Gigabit Ethernet LAN Network Adapter Supporting 10/100/1000 Mbps
See on [Amazon](https://www.amazon.com/Network-Adapter-TechRise-Ethernet-Supporting/dp/B01K1NSSTA)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R1T66UE8MIWGUJ/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B01K1NSSTA)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/R1EP6GA35G5Y7G/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B01K1NSSTA)

#### AmazonBasics USB 3.0 to 10/100/1000 Gigabit Ethernet Adapter
See on [Amazon](https://www.amazon.com/AmazonBasics-1000-Gigabit-Ethernet-Adapter/dp/B00M77HMU0)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R3C4E6I9L8WHBB/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00M77HMU0)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/R1EQT8RT92G6D2/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00M77HMU0)
* [Comment 3](https://www.amazon.com/gp/customer-reviews/R3FF2EAAHXDZYZ/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00M77HMU0)
* [Comment 4](https://www.amazon.com/gp/customer-reviews/R30UKMRYEU4Q32/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00M77HMU0)

#### Anker USB 3.0 Unibody Portable Aluminum Gigabit Ethernet Adapter Supporting 10 / 100 / 1000 Mbps Ethernet for Macbook, Mac Pro / mini, iMac, XPS, Surface Pro, Notebook PC, and More
See on [Amazon](https://www.amazon.com/Anker-Unibody-Aluminum-Ethernet-Supporting/dp/B00PC0H9IE)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R1LBKULPP9VK9C/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00PC0H9IE)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/RMOZD7HWS35OT/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00PC0H9IE)
* [Comment 3](https://www.amazon.com/gp/customer-reviews/R31JI6T7Q79U9W/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00PC0H9IE)
* [Comment 4](https://www.amazon.com/gp/customer-reviews/R2L6HVP414HLD/ref=cm_cr_getr_d_rvw_ttl?ie=UTF8&ASIN=B00PC0H9IE)

#### TRENDnet USB 3.0 to Gigabit Ethernet LAN Wired Network Adapter for Windows, Mac, Chromebook, Linux, and Specific Android Tablets, Nintendo Switch, ASIX AX88179 Chipset, TU3-ETG
See on [Amazon](https://www.amazon.com/TRENDnet-Ethernet-Chromebook-Specific-TU3-ETG/dp/B00FFJ0RKE)

#### UGREEN Network Adapter USB 3.0 to Ethernet RJ45 Lan Gigabit Adapter for 10/100/1000 Mbps Ethernet Supports Nintendo Switch Black
See on [Amazon](https://www.amazon.com/UGREEN-Gigabit-Ethernet-Network-1000Mbps/dp/B00MYTSN18)

See user comments on Linux compatibility:
* [Comment 1](https://www.amazon.com/gp/customer-reviews/R2OM3JOLU29UH6/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00MYTSN18)
* [Comment 2](https://www.amazon.com/gp/customer-reviews/R1BZXTJRMPBQMW/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00MYTSN18)
* [Comment 3](https://www.amazon.com/gp/customer-reviews/REPFG2LZ47QMX/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00MYTSN18)
* [Comment 4](https://www.amazon.com/gp/customer-reviews/RCM8UMRCK0AHR/ref=cm_cr_arp_d_rvw_ttl?ie=UTF8&ASIN=B00MYTSN18)



