#!/bin/bash
#
# Shell script to install Bluetooth firmware and attach BT part of
# RTL8723BS
#

TTY=${1:-""}

cd $(/bin/readlink -f $(/usr/bin/dirname $0))

if [ "$TTY" = "" ]
then
    # Find the TTY attached to the BT device
    TTYSTRING=`dmesg -t | grep tty | grep MMIO | cut -b 14-18`
    if [ "$TTYSTRING" = "" ]
    then
	echo
	echo "No BT TTY device has been found"
	echo "Either this computer has no BT device that uses hciattach, or"
	echo "Your kernel does not have module 8250_dw configured."
	echo "Note: The configuration variable is CONFIG_SERIAL_8250_DW."
	echo
	exit 1
    fi
    TTY=`expr substr "$TTYSTRING" 1 5`
fi

TTY="/dev/$TTY"
echo "Using device $TTY for Bluetooth"

LIB_FW_DIR=/lib/firmware/rtl_bt
for FW_FILE in rtlbt_config  rtlbt_fw  rtlbt_fw_new
do
	if [ ! -f ${LIB_FW_DIR}/${FW_FILE} ]; then
		echo "Copying missing file ${FW_FILE} to ${LIB_FW_DIR}"
		cp -v ${FW_FILE} ${LIB_FW_DIR}/
	fi
done


# Run in background - works well udev trigger and in rc.local
./rtk_hciattach -n -s 115200 $TTY rtk_h5 1>/dev/null 2>&1 &
