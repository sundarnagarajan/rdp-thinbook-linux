## Kernel config entries required
```
CONFIG_RTL8723BS=m
CONFIG_AXP288_CHARGER=m
CONFIG_AXP288_FUEL_GAUGE=m
CONFIG_EXTCON_AXP288=m
CONFIG_AXP288_ADC=m
CONFIG_SND_SOC_INTEL_BYT_CHT_ES8316_MACH=m
CONFIG_SND_SOC_ES8316=m
CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH=m
CONFIG_SND_SOC_RT5651=m
```
## Kernel config entries explained
### Make Wifi work (Realtek 8723BS chipset)
- ```CONFIG_RTL8723BS``` Introduced in [kernel 4.12](https://cateee.net/lkddb/web-lkddb/RTL8723BS.html)
### Make battery gauge work
- ```CONFIG_AXP288_FUEL_GAUGE``` introduced in [kernel 4.1](https://cateee.net/lkddb/web-lkddb/AXP288_FUEL_GAUGE.html)
- ```CONFIG_AXP288_CHARGER``` introduced in [kernel 4.2](https://cateee.net/lkddb/web-lkddb/AXP288_CHARGER.html)
- ```CONFIG_EXTCON_AXP288``` introduced in [kernel 4.2](https://cateee.net/lkddb/web-lkddb/EXTCON_AXP288.html)
- ```CONFIG_AXP288_ADC``` introduced in [kernel 3.9](https://cateee.net/lkddb/web-lkddb/AXP288_ADC.html)
- Critical bug was fixed in 4.12
### Make bytcht-es8316 sound card work (14-inch RDP Thinbook)
- ```CONFIG_SND_SOC_INTEL_BYT_CHT_ES8316_MACH``` introduced in [kernel 4.13](https://cateee.net/lkddb/web-lkddb/SND_SOC_INTEL_BYT_CHT_ES8316_MACH.html)
- ```CONFIG_SND_SOC_ES8316``` introduced in [kernel 4.13](https://cateee.net/lkddb/web-lkddb/SND_SOC_ES8316.html)
### Make bytcr-rt6551 sound card work (11-inch RDP Thinbook)
- ```CONFIG_SND_SOC_RT5651``` introduced in [kernel ](https://cateee.net/lkddb/web-lkddb/SND_SOC_RT5651.html)
- ```CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH``` introduced in [kernel 4.5](https://cateee.net/lkddb/web-lkddb/SND_SOC_INTEL_BYTCR_RT5651_MACH.html)
### HDMI audio without HDaudio on Intel Atom platforms
- ```CONFIG_HDMI_LPE_AUDIO``` introduced in [kernel 4.11](https://cateee.net/lkddb/web-lkddb/HDMI_LPE_AUDIO.html)
- Note: currently we **BLACKLIST** this module if pulseaudio version >= 1:10.0-2ubuntu3 because loading this module prevents pulseaudio (version >= 1:10.0-2ubuntu3) from starting in daemon mode
## Kernel 4.13.x on Ubuntu 17.10 (Artful Aardvark)
All the above entries are present

However a 1-line patch is required for Bluetooth (rt8723bs_bt) to work properly:
```diff
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 76c01cb..4e32def 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -163,6 +163,7 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
 static const struct acpi_device_id rfkill_acpi_match[] = {
 	{ "BCM4752", RFKILL_TYPE_GPS },
 	{ "LNV4752", RFKILL_TYPE_GPS },
+     { "OBDA8723",RFKILL_TYPE_BLUETOOTH },
 	{ },
 };
 MODULE_DEVICE_TABLE(acpi, rfkill_acpi_match);
```
