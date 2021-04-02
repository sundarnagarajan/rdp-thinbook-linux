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

# No longer required starting with Groovy (20.10) kernel 5.8
MIN_RELEASE=20.10
CUR_RELEASE=$(cat /etc/os-release | grep '^VERSION_ID' | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//')
[[ "$( (echo $MIN_RELEASE; echo $CUR_RELEASE) | sort -Vr | tail -1)" = "$MIN_RELEASE" ]] && {
    MIN_KERNEL=5.8
    MAX_KERNEL_VER_INSTALLED=$(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $3}' |sort -Vr | head -1)
    [[ "$( (echo $MIN_KERNEL; echo $MAX_KERNEL_VER_INSTALLED) | sort -Vr | tail -1)" = "$MIN_KERNEL" ]] && {
        echo "Current kernel (${MAX_KERNEL_VER_INSTALLED}) meets minimum requirements (${MIN_KERNEL})"
        echo "Current release (${CUR_RELEASE}) meets minimum release (${MIN_RELEASE})"
        echo "Not installing fixes for RTL8723bs_bt bluetooth"
        exit 0
    }
}

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
