```
[    0.000000] random: get_random_bytes called from start_kernel+0x42/0x47a with crng_init=0
[    0.000000] Linux version 4.13.0 (sundar@smaug) (gcc version 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.4)) #2 SMP Mon Sep 4 22:31:57 PDT 2017
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.13.0 root=UUID=85f1ebf1-28e2-4fcf-a947-0ac0b4140f8c ro crashkernel=384M-:128M
[    0.000000] KERNEL supported cpus:
[    0.000000]   Intel GenuineIntel
[    0.000000]   AMD AuthenticAMD
[    0.000000]   Centaur CentaurHauls
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000008efff] usable
[    0.000000] BIOS-e820: [mem 0x000000000008f000-0x000000000008ffff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x0000000000090000-0x000000000009dfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009e000-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000020200000-0x000000007b11afff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b11b000-0x000000007b14afff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007b14b000-0x000000007b267fff] usable
[    0.000000] BIOS-e820: [mem 0x000000007b268000-0x000000007b747fff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x000000007b748000-0x000000007ba90fff] reserved
[    0.000000] BIOS-e820: [mem 0x000000007ba91000-0x000000007bffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000e0000000-0x00000000e3ffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fea00000-0x00000000feafffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed01000-0x00000000fed01fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed03000-0x00000000fed03fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed06000-0x00000000fed06fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed08000-0x00000000fed09fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1cfff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed80000-0x00000000fedbffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] efi: EFI v2.40 by American Megatrends
[    0.000000] efi:  ESRT=0x7b149000  ACPI=0x7b2ac000  ACPI 2.0=0x7b2ac000  SMBIOS=0x7b911000  SMBIOS 3.0=0x7b910000 
[    0.000000] random: fast init done
[    0.000000] SMBIOS 3.0.0 present.
[    0.000000] DMI: RDP Workstations Pvt LTD. ThinBook/Default string, BIOS 0.09 08/17/2016
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x7c000 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 000000000 mask F80000000 write-back
[    0.000000]   1 base 07E000000 mask FFE000000 uncachable
[    0.000000]   2 base 07D000000 mask FFF000000 uncachable
[    0.000000]   3 base 07C800000 mask FFF800000 uncachable
[    0.000000]   4 base 07C400000 mask FFFC00000 uncachable
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT  
[    0.000000] total RAM covered: 1988M
[    0.000000] Found optimal setting for mtrr clean up
[    0.000000]  gran_size: 64K 	chunk_size: 64M 	num_reg: 5  	lose cover RAM: 0G
[    0.000000] esrt: ESRT header is not in the memory map.
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff9df600098000] 98000 size 24576
[    0.000000] BRK [0x3885d000, 0x3885dfff] PGTABLE
[    0.000000] BRK [0x3885e000, 0x3885efff] PGTABLE
[    0.000000] BRK [0x3885f000, 0x3885ffff] PGTABLE
[    0.000000] BRK [0x38860000, 0x38860fff] PGTABLE
[    0.000000] BRK [0x38861000, 0x38861fff] PGTABLE
[    0.000000] BRK [0x38862000, 0x38862fff] PGTABLE
[    0.000000] BRK [0x38863000, 0x38863fff] PGTABLE
[    0.000000] BRK [0x38864000, 0x38864fff] PGTABLE
[    0.000000] Secure boot could not be determined
[    0.000000] RAMDISK: [mem 0x3d7e0000-0x3fffafff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x000000007B2AC000 000024 (v02 ALASKA)
[    0.000000] ACPI: XSDT 0x000000007B2AC0B8 0000EC (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: FACP 0x000000007B2CBAE0 00010C (v05 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: DSDT 0x000000007B2AC238 01F8A1 (v02 ALASKA A M I    01072009 INTL 20120913)
[    0.000000] ACPI: APIC 0x000000007B2CBBF0 000084 (v03 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: FPDT 0x000000007B2CBC78 000044 (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: FIDT 0x000000007B2CBCC0 00009C (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: MCFG 0x000000007B2CBD60 00003C (v01 ALASKA A M I    01072009 MSFT 00000097)
[    0.000000] ACPI: SSDT 0x000000007B2CBDA0 004129 (v01 DptfTb DptfTab  00001000 INTL 20120913)
[    0.000000] ACPI: SSDT 0x000000007B2CFED0 000612 (v01 CpuDpf CpuDptf  00001000 INTL 20120913)
[    0.000000] ACPI: SSDT 0x000000007B2D04E8 000058 (v01 LowPM  LowPwrM  00001000 INTL 20120913)
[    0.000000] ACPI: UEFI 0x000000007B2D0540 000042 (v01 ALASKA A M I    00000000      00000000)
[    0.000000] ACPI: SSDT 0x000000007B2D0588 000269 (v01 UsbCTb UsbCTab  00001000 INTL 20120913)
[    0.000000] ACPI: HPET 0x000000007B2D07F8 000038 (v01 ALASKA A M I    01072009 AMI. 00000005)
[    0.000000] ACPI: SSDT 0x000000007B2D0830 000763 (v01 PmRef  CpuPm    00003000 INTL 20120913)
[    0.000000] ACPI: SSDT 0x000000007B2D0F98 000262 (v01 PmRef  Cpu0Tst  00003000 INTL 20120913)
[    0.000000] ACPI: SSDT 0x000000007B2D1200 00017A (v01 PmRef  ApTst    00003000 INTL 20120913)
[    0.000000] ACPI: LPIT 0x000000007B2D1380 000104 (v01 ALASKA A M I    00000005 MSFT 0100000D)
[    0.000000] ACPI: BCFG 0x000000007B2D1488 000139 (v01 INTEL  BATTCONF 00000001 ACPI 00000000)
[    0.000000] ACPI: PRAM 0x000000007B2D15C8 000030 (v01                 00000001      00000000)
[    0.000000] ACPI: BGRT 0x000000007B2D15F8 000038 (v01 ALASKA A M I    01072009 AMI  00010013)
[    0.000000] ACPI: TPM2 0x000000007B2D1630 000034 (v03        Tpm2Tabl 00000001 AMI  00000000)
[    0.000000] ACPI: CSRT 0x000000007B2D1668 00014C (v00 INTEL  LANFORDC 00000005 MSFT 0100000D)
[    0.000000] ACPI: WDAT 0x000000007B2D17B8 000104 (v01                 00000000      00000000)
[    0.000000] ACPI: EINJ 0x000000007B2D18C0 000130 (v01 AMI    AMI.EINJ 00000000 AMI. 00000000)
[    0.000000] ACPI: ERST 0x000000007B2D19F0 000230 (v01 AMIER  AMI.ERST 00000000 AMI. 00000000)
[    0.000000] ACPI: BERT 0x000000007B2D1C20 000030 (v01 AMI    AMI.BERT 00000000 AMI. 00000000)
[    0.000000] ACPI: HEST 0x000000007B2D1C50 0000A8 (v01 AMI    AMI.HEST 00000000 AMI. 00000000)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000007bffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x7b263000-0x7b267fff]
[    0.000000] Reserving 128MB of memory at 752MB for crashkernel (System RAM: 1973MB)
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x000000007bffffff]
[    0.000000]   Normal   empty
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000008efff]
[    0.000000]   node   0: [mem 0x0000000000090000-0x000000000009dfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001fffffff]
[    0.000000]   node   0: [mem 0x0000000020200000-0x000000007b11afff]
[    0.000000]   node   0: [mem 0x000000007b14b000-0x000000007b267fff]
[    0.000000]   node   0: [mem 0x000000007ba91000-0x000000007bffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000007bffffff]
[    0.000000] On node 0 totalpages: 505155
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 7872 pages used for memmap
[    0.000000]   DMA32 zone: 501159 pages, LIFO batch:31
[    0.000000] tboot: non-0 tboot_addr but it is not of type E820_TYPE_RESERVED
[    0.000000] Reserving Intel graphics memory at 0x000000007ce00000-0x000000007edfffff
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 1, version 32, address 0xfec00000, GSI 0-114
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 4 CPUs, 0 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0008f000-0x0008ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x20000000-0x201fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b11b000-0x7b14afff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b268000-0x7b747fff]
[    0.000000] PM: Registered nosave memory: [mem 0x7b748000-0x7ba90fff]
[    0.000000] e820: [mem 0x7ee00000-0xdfffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:4 nr_node_ids:1
[    0.000000] percpu: Embedded 39 pages/cpu @ffff9df67ac00000 s120024 r8192 d31528 u524288
[    0.000000] pcpu-alloc: s120024 r8192 d31528 u524288 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 497198
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.13.0 root=UUID=85f1ebf1-28e2-4fcf-a947-0ac0b4140f8c ro crashkernel=384M-:128M
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 1695824K/2020620K available (9095K kernel code, 1529K rwdata, 3840K rodata, 1640K init, 1180K bss, 324796K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] ftrace: allocating 36959 entries in 145 pages
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=4.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
[    0.000000] NR_IRQS: 33024, nr_irqs: 1024, preallocated irqs: 0
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] tsc: Detected 1440.000 MHz processor
[    0.000021] Calibrating delay loop (skipped), value calculated using timer frequency.. 2880.00 BogoMIPS (lpj=5760000)
[    0.000045] pid_max: default: 32768 minimum: 301
[    0.000085] ACPI: Core revision 20170531
[    0.004000] ACPI: 8 ACPI AML tables successfully acquired and loaded
[    0.004000] Security Framework initialized
[    0.004000] Yama: becoming mindful.
[    0.004000] AppArmor: AppArmor initialized
[    0.004000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.004000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.004000] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.004000] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes)
[    0.004000] CPU: Physical Processor ID: 0
[    0.004000] CPU: Processor Core ID: 0
[    0.004000] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.004000] ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.004000] mce: CPU supports 6 MCE banks
[    0.004000] CPU0: Thermal monitoring enabled (TM1)
[    0.004000] process: using mwait in idle threads
[    0.004000] Last level iTLB entries: 4KB 48, 2MB 0, 4MB 0
[    0.004000] Last level dTLB entries: 4KB 256, 2MB 16, 4MB 16, 1GB 0
[    0.004000] Freeing SMP alternatives memory: 32K
[    0.004000] smpboot: Max logical packages: 1
[    0.004000] TSC deadline timer enabled
[    0.004000] smpboot: CPU0: Intel(R) Atom(TM) x5-Z8300  CPU @ 1.44GHz (family: 0x6, model: 0x4c, stepping: 0x3)
[    0.004000] Performance Events: PEBS fmt2+, 8-deep LBR, Silvermont events, 8-deep LBR, full-width counters, Intel PMU driver.
[    0.004000] ... version:                3
[    0.004000] ... bit width:              40
[    0.004000] ... generic registers:      2
[    0.004000] ... value mask:             000000ffffffffff
[    0.004000] ... max period:             0000007fffffffff
[    0.004000] ... fixed-purpose events:   3
[    0.004000] ... event mask:             0000000700000003
[    0.004000] Hierarchical SRCU implementation.
[    0.004000] smp: Bringing up secondary CPUs ...
[    0.004000] x86: Booting SMP configuration:
[    0.004000] .... node  #0, CPUs:      #1
[    0.080180] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.080556]  #2 #3
[    0.240067] smp: Brought up 1 node, 4 CPUs
[    0.240067] smpboot: Total of 4 processors activated (11528.75 BogoMIPS)
[    0.241403] devtmpfs: initialized
[    0.241403] x86/mm: Memory block size: 128MB
[    0.241403] evm: security.selinux
[    0.241403] evm: security.SMACK64
[    0.241403] evm: security.SMACK64EXEC
[    0.241403] evm: security.SMACK64TRANSMUTE
[    0.241403] evm: security.SMACK64MMAP
[    0.241403] evm: security.ima
[    0.241403] evm: security.capability
[    0.241403] PM: Registering ACPI NVS region [mem 0x0008f000-0x0008ffff] (4096 bytes)
[    0.241403] PM: Registering ACPI NVS region [mem 0x7b268000-0x7b747fff] (5111808 bytes)
[    0.241403] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.241403] futex hash table entries: 1024 (order: 4, 65536 bytes)
[    0.241403] pinctrl core: initialized pinctrl subsystem
[    0.241403] RTC time: 22:44:43, date: 09/11/17
[    0.241403] NET: Registered protocol family 16
[    0.244352] cpuidle: using governor ladder
[    0.244352] cpuidle: using governor menu
[    0.244352] PCCT header not found.
[    0.244352] ACPI: bus type PCI registered
[    0.244352] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.244352] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.244352] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
[    0.244352] PCI: MMCONFIG for 0000 [bus00-3f] at [mem 0xe0000000-0xe3ffffff] (base 0xe0000000) (size reduced!)
[    0.244367] PCI: Using configuration type 1 for base access
[    0.248348] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.248348] ACPI: Added _OSI(Module Device)
[    0.248348] ACPI: Added _OSI(Processor Device)
[    0.248348] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.248348] ACPI: Added _OSI(Processor Aggregator Device)
[    0.287858] ACPI: Dynamic OEM Table Load:
[    0.287892] ACPI: SSDT 0xFFFF9DF672782000 00057B (v01 PmRef  Cpu0Ist  00003000 INTL 20120913)
[    0.288623] ACPI: Dynamic OEM Table Load:
[    0.288648] ACPI: SSDT 0xFFFF9DF67A860400 0003A5 (v01 PmRef  Cpu0Cst  00003001 INTL 20120913)
[    0.289840] ACPI: Dynamic OEM Table Load:
[    0.289864] ACPI: SSDT 0xFFFF9DF6727C4A00 00015F (v01 PmRef  ApIst    00003000 INTL 20120913)
[    0.290465] ACPI: Dynamic OEM Table Load:
[    0.290487] ACPI: SSDT 0xFFFF9DF67A805900 00008D (v01 PmRef  ApCst    00003000 INTL 20120913)
[    0.295439] ACPI: Interpreter enabled
[    0.295502] ACPI: (supports S0 S4 S5)
[    0.295513] ACPI: Using IOAPIC for interrupt routing
[    0.295696] HEST: Table parsing has been initialized.
[    0.295714] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.299023] ACPI: Power Resource [P06X] (off)
[    0.301435] ACPI: Power Resource [ID3C] (on)
[    0.304549] ACPI: Power Resource [USBC] (on)
[    0.305827] ACPI: Power Resource [WWPR] (off)
[    0.306679] ACPI: Power Resource [WWPR] (off)
[    0.308050] ACPI: Power Resource [WWPR] (off)
[    0.308891] ACPI: Power Resource [WWPR] (off)
[    0.309744] ACPI: Power Resource [WWPR] (off)
[    0.310659] ACPI: Power Resource [WWPR] (off)
[    0.325791] ACPI: Power Resource [CLK2] (on)
[    0.325925] ACPI: Power Resource [CLK4] (on)
[    0.326046] ACPI: Power Resource [P28P] (off)
[    0.326171] ACPI: Power Resource [P18P] (off)
[    0.326291] ACPI: Power Resource [P12P] (off)
[    0.326416] ACPI: Power Resource [P16P] (off)
[    0.331111] ACPI: Power Resource [CLK3] (on)
[    0.331244] ACPI: Power Resource [CLK4] (on)
[    0.333052] ACPI: Power Resource [CLK2] (on)
[    0.333178] ACPI: Power Resource [CLK1] (on)
[    0.336370] ACPI: Power Resource [CLK0] (on)
[    0.336505] ACPI: Power Resource [CLK1] (on)
[    0.338384] ACPI: Power Resource [CLK5] (off)
[    0.339209] ACPI: Power Resource [P33P] (off)
[    0.339331] ACPI: Power Resource [P65P] (off)
[    0.358189] ACPI: Power Resource [P28X] (off)
[    0.358324] ACPI: Power Resource [P18X] (off)
[    0.358447] ACPI: Power Resource [P12X] (off)
[    0.358577] ACPI: Power Resource [P28P] (off)
[    0.358710] ACPI: Power Resource [P18P] (off)
[    0.358843] ACPI: Power Resource [P12P] (off)
[    0.358966] ACPI: Power Resource [P19X] (off)
[    0.359098] ACPI: Power Resource [P12A] (off)
[    0.359220] ACPI: Power Resource [P28T] (off)
[    0.359347] ACPI: Power Resource [P18D] (off)
[    0.359474] ACPI: Power Resource [P18T] (off)
[    0.359596] ACPI: Power Resource [P3P3] (off)
[    0.359724] ACPI: Power Resource [P12T] (off)
[    0.359848] ACPI: Power Resource [P28W] (off)
[    0.359974] ACPI: Power Resource [P18W] (off)
[    0.360102] ACPI: Power Resource [P12W] (off)
[    0.360227] ACPI: Power Resource [P33W] (off)
[    0.360355] ACPI: Power Resource [P33X] (off)
[    0.360476] ACPI: Power Resource [P4BW] (off)
[    0.370119] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.370144] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.370736] acpi PNP0A08:00: _OSC: OS now controls [PCIeHotplug PME AER PCIeCapability]
[    0.370790] acpi PNP0A08:00: [Firmware Info]: MMCONFIG for domain 0000 [bus 00-3f] only partially covers this bridge
[    0.372222] PCI host bridge to bus 0000:00
[    0.372238] pci_bus 0000:00: root bus resource [io  0x0070-0x0077]
[    0.372251] pci_bus 0000:00: root bus resource [io  0x0000-0x006f window]
[    0.372263] pci_bus 0000:00: root bus resource [io  0x0078-0x0cf7 window]
[    0.372275] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.372287] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.372303] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff window]
[    0.372319] pci_bus 0000:00: root bus resource [mem 0x000e0000-0x000fffff window]
[    0.372335] pci_bus 0000:00: root bus resource [mem 0x20000000-0x201fffff window]
[    0.372350] pci_bus 0000:00: root bus resource [mem 0x7ce00001-0x7ee00000 window]
[    0.372366] pci_bus 0000:00: root bus resource [mem 0x80000000-0xdfffffff window]
[    0.372383] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.372409] pci 0000:00:00.0: [8086:2280] type 00 class 0x060000
[    0.373044] pci 0000:00:02.0: [8086:22b0] type 00 class 0x030000
[    0.373078] pci 0000:00:02.0: reg 0x10: [mem 0x90000000-0x90ffffff 64bit]
[    0.373093] pci 0000:00:02.0: reg 0x18: [mem 0x80000000-0x8fffffff 64bit pref]
[    0.373103] pci 0000:00:02.0: reg 0x20: [io  0xf000-0xf03f]
[    0.373468] pci 0000:00:03.0: [8086:22b8] type 00 class 0x048000
[    0.373491] pci 0000:00:03.0: reg 0x10: [mem 0x91000000-0x913fffff]
[    0.373869] pci 0000:00:0b.0: [8086:22dc] type 00 class 0x118000
[    0.373896] pci 0000:00:0b.0: reg 0x10: [mem 0x91827000-0x91827fff 64bit]
[    0.374340] pci 0000:00:14.0: [8086:22b5] type 00 class 0x0c0330
[    0.374376] pci 0000:00:14.0: reg 0x10: [mem 0x91800000-0x9180ffff 64bit]
[    0.374483] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    0.374851] pci 0000:00:1a.0: [8086:2298] type 00 class 0x108000
[    0.374882] pci 0000:00:1a.0: reg 0x10: [mem 0x91700000-0x917fffff]
[    0.374895] pci 0000:00:1a.0: reg 0x14: [mem 0x91600000-0x916fffff]
[    0.374997] pci 0000:00:1a.0: PME# supported from D0 D3hot
[    0.375390] pci 0000:00:1f.0: [8086:229c] type 00 class 0x060100
[    0.379744] acpi 80862288:00: Device [PWM1] is in always present list
[    0.385076] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.385281] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.385480] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.385676] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.385868] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.386062] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.386259] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.386456] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.386875] acpi INT0002:00: Device [GPED] is in always present list
[    0.391440] pci 0000:00:02.0: vgaarb: setting as boot VGA device
[    0.391440] pci 0000:00:02.0: vgaarb: VGA device added: decodes=io+mem,owns=io+mem,locks=none
[    0.391440] pci 0000:00:02.0: vgaarb: bridge control possible
[    0.391440] vgaarb: loaded
[    0.392046] SCSI subsystem initialized
[    0.392152] libata version 3.00 loaded.
[    0.392152] ACPI: bus type USB registered
[    0.392168] usbcore: registered new interface driver usbfs
[    0.392206] usbcore: registered new interface driver hub
[    0.392264] usbcore: registered new device driver usb
[    0.432766] EDAC MC: Ver: 3.0.0
[    0.432766] Registered efivars operations
[    0.436719] PCI: Using ACPI for IRQ routing
[    0.438844] PCI: pci_cache_line_size set to 64 bytes
[    0.438892] Expanded resource Reserved due to conflict with PCI Bus 0000:00
[    0.438906] e820: reserve RAM buffer [mem 0x0008f000-0x0008ffff]
[    0.438909] e820: reserve RAM buffer [mem 0x0009e000-0x0009ffff]
[    0.438911] e820: reserve RAM buffer [mem 0x7b11b000-0x7bffffff]
[    0.438914] e820: reserve RAM buffer [mem 0x7b268000-0x7bffffff]
[    0.439139] NetLabel: Initializing
[    0.439150] NetLabel:  domain hash size = 128
[    0.439159] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    0.439204] NetLabel:  unlabeled traffic allowed by default
[    0.440127] clocksource: Switched to clocksource refined-jiffies
[    0.469252] VFS: Disk quotas dquot_6.6.0
[    0.469321] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.469570] AppArmor: AppArmor Filesystem Enabled
[    0.469732] pnp: PnP ACPI init
[    0.470111] system 00:00: [io  0x0680-0x069f] has been reserved
[    0.470128] system 00:00: [io  0x0400-0x047f] could not be reserved
[    0.470140] system 00:00: [io  0x0500-0x05fe] has been reserved
[    0.470161] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.470406] pnp 00:01: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.475867] system 00:02: [mem 0x91825000-0x91825fff] has been reserved
[    0.475887] system 00:02: [mem 0x91823000-0x91823fff] has been reserved
[    0.475900] system 00:02: [mem 0x9181c000-0x9181cfff] has been reserved
[    0.475913] system 00:02: [mem 0x9181a000-0x9181afff] has been reserved
[    0.475925] system 00:02: [mem 0x91818000-0x91818fff] has been reserved
[    0.475938] system 00:02: [mem 0x91821000-0x91821fff] has been reserved
[    0.475950] system 00:02: [mem 0x9181f000-0x9181ffff] has been reserved
[    0.475962] system 00:02: [mem 0x9181d000-0x9181dfff] has been reserved
[    0.475979] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.476229] system 00:03: [mem 0xe0000000-0xefffffff] could not be reserved
[    0.476245] system 00:03: [mem 0xfea00000-0xfeafffff] has been reserved
[    0.476259] system 00:03: [mem 0xfed01000-0xfed01fff] has been reserved
[    0.476271] system 00:03: [mem 0xfed03000-0xfed03fff] has been reserved
[    0.476283] system 00:03: [mem 0xfed06000-0xfed06fff] has been reserved
[    0.476296] system 00:03: [mem 0xfed08000-0xfed09fff] has been reserved
[    0.476309] system 00:03: [mem 0xfed80000-0xfedbffff] could not be reserved
[    0.476322] system 00:03: [mem 0xfed1c000-0xfed1cfff] has been reserved
[    0.476334] system 00:03: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.476351] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.476777] pnp 00:04: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.478478] pnp: PnP ACPI: found 5 devices
[    0.480159] pci_bus 0000:00: resource 4 [io  0x0070-0x0077]
[    0.480164] pci_bus 0000:00: resource 5 [io  0x0000-0x006f window]
[    0.480168] pci_bus 0000:00: resource 6 [io  0x0078-0x0cf7 window]
[    0.480172] pci_bus 0000:00: resource 7 [io  0x0d00-0xffff window]
[    0.480176] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff window]
[    0.480179] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff window]
[    0.480183] pci_bus 0000:00: resource 10 [mem 0x000e0000-0x000fffff window]
[    0.480187] pci_bus 0000:00: resource 11 [mem 0x20000000-0x201fffff window]
[    0.480190] pci_bus 0000:00: resource 12 [mem 0x7ce00001-0x7ee00000 window]
[    0.480194] pci_bus 0000:00: resource 13 [mem 0x80000000-0xdfffffff window]
[    0.480682] NET: Registered protocol family 2
[    0.484230] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
[    0.484339] TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
[    0.484455] TCP: Hash tables configured (established 16384 bind 16384)
[    0.484554] UDP hash table entries: 1024 (order: 3, 32768 bytes)
[    0.484597] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes)
[    0.484721] NET: Registered protocol family 1
[    0.484772] pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000dffff]
[    0.485302] PCI: CLS 64 bytes, default 64
[    0.485423] Trying to unpack rootfs image as initramfs...
[    2.058121] Freeing initrd memory: 41068K
[    2.058164] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x14c1baf3789, max_idle_ns: 440795266465 ns
[    2.058232] clocksource: Switched to clocksource tsc
[    2.058232] Scanning for low memory corruption every 60 seconds
[    2.058232] audit: initializing netlink subsys (disabled)
[    2.058232] audit: type=2000 audit(1505169885.057:1): state=initialized audit_enabled=0 res=1
[    2.058232] Initialise system trusted keyrings
[    2.058232] workingset: timestamp_bits=40 max_order=19 bucket_order=0
[    2.061500] zbud: loaded
[    2.062549] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    2.062971] fuse init (API version 7.26)
[    2.063305] Allocating IMA blacklist keyring.
[    2.066690] Key type asymmetric registered
[    2.066705] Asymmetric key parser 'x509' registered
[    2.066827] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 247)
[    2.066917] io scheduler noop registered
[    2.066929] io scheduler deadline registered (default)
[    2.067015] io scheduler cfq registered
[    2.067026] io scheduler mq-deadline registered
[    2.067432] efifb: probing for efifb
[    2.067475] efifb: framebuffer at 0x80000000, using 4128k, total 4128k
[    2.067487] efifb: mode is 1366x768x32, linelength=5504, pages=1
[    2.067496] efifb: scrolling: redraw
[    2.067507] efifb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    2.076888] Console: switching to colour frame buffer device 170x48
[    2.086234] fb0: EFI VGA frame buffer device
[    2.086322] intel_idle: MWAIT substates: 0x33000020
[    2.086325] intel_idle: v0.4.1 model 0x4C
[    2.086721] intel_idle: lapic_timer_reliable_states 0xffffffff
[    2.086806] ACPI: AC: found native INT33F4 PMIC, not loading
[    2.087050] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    2.087200] ACPI: Power Button [PWRB]
[    2.087488] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input1
[    2.087675] ACPI: Lid Switch [LID0]
[    2.092350] (NULL device *): hwmon_device_register() is deprecated. Please convert the driver to use hwmon_device_register_with_info().
[    2.092680] thermal LNXTHERM:00: registered as thermal_zone0
[    2.092770] ACPI: Thermal Zone [TZ00] (0 C)
[    2.092964] ACPI: Battery: found native INT33F4 PMIC, not loading
[    2.093016] ERST: Error Record Serialization Table (ERST) support is initialized.
[    2.093019] pstore: using zlib compression
[    2.093027] pstore: Registered erst as persistent store backend
[    2.093265] GHES: APEI firmware first mode is enabled by APEI bit and WHEA _OSC.
[    2.093651] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    2.114266] 00:01: ttyS0 at I/O 0x3f8 (irq = 19, base_baud = 115200) is a 16550A
[    2.120738] hpet: number irqs doesn't agree with number of timers
[    2.120957] Linux agpgart interface v0.103
[    2.128439] brd: module loaded
[    2.132684] loop: module loaded
[    2.133285] libphy: Fixed MDIO Bus: probed
[    2.133354] tun: Universal TUN/TAP device driver, 1.6
[    2.133593] PPP generic driver version 2.4.2
[    2.137066] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.140480] ehci-pci: EHCI PCI platform driver
[    2.143872] ehci-platform: EHCI generic platform driver
[    2.147269] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.150603] ohci-pci: OHCI PCI platform driver
[    2.153943] ohci-platform: OHCI generic platform driver
[    2.157262] uhci_hcd: USB Universal Host Controller Interface driver
[    2.160967] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.164286] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 1
[    2.168791] xhci_hcd 0000:00:14.0: hcc params 0x200077c1 hci version 0x100 quirks 0x01509810
[    2.172176] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    2.172400] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    2.175796] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.179210] usb usb1: Product: xHCI Host Controller
[    2.182582] usb usb1: Manufacturer: Linux 4.13.0 xhci-hcd
[    2.185917] usb usb1: SerialNumber: 0000:00:14.0
[    2.189785] hub 1-0:1.0: USB hub found
[    2.193164] hub 1-0:1.0: 7 ports detected
[    2.197789] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    2.201175] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
[    2.204799] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    2.208222] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    2.211627] usb usb2: Product: xHCI Host Controller
[    2.215015] usb usb2: Manufacturer: Linux 4.13.0 xhci-hcd
[    2.218416] usb usb2: SerialNumber: 0000:00:14.0
[    2.222221] hub 2-0:1.0: USB hub found
[    2.225609] hub 2-0:1.0: 6 ports detected
[    2.230294] i8042: PNP: No PS/2 controller found.
[    2.233993] mousedev: PS/2 mouse device common for all mice
[    2.238042] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
[    2.241282] rtc_cmos 00:04: no alarms, 242 bytes nvram
[    2.244439] i2c /dev entries driver
[    2.247755] device-mapper: uevent: version 1.0.3
[    2.250926] device-mapper: ioctl: 4.36.0-ioctl (2017-06-09) initialised: dm-devel@redhat.com
[    2.253964] intel_pstate: Intel P-state driver initializing
[    2.258208] ledtrig-cpu: registered to indicate activity on CPUs
[    2.260582] EFI Variables Facility v0.08 2004-May-17
[    2.268369] NET: Registered protocol family 10
[    2.271557] Segment Routing with IPv6
[    2.273906] NET: Registered protocol family 17
[    2.276201] Key type dns_resolver registered
[    2.280743] microcode: sig=0x406c3, pf=0x1, revision=0x364
[    2.283627] microcode: Microcode Update Driver: v2.2.
[    2.283649] sched_clock: Marking stable (2283610303, 0)->(2333869350, -50259047)
[    2.290644] registered taskstats version 1
[    2.293230] Loading compiled-in X.509 certificates
[    2.304657] Loaded X.509 cert 'Build time autogenerated kernel key: d6c69cc631e7c40da28f9c3d8ac20ebf6d0daec0'
[    2.307155] zswap: loaded using pool lzo/zbud
[    2.323690] Key type big_key registered
[    2.333124] Key type trusted registered
[    2.342497] Key type encrypted registered
[    2.345040] AppArmor: AppArmor sha1 policy hashing enabled
[    2.347521] ima: No TPM chip found, activating TPM-bypass! (rc=-19)
[    2.349911] evm: HMAC attrs: 0x1
[    2.368582] i2c_designware 808622C1:06: I2C bus managed by PUNIT
[    2.381613]   Magic number: 1:863:754
[    2.384028] tty ttyS5: hash matches
[    2.386946] rtc_cmos 00:04: setting system clock to 2017-09-11 22:44:45 UTC (1505169885)
[    2.390673] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    2.393160] EDD information not available.
[    2.395610] PM: Hibernation image not present or could not be loaded.
[    2.421100] Freeing unused kernel memory: 1640K
[    2.423458] Write protecting the kernel read-only data: 14336k
[    2.427812] Freeing unused kernel memory: 1132K
[    2.432353] Freeing unused kernel memory: 256K
[    2.440023] x86/mm: Checked W+X mappings: passed, no W+X pages found.
[    2.528489] usb 1-2: new high-speed USB device number 2 using xhci_hcd
[    2.642567] sdhci: Secure Digital Host Controller Interface driver
[    2.645303] sdhci: Copyright(c) Pierre Ossman
[    2.662091] hidraw: raw HID events driver (C) Jiri Kosina
[    2.668866] mmc0: SDHCI controller on ACPI [80860F14:00] using ADMA
[    2.672396] usb 1-2: New USB device found, idVendor=0bda, idProduct=0129
[    2.675078] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.677863] usb 1-2: Product: USB2.0-CRW
[    2.680627] usb 1-2: Manufacturer: Generic
[    2.683335] usb 1-2: SerialNumber: 20100201396000000
[    2.695573] mmc1: SDHCI controller on ACPI [80860F14:01] using ADMA
[    2.756217] mmc1: new high speed SDIO card at address 0001
[    2.808055] usb 1-3: new high-speed USB device number 3 using xhci_hcd
[    2.813977] [drm] Memory usable by graphics device = 2048M
[    2.814782] mmc0: new HS200 MMC card at address 0001
[    2.815210] mmcblk0: mmc0:0001 NCard  28.9 GiB 
[    2.815342] mmcblk0boot0: mmc0:0001 NCard  partition 1 4.00 MiB
[    2.815451] mmcblk0boot1: mmc0:0001 NCard  partition 2 4.00 MiB
[    2.815655] mmcblk0rpmb: mmc0:0001 NCard  partition 3 4.00 MiB
[    2.819125]  mmcblk0: p1 p2 p3 p4 p5
[    2.832420] checking generic (80000000 408000) vs hw (80000000 10000000)
[    2.832422] fb: switching to inteldrmfb from EFI VGA
[    2.834997] Console: switching to colour dummy device 80x25
[    2.835354] [drm] Replacing VGA console driver
[    2.835893] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    2.835905] [drm] Driver supports precise vblank timestamp query.
[    2.841456] i915 0000:00:02.0: vgaarb: changed VGA decodes: olddecodes=io+mem,decodes=io+mem:owns=io+mem
[    2.853816] [drm] Initialized i915 1.6.0 20170619 for 0000:00:02.0 on minor 0
[    2.855321] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    2.857340] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:00/input/input2
[    2.857646] [drm] HDaudio controller not detected, using LPE audio instead

[    2.887533] fbcon: inteldrmfb (fb0) is primary device
[    2.952238] usb 1-3: New USB device found, idVendor=05e3, idProduct=0608
[    2.952242] usb 1-3: New USB device strings: Mfr=0, Product=1, SerialNumber=0
[    2.952244] usb 1-3: Product: USB2.0 Hub
[    2.953273] hub 1-3:1.0: USB hub found
[    2.953674] hub 1-3:1.0: 3 ports detected
[    3.072677] usb 1-4: new high-speed USB device number 4 using xhci_hcd
[    3.214964] usb 1-4: New USB device found, idVendor=1908, idProduct=2311
[    3.214969] usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    3.214972] usb 1-4: Product: USB2.0 PC CAMERA
[    3.214976] usb 1-4: Manufacturer: Generic
[    3.225630] usbcore: registered new interface driver rtsx_usb
[    3.292698] usb 1-3.2: new full-speed USB device number 5 using xhci_hcd
[    3.398019] usb 1-3.2: New USB device found, idVendor=04b4, idProduct=ff01
[    3.398031] usb 1-3.2: New USB device strings: Mfr=2, Product=0, SerialNumber=0
[    3.398040] usb 1-3.2: Manufacturer: winpad Keyboard
[    3.480668] usb 1-3.3: new low-speed USB device number 6 using xhci_hcd
[    3.584399] usb 1-3.3: New USB device found, idVendor=062a, idProduct=0000
[    3.584411] usb 1-3.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    3.602553] usbcore: registered new interface driver usbhid
[    3.602555] usbhid: USB HID core driver
[    3.607417] input: winpad Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3.2/1-3.2:1.0/0003:04B4:FF01.0001/input/input3
[    3.665861] hid-generic 0003:04B4:FF01.0001: input,hidraw0: USB HID v1.11 Keyboard [winpad Keyboard] on usb-0000:00:14.0-3.2/input0
[    3.666400] input: winpad Keyboard as /devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3.2/1-3.2:1.1/0003:04B4:FF01.0002/input/input4
[    3.726639] hid-generic 0003:04B4:FF01.0002: input,hiddev0,hidraw1: USB HID v1.11 Mouse [winpad Keyboard] on usb-0000:00:14.0-3.2/input1
[    3.727501] hid-generic 0003:04B4:FF01.0003: hiddev1,hidraw2: USB HID v1.11 Device [winpad Keyboard] on usb-0000:00:14.0-3.2/input2
[    3.727729] input: HID 062a:0000 as /devices/pci0000:00/0000:00:14.0/usb1/1-3/1-3.3/1-3.3:1.0/0003:062A:0000.0004/input/input5
[    3.727940] hid-generic 0003:062A:0000.0004: input,hidraw3: USB HID v1.10 Mouse [HID 062a:0000] on usb-0000:00:14.0-3.3/input0
[    4.095174] Console: switching to colour frame buffer device 170x48
[    4.138419] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[    4.302044] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    4.650461] systemd[1]: systemd 229 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ -LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN)
[    4.658462] systemd[1]: Detected architecture x86-64.
[    4.682280] systemd[1]: Set hostname to <rdp-sundar>.
[    4.910963] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[    4.919155] systemd[1]: Listening on Syslog Socket.
[    4.927430] systemd[1]: Created slice System Slice.
[    4.935634] systemd[1]: Created slice system-systemd\x2dfsck.slice.
[    4.943762] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[    4.952000] systemd[1]: Listening on fsck to fsckd communication Socket.
[    4.960409] systemd[1]: Created slice User and Session Slice.
[    5.117357] lp: driver loaded but no devices found
[    5.127531] ppdev: user-space parallel port driver
[    5.403753] EXT4-fs (mmcblk0p2): re-mounted. Opts: errors=remount-ro
[    5.447457] systemd-journald[246]: Received request to flush runtime journal from PID 1
[    5.796410] 8086228A:00: ttyS4 at MMIO 0x91819000 (irq = 4, base_baud = 2764800) is a 16550A
[    5.816810] rfkill_gpio OBDA8723:00: OBDA8723:00 device registered.
[    5.911483] axp20x-i2c i2c-INT33F4:00: AXP20x variant AXP288 found
[    5.921645] Bluetooth: Core ver 2.22
[    5.921683] NET: Registered protocol family 31
[    5.921685] Bluetooth: HCI device and connection manager initialized
[    5.921692] Bluetooth: HCI socket layer initialized
[    5.921697] Bluetooth: L2CAP socket layer initialized
[    5.921723] Bluetooth: SCO socket layer initialized
[    5.935159] nfc: nfc_init: NFC Core ver 0.1
[    5.935206] NET: Registered protocol family 39
[    5.947780] r8723bs: module is from the staging directory, the quality is unknown, you have been warned.
[    5.951292] RTL8723BS: module init start
[    5.951296] RTL8723BS: rtl8723bs v4.3.5.5_12290.20140916_BTCOEX20140507-4E40
[    5.951298] RTL8723BS: rtl8723bs BT-Coex version = BTCOEX20140507-4E40
[    5.982925] Bluetooth: HCI UART driver ver 2.3
[    5.982930] Bluetooth: HCI UART protocol H4 registered
[    5.982932] Bluetooth: HCI UART protocol BCSP registered
[    5.982972] Bluetooth: HCI UART protocol LL registered
[    5.982975] Bluetooth: HCI UART protocol ATH3K registered
[    5.982976] Bluetooth: HCI UART protocol Three-wire (H5) registered
[    5.983099] Bluetooth: HCI UART protocol Intel registered
[    5.983144] Bluetooth: HCI UART protocol Broadcom registered
[    5.983146] Bluetooth: HCI UART protocol QCA registered
[    5.983147] Bluetooth: HCI UART protocol AG6XX registered
[    5.997079] axp20x-i2c i2c-INT33F4:00: AXP20X driver loaded
[    6.004522] dw_dmac INTL9C60:00: DesignWare DMA Controller, 8 channels
[    6.044550] dw_dmac INTL9C60:01: DesignWare DMA Controller, 8 channels
[    6.050277] input: Intel HDMI/DP LPE Audio HDMI/DP,pcm=0 as /devices/pci0000:00/0000:00:02.0/hdmi-lpe-audio/sound/card0/input6
[    6.050535] input: Intel HDMI/DP LPE Audio HDMI/DP,pcm=1 as /devices/pci0000:00/0000:00:02.0/hdmi-lpe-audio/sound/card0/input7
[    6.050692] input: Intel HDMI/DP LPE Audio HDMI/DP,pcm=2 as /devices/pci0000:00/0000:00:02.0/hdmi-lpe-audio/sound/card0/input8
[    6.062472] intel_sst_acpi 808622A8:00: LPE base: 0x91400000 size:0x200000
[    6.062477] intel_sst_acpi 808622A8:00: IRAM base: 0x914c0000
[    6.062514] intel_sst_acpi 808622A8:00: DRAM base: 0x91500000
[    6.062524] intel_sst_acpi 808622A8:00: SHIM base: 0x91540000
[    6.062543] intel_sst_acpi 808622A8:00: Mailbox base: 0x91544000
[    6.062551] intel_sst_acpi 808622A8:00: DDR base: 0x20000000
[    6.062665] intel_sst_acpi 808622A8:00: Got drv data max stream 25
[    6.063514] pnetdev = ffff9df63e817000
[    6.063630] proc_thermal 0000:00:0b.0: enabling device (0000 -> 0002)
[    6.066629] (NULL device *): hwmon_device_register() is deprecated. Please convert the driver to use hwmon_device_register_with_info().
[    6.066773] (NULL device *): hwmon_device_register() is deprecated. Please convert the driver to use hwmon_device_register_with_info().
[    6.117487] r8723bs: module is from the staging directory, the quality is unknown, you have been warned.
[    6.130673] r8723bs: module is from the staging directory, the quality is unknown, you have been warned.
[    6.188411] RTL8723BS: rtw_ndev_init(wlan0)
[    6.189135] RTL8723BS: module init ret =0
[    6.275139] SSE version of gcm_enc/dec engaged.
[    6.516164] intel_rapl: Found RAPL domain package
[    6.516168] intel_rapl: Found RAPL domain core
[    6.740249] Adding 3145724k swap on /dev/mmcblk0p3.  Priority:-1 extents:1 across:3145724k SSFS
[    6.808142] input: gpio-keys as /devices/platform/gpio-keys.2.auto/input/input9
[    6.808502] input: gpio-keys as /devices/platform/gpio-keys.3.auto/input/input10
[    6.971499] snd_soc_sst_byt_cht_es8316: unknown parameter 'index' ignored
[    7.021472] intel-spi intel-spi: w25q64dw (8192 Kbytes)
[    7.041615] Creating 1 MTD partitions on "intel-spi":
[    7.041626] 0x000000000000-0x000000800000 : "BIOS"
[    7.047536] bytcht_es8316 bytcht_es8316: snd-soc-dummy-dai <-> media-cpu-dai mapping ok
[    7.047611] bytcht_es8316 bytcht_es8316: snd-soc-dummy-dai <-> deepbuffer-cpu-dai mapping ok
[    7.047652] compress asoc: snd-soc-dummy-dai <-> compress-cpu-dai mapping ok
[    7.052444] bytcht_es8316 bytcht_es8316: ES8316 HiFi <-> ssp2-port mapping ok
[    7.151423] audit: type=1400 audit(1505169890.264:2): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/bin/ubuntu-core-launcher" pid=776 comm="apparmor_parser"
[    7.154095] audit: type=1400 audit(1505169890.267:3): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/snapd/snap-confine" pid=777 comm="apparmor_parser"
[    7.154107] audit: type=1400 audit(1505169890.267:4): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/snapd/snap-confine//mount-namespace-capture-helper" pid=777 comm="apparmor_parser"
[    7.158364] audit: type=1400 audit(1505169890.271:5): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/sbin/dhclient" pid=774 comm="apparmor_parser"
[    7.158374] audit: type=1400 audit(1505169890.271:6): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=774 comm="apparmor_parser"
[    7.158380] audit: type=1400 audit(1505169890.271:7): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/NetworkManager/nm-dhcp-helper" pid=774 comm="apparmor_parser"
[    7.158384] audit: type=1400 audit(1505169890.271:8): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/connman/scripts/dhclient-script" pid=774 comm="apparmor_parser"
[    7.163650] audit: type=1400 audit(1505169890.277:9): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/sbin/cups-browsed" pid=778 comm="apparmor_parser"
[    7.164120] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 16 -> VIRQ 226
[    7.164479] audit: type=1400 audit(1505169890.277:10): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/lightdm/lightdm-guest-session" pid=773 comm="apparmor_parser"
[    7.164488] audit: type=1400 audit(1505169890.277:11): apparmor="STATUS" operation="profile_load" profile="unconfined" name="/usr/lib/lightdm/lightdm-guest-session//chromium" pid=773 comm="apparmor_parser"
[    7.190382] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 17 -> VIRQ 227
[    7.216214] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 18 -> VIRQ 228
[    7.240200] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 19 -> VIRQ 229
[    7.268249] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 24 -> VIRQ 234
[    7.296595] axp288_fuel_gauge axp288_fuel_gauge: HW IRQ 25 -> VIRQ 235
[    7.312923] media: Linux media interface: v0.10
[    7.336460] Linux video capture interface: v2.00
[    7.540364] uvcvideo: Found UVC 1.00 device USB2.0 PC CAMERA (1908:2311)
[    7.540819] uvcvideo 1-4:1.0: Entity type for entity Processing 2 was not initialized!
[    7.540824] uvcvideo 1-4:1.0: Entity type for entity Camera 1 was not initialized!
[    7.541840] input: USB2.0 PC CAMERA: USB2.0 PC CAM as /devices/pci0000:00/0000:00:14.0/usb1/1-4/1-4:1.0/input/input11
[    7.542105] usbcore: registered new interface driver uvcvideo
[    7.542107] USB Video Class driver (1.1.1)
[    7.638684] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    7.638688] Bluetooth: BNEP filters: protocol multicast
[    7.638695] Bluetooth: BNEP socket layer initialized
[    8.621124] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[    8.625345] rtl8723bs: acquire FW from file:rtlwifi/rtl8723bs_nic.bin
[    8.654328] random: crng init done
[   10.049264] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   10.292508] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   10.458382] Non-volatile memory driver v1.3
[   14.078450] RTL8723BS: rtw_set_802_11_connect(wlan0)  fw_state = 0x00000008
[   14.388690] RTL8723BS: start auth
[   14.391576] RTL8723BS: auth success, start assoc
[   14.396881] RTL8723BS: rtw_cfg80211_indicate_connect(wlan0) BSS not found !!
[   14.396894] RTL8723BS: assoc success
[   14.396948] IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   14.402468] RTL8723BS: send eapol packet
[   14.410078] RTL8723BS: send eapol packet
[   14.612292] RTL8723BS: set pairwise key camid:4, addr:90:f6:52:ff:d9:6f, kid:0, type:AES
[   14.613630] RTL8723BS: set group key camid:5, addr:90:f6:52:ff:d9:6f, kid:2, type:TKIP
```
