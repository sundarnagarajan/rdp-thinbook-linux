#!/bin/bash
# Install scripts related to making r8723bs bluetooth work

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

R8723_SCRIPTS_DIR=${PROG_DIR}/../r8723bs-bluetooth
FW=${R8723_SCRIPTS_DIR}/hardware/bluetooth/rtl8723bs_bt/rtlbt_fw
FW_CONFIG=${R8723_SCRIPTS_DIR}/hardware/bluetooth/rtl8723bs_bt/rtlbt_config
FW_NEW_NAME=rtl8723bs_fw.bin
FW_CONFIG_NEW_NAME=rtl8723bs_config-OBDA8723.bin
FW_DEST_DIR=/lib/firmware/rtl_bt

if [ ! -f $FW ]; then
    echo "Firmware not found: $FW"
    exit 0
fi
mkdir -p /lib/firmware/rtl_bt
\cp -f "$FW" "${FW_DEST_DIR}/$FW_NEW_NAME"
if [ ! -f $FW_CONFIG ]; then
    echo "Firmware config not found: $FW_CONFIG"
    exit 0
fi
\cp -f "$FW_CONFIG" "${FW_DEST_DIR}/$FW_CONFIG_NEW_NAME"

echo ""
echo "---------------------------------------------------------------------------"
echo "Making r8723bs Bluetooth work"
echo ""
echo "rtlbt_fw and rtlbt_config are from:"
echo "https://github.com/lwfinger/rtl8723bs_bt.git"
echo "This source is licensed under the same terms as the original."
echo "If there is no LICENSE specified by the original author, this"
echo "source is hereby licensed under the GNU General Public License version 2."
echo ""
echo "For license detils, see /root/hardware/LICENSE and "
echo "/root/hardware/bluetooth/rtl8723bs_bt/LICENSE"
echo "---------------------------------------------------------------------------"
echo ""
