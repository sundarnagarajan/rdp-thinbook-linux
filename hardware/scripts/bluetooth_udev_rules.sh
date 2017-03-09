#!/bin/bash
# $1: HCI device (e.g. hci0). If unset, defaults to hci0

HCIDEV=${1:-hci0}
if [ "$RFKILL_TYPE" != "bluetooth" ]; then
	exit 0
fi
if [ "$RFKILL_NAME" != "$HCIDEV" ]; then
	exit 0
fi
if [ "$RFKILL_STATE" = "0" ]; then
	/usr/bin/logger -t r8723bs_bt_firmware "$0 running for RFKILL_STATE=1"
	/root/hardware/bluetooth/rtl8723bs_bt/start_bt.sh
fi
