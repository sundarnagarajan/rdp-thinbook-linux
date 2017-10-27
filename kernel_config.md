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
Introduced in [kernel 4.12](https://cateee.net/lkddb/web-lkddb/RTL8723BS.html)
```
CONFIG_RTL8723BS=m
```
### Make battery gauge work
- CONFIG_AXP288_FUEL_GAUGE introduced in [kernel 4.1](https://cateee.net/lkddb/web-lkddb/AXP288_FUEL_GAUGE.html)
- CONFIG_AXP288_CHARGER introduced in [kernel 4.2](https://cateee.net/lkddb/web-lkddb/AXP288_CHARGER.html)
- CONFIG_EXTCON_AXP288 introduced in [kernel 4.2](https://cateee.net/lkddb/web-lkddb/EXTCON_AXP288.html)
- CONFIG_AXP288_ADC introduced in [kernel 3.9](https://cateee.net/lkddb/web-lkddb/AXP288_ADC.html)
Critical bug was fixed in 4.12
```
CONFIG_AXP288_CHARGER=m
CONFIG_AXP288_FUEL_GAUGE=m
CONFIG_EXTCON_AXP288=m
CONFIG_AXP288_ADC=m
```
### Make bytcht-es8316 sound card work (14-inch RDP Thinbook)
- CONFIG_SND_SOC_INTEL_BYT_CHT_ES8316_MACH introduced in [kernel 4.13](https://cateee.net/lkddb/web-lkddb/SND_SOC_INTEL_BYT_CHT_ES8316_MACH.html)
- CONFIG_SND_SOC_ES8316 introduced in [kernel 4.13](https://cateee.net/lkddb/web-lkddb/SND_SOC_ES8316.html)
```
CONFIG_SND_SOC_INTEL_BYT_CHT_ES8316_MACH=m
CONFIG_SND_SOC_ES8316=m
```
### Make bytcr-rt6551 sound card work (11-inch RDP Thinbook)
- CONFIG_SND_SOC_RT5651 introduced in [kernel ](https://cateee.net/lkddb/web-lkddb/SND_SOC_RT5651.html)
- CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH introduced in [kernel 4.5](https://cateee.net/lkddb/web-lkddb/SND_SOC_INTEL_BYTCR_RT5651_MACH.html)
```
CONFIG_SND_SOC_INTEL_BYTCR_RT5651_MACH=m
CONFIG_SND_SOC_RT5651=m
```
