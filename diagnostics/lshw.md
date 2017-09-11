## Output of sudo lshw
```
rdp-sundar                
    description: Desktop Computer
    product: ThinBook (Default string)
    vendor: RDP Workstations Pvt LTD.
    version: 1.0
    serial: To Be Filled By O.E.M
    width: 64 bits
    capabilities: smbios-3.0 dmi-3.0 vsyscall32
    configuration: boot=normal chassis=desktop family=NoteBook sku=Default string uuid=58D5E2A7-7A0E-424B-B322-CC79CF46DE04
  *-core
       description: Motherboard
       product: Default string
       vendor: iP3
       physical id: 0
       version: Default string
       serial: YN81234567890211
       slot: Default string
     *-firmware
          description: BIOS
          vendor: American Megatrends Inc.
          physical id: 0
          version: 0.09
          date: 08/17/2016
          size: 64KiB
          capacity: 4032KiB
          capabilities: pci upgrade shadowing cdboot bootselect socketedrom edd int13floppy1200 int13floppy720 int13floppy2880 int5printscreen int14serial int17printer acpi usb biosbootspecification uefi
     *-memory
          description: System Memory
          physical id: 28
          slot: System board or motherboard
          size: 2GiB
        *-bank:0
             description: DIMM DDR3 1600 MHz (0.6 ns)
             product: 00000000
             vendor: Hynix Semiconductor
             physical id: 0
             serial: 00000000
             slot: A1_DIMM0
             size: 2GiB
             width: 8 bits
             clock: 1600MHz (0.6ns)
        *-bank:1
             description: DIMM [empty]
             product: 00000000
             vendor: Hynix Semiconductor
             physical id: 1
             serial: 00000000
             slot: A1_DIMM1
     *-cache:0
          description: L1 cache
          physical id: 32
          slot: CPU Internal L1
          size: 224KiB
          capacity: 224KiB
          capabilities: internal write-back
          configuration: level=1
     *-cache:1
          description: L2 cache
          physical id: 33
          slot: CPU Internal L2
          size: 2MiB
          capacity: 2MiB
          capabilities: internal write-back unified
          configuration: level=2
     *-cpu
          description: CPU
          product: Intel(R) Atom(TM) x5-Z8300  CPU @ 1.44GHz
          vendor: Intel Corp.
          physical id: 34
          bus info: cpu@0
          version: Intel(R) Atom(TM) x5-Z8300 CPU @ 1.44GHz
          slot: SOCKET 0
          size: 593MHz
          capacity: 2400MHz
          width: 64 bits
          clock: 80MHz
          capabilities: x86-64 fpu fpu_exception wp vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx rdtscp constant_tsc arch_perfmon pebs bts rep_good nopl xtopology tsc_reliable nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr pdcm sse4_1 sse4_2 movbe popcnt tsc_deadline_timer aes rdrand lahf_lm 3dnowprefetch epb tpr_shadow vnmi flexpriority ept vpid tsc_adjust smep erms dtherm ida arat cpufreq
          configuration: cores=4 enabledcores=4 threads=4
     *-pci
          description: Host bridge
          product: Intel Corporation
          vendor: Intel Corporation
          physical id: 100
          bus info: pci@0000:00:00.0
          version: 22
          width: 32 bits
          clock: 33MHz
          configuration: driver=iosf_mbi_pci
          resources: irq:0
        *-display
             description: VGA compatible controller
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: 2
             bus info: pci@0000:00:02.0
             version: 22
             width: 64 bits
             clock: 33MHz
             capabilities: pm msi vga_controller bus_master cap_list rom
             configuration: driver=i915 latency=0
             resources: irq:207 memory:90000000-90ffffff memory:80000000-8fffffff ioport:f000(size=64) memory:c0000-dffff
        *-multimedia UNCLAIMED
             description: Multimedia controller
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: 3
             bus info: pci@0000:00:03.0
             version: 22
             width: 32 bits
             clock: 33MHz
             capabilities: pm msi cap_list
             configuration: latency=0
             resources: memory:91000000-913fffff
        *-generic:0
             description: Signal processing controller
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: b
             bus info: pci@0000:00:0b.0
             version: 22
             width: 64 bits
             clock: 33MHz
             capabilities: msi pm cap_list
             configuration: driver=proc_thermal latency=0
             resources: irq:253 memory:91827000-91827fff
        *-usb
             description: USB controller
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: 14
             bus info: pci@0000:00:14.0
             version: 22
             width: 64 bits
             clock: 33MHz
             capabilities: pm msi xhci bus_master cap_list
             configuration: driver=xhci_hcd latency=0
             resources: irq:21 memory:91800000-9180ffff
           *-usbhost:0
                product: xHCI Host Controller
                vendor: Linux 4.13.0 xhci-hcd
                physical id: 0
                bus info: usb@1
                logical name: usb1
                version: 4.13
                capabilities: usb-2.00
                configuration: driver=hub slots=7 speed=480Mbit/s
              *-usb:0
                   description: Generic USB device
                   product: USB2.0-CRW
                   vendor: Generic
                   physical id: 2
                   bus info: usb@1:2
                   version: 39.60
                   serial: 20100201396000000
                   capabilities: usb-2.00
                   configuration: driver=rtsx_usb maxpower=500mA speed=480Mbit/s
              *-usb:1
                   description: USB hub
                   product: USB2.0 Hub
                   vendor: Genesys Logic, Inc.
                   physical id: 3
                   bus info: usb@1:3
                   version: 85.37
                   capabilities: usb-2.00
                   configuration: driver=hub maxpower=100mA slots=3 speed=480Mbit/s
                 *-usb:0
                      description: Keyboard
                      vendor: winpad Keyboard
                      physical id: 2
                      bus info: usb@1:3.2
                      version: 0.01
                      capabilities: usb-2.00
                      configuration: driver=usbhid maxpower=98mA speed=12Mbit/s
                 *-usb:1
                      description: Mouse
                      product: Optical mouse
                      vendor: Creative Labs
                      physical id: 3
                      bus info: usb@1:3.3
                      version: 0.00
                      capabilities: usb-1.10
                      configuration: driver=usbhid maxpower=100mA speed=2Mbit/s
              *-usb:2
                   description: Video
                   product: USB2.0 PC CAMERA
                   vendor: Generic
                   physical id: 4
                   bus info: usb@1:4
                   version: 1.00
                   capabilities: usb-2.00
                   configuration: driver=uvcvideo maxpower=256mA speed=480Mbit/s
           *-usbhost:1
                product: xHCI Host Controller
                vendor: Linux 4.13.0 xhci-hcd
                physical id: 1
                bus info: usb@2
                logical name: usb2
                version: 4.13
                capabilities: usb-3.00
                configuration: driver=hub slots=6 speed=5000Mbit/s
        *-generic:1
             description: Encryption controller
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: 1a
             bus info: pci@0000:00:1a.0
             version: 22
             width: 32 bits
             clock: 33MHz
             capabilities: pm msi bus_master cap_list
             configuration: driver=mei_txe latency=0
             resources: irq:254 memory:91700000-917fffff memory:91600000-916fffff
        *-isa
             description: ISA bridge
             product: Intel Corporation
             vendor: Intel Corporation
             physical id: 1f
             bus info: pci@0000:00:1f.0
             version: 22
             width: 32 bits
             clock: 33MHz
             capabilities: isa bus_master cap_list
             configuration: driver=lpc_ich latency=0
             resources: irq:0
  *-network
       description: Wireless interface
       physical id: 1
       logical name: wlan0
       serial: cc:79:cf:46:de:04
       capabilities: ethernet physical wireless
       configuration: broadcast=yes driver=rtl8723bs ip=10.3.2.61 multicast=yes wireless=IEEE 802.11bgn
```
