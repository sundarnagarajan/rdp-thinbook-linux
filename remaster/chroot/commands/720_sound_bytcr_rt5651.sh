#!/bin/bash
# Install files related to making sound work

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SOUND_SCRIPTS_DIR=${PROG_DIR}/../sound

MIN_RELEASE=20.10
CUR_RELEASE=$(cat /etc/os-release | grep '^VERSION_ID' | cut -d= -f2 | sed -e 's/^"//' -e 's/"$//')
[[ "$( (echo $MIN_RELEASE; echo $CUR_RELEASE) | sort -Vr | tail -1)" = "$MIN_RELEASE" ]] && {
    MIN_KERNEL=5.8
    MAX_KERNEL_VER_INSTALLED=$(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $3}' |sort -Vr | head -1)
    [[ "$( (echo $MIN_KERNEL; echo $MAX_KERNEL_VER_INSTALLED) | sort -Vr | tail -1)" = "$MIN_KERNEL" ]] && {
        echo "Current kernel (${MAX_KERNEL_VER_INSTALLED}) meets minimum requirements (${MIN_KERNEL})"
        echo "Current release (${CUR_RELEASE}) meets minimum release (${MIN_RELEASE})"
        echo "Not installing fixes for bytcr_rt5651 sound"
        exit 0
    }
}

if [ ! -d ${SOUND_SCRIPTS_DIR} ]; then
    echo "SOUND_SCRIPTS_DIR not a directory: $SOUND_SCRIPTS_DIR"
    exit 0
fi
SOUND_SCRIPTS_DIR=$(readlink -e $SOUND_SCRIPTS_DIR)
test "$(ls -A $SOUND_SCRIPTS_DIR)"
if [ $? -ne 0 ]; then
    echo "No files to copy: $SOUND_SCRIPTS_DIR"
    exit 0
fi

mkdir -p /root
cp -r ${SOUND_SCRIPTS_DIR}/. /root/

if [ ! -x /root/hardware/sound/install.sh ]; then
    echo "Not found or not executable: /root/hardware/sound/install.sh"
    exit 0
fi
if [ ! -f //root/hardware/sound/LICENSE ]; then
    echo "Missing file: /root/hardware/sound//LICENSE"
    exit 1
fi
cat /root/hardware/sound/LICENSE
echo ""


/root/hardware/sound/install.sh
