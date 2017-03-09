#!/bin/bash
# $1: HCI device (e.g. hci0). If unset, defaults to hci0

HCIDEV="${1:-hci0}"
# No need to run if $HCIDEV is already detected
if [ -e /sys/class/bluetooth/${HCIDEV} ]; then
	echo "${HCIDEV} already detected. Nothing to do"
	exit 0
fi

/usr/sbin/rfkill unblock bluetooth
sleep 3
/root/hardware/bluetooth/rtl8723bs_bt/start_bt.sh
