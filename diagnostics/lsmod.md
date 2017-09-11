## output of lsmod (Kernel 4.13.1)
```
Module                  Size  Used by
nvram                  16384  0
msr                    16384  0
rtsx_usb_ms            20480  0
memstick               16384  1 rtsx_usb_ms
input_leds             16384  0
joydev                 20480  0
bnep                   20480  2
uvcvideo               90112  0
videobuf2_vmalloc      16384  1 uvcvideo
videobuf2_memops       16384  1 videobuf2_vmalloc
videobuf2_v4l2         24576  1 uvcvideo
videobuf2_core         40960  2 uvcvideo,videobuf2_v4l2
videodev              172032  3 uvcvideo,videobuf2_core,videobuf2_v4l2
media                  40960  2 uvcvideo,videodev
cmdlinepart            16384  0
intel_spi_platform     16384  0
intel_spi              20480  1 intel_spi_platform
spi_nor                28672  1 intel_spi
mtd                    57344  4 spi_nor,intel_spi,cmdlinepart
snd_soc_sst_byt_cht_es8316    16384  0
axp288_charger         20480  0
axp288_fuel_gauge      20480  0
axp288_adc             16384  0
axp20x_pek             16384  0
extcon_axp288          16384  0
nls_iso8859_1          16384  1
gpio_keys              20480  0
intel_rapl             20480  0
intel_powerclamp       16384  0
coretemp               16384  0
kvm_intel             196608  0
kvm                   581632  1 kvm_intel
irqbypass              16384  1 kvm
punit_atom_debug       16384  0
crct10dif_pclmul       16384  0
crc32_pclmul           16384  0
ghash_clmulni_intel    16384  0
pcbc                   16384  0
aesni_intel           188416  0
aes_x86_64             20480  1 aesni_intel
crypto_simd            16384  1 aesni_intel
glue_helper            16384  1 aesni_intel
cryptd                 24576  3 crypto_simd,ghash_clmulni_intel,aesni_intel
intel_cstate           16384  0
wdat_wdt               16384  0
mei_txe                20480  0
mei                    98304  1 mei_txe
processor_thermal_device    16384  0
lpc_ich                24576  0
snd_hdmi_lpe_audio     24576  0
snd_intel_sst_acpi     16384  1
intel_soc_dts_iosf     16384  1 processor_thermal_device
snd_intel_sst_core     77824  1 snd_intel_sst_acpi
snd_soc_sst_atom_hifi2_platform   102400  3 snd_intel_sst_core
snd_soc_sst_match      16384  1 snd_intel_sst_acpi
mac_hid                16384  0
fdp_i2c                16384  0
hci_uart              102400  1
snd_seq_midi           16384  0
snd_soc_rt5670        131072  0
btbcm                  16384  1 hci_uart
dw_dmac                16384  2
snd_soc_rt5645        147456  0
snd_soc_rt5640        118784  0
fdp                    20480  1 fdp_i2c
serdev                 20480  1 hci_uart
snd_seq_midi_event     16384  1 snd_seq_midi
r8723bs               602112  0
nci                    69632  1 fdp
dw_dmac_core           24576  1 dw_dmac
snd_soc_es8316         36864  1
btqca                  16384  1 hci_uart
intel_hid              16384  0
extcon_intel_int3496    16384  0
snd_soc_rl6231         16384  3 snd_soc_rt5670,snd_soc_rt5640,snd_soc_rt5645
btintel                16384  1 hci_uart
sparse_keymap          16384  1 intel_hid
intel_soc_pmic_bxtwc    16384  0
nfc                   114688  1 nci
intel_pmc_ipc          20480  1 intel_soc_pmic_bxtwc
snd_soc_core          229376  6 snd_soc_sst_byt_cht_es8316,snd_soc_rt5670,snd_soc_rt5640,snd_soc_sst_atom_hifi2_platform,snd_soc_es8316,snd_soc_rt5645
axp20x_i2c             16384  0
snd_rawmidi            32768  1 snd_seq_midi
bmg160_i2c             16384  0
goodix                 16384  0
axp20x                 24576  1 axp20x_i2c
snd_compress           20480  1 snd_soc_core
silead                 16384  0
kxcjk_1013             20480  0
bluetooth             544768  26 hci_uart,btintel,btqca,bnep,btbcm
bmg160_core            20480  1 bmg160_i2c
ac97_bus               16384  1 snd_soc_core
cfg80211              610304  1 r8723bs
snd_seq                65536  2 snd_seq_midi_event,snd_seq_midi
snd_pcm_dmaengine      16384  1 snd_soc_core
industrialio_triggered_buffer    16384  2 kxcjk_1013,bmg160_core
kfifo_buf              16384  1 industrialio_triggered_buffer
ecdh_generic           24576  1 bluetooth
snd_pcm                98304  9 snd_soc_sst_byt_cht_es8316,snd_soc_rt5670,snd_hdmi_lpe_audio,snd_pcm_dmaengine,snd_soc_rt5640,snd_soc_sst_atom_hifi2_platform,snd_soc_es8316,snd_soc_rt5645,snd_soc_core
industrialio           69632  6 kxcjk_1013,axp288_adc,bmg160_core,axp288_fuel_gauge,industrialio_triggered_buffer,kfifo_buf
snd_seq_device         16384  3 snd_seq,snd_rawmidi,snd_seq_midi
intel_cht_int33fe      16384  0
rfkill_gpio            16384  0
snd_timer              32768  2 snd_seq,snd_pcm
snd                    77824  9 snd_compress,snd_seq,snd_hdmi_lpe_audio,snd_timer,snd_soc_sst_atom_hifi2_platform,snd_rawmidi,snd_seq_device,snd_soc_core,snd_pcm
8250_dw                16384  0
pwm_lpss_platform      16384  0
soundcore              16384  1 snd
pwm_lpss               16384  1 pwm_lpss_platform
spi_pxa2xx_platform    24576  0
tpm_crb                16384  0
int3400_thermal        16384  0
intel_int0002_vgpio    16384  1
soc_button_array       16384  0
dptf_power             16384  0
acpi_thermal_rel       16384  1 int3400_thermal
acpi_pad               24576  0
int3406_thermal        16384  0
int3403_thermal        16384  0
int340x_thermal_zone    16384  2 int3403_thermal,processor_thermal_device
parport_pc             32768  0
ppdev                  20480  0
lp                     20480  0
parport                49152  3 lp,parport_pc,ppdev
autofs4                40960  2
hid_generic            16384  0
usbhid                 49152  0
rtsx_usb_sdmmc         28672  0
rtsx_usb               20480  2 rtsx_usb_sdmmc,rtsx_usb_ms
i915                 1798144  4
mmc_block              36864  4
i2c_algo_bit           16384  1 i915
drm_kms_helper        167936  1 i915
syscopyarea            16384  1 drm_kms_helper
sysfillrect            16384  1 drm_kms_helper
sysimgblt              16384  1 drm_kms_helper
fb_sys_fops            16384  1 drm_kms_helper
drm                   356352  5 i915,drm_kms_helper
i2c_hid                20480  0
video                  40960  2 int3406_thermal,i915
hid                   118784  3 i2c_hid,hid_generic,usbhid
sdhci_acpi             16384  0
sdhci                  45056  1 sdhci_acpi
pinctrl_cherryview     36864  19
```
