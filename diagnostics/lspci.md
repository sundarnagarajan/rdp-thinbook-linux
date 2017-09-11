## PCI devices

| B:D:F | VID:PID | ModUsed | ModAvail | Rev | Class | Description |
| ----- | ------- | ------- | -------- | --- | ----- | ----------- |
| 00:1f.0 | 8086:229c | lpc_ich |  | 22 | ISA bridge | Intel Device 229c |
| 00:02.0 | 8086:22b0 | i915 | 22 | VGA compatible controller | Intel Device 22b0 |
| 00:14.0 | 8086:22b5 | xhci_hcd | None | 22 | USB controller | Intel Device 22b5 |
| 00:1a.0 | 8086:2298 | mei_txe |  | 22 | Encryption controller | Intel Device 2298 |

## Raw lspci -nn output
```
00:00.0 Host bridge [0600]: Intel Corporation Device [8086:2280] (rev 22)
00:02.0 VGA compatible controller [0300]: Intel Corporation Device [8086:22b0] (rev 22)
00:03.0 Multimedia controller [0480]: Intel Corporation Device [8086:22b8] (rev 22)
00:0b.0 Signal processing controller [1180]: Intel Corporation Device [8086:22dc] (rev 22)
00:14.0 USB controller [0c03]: Intel Corporation Device [8086:22b5] (rev 22)
00:1a.0 Encryption controller [1080]: Intel Corporation Device [8086:2298] (rev 22)
00:1f.0 ISA bridge [0601]: Intel Corporation Device [8086:229c] (rev 22)
```
