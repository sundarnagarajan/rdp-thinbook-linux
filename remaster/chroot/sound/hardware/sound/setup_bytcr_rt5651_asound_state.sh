#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")
PROG_NAME=$(basename $0)

DMESG_INDICATOR="bytcr_rt5651 bytcr_rt5651: snd-soc-dummy-dai <-> media-cpu-dai mapping ok"
ASOUND_STATE_DIR=/usr/share/alsa/ucm/bytcr-rt5651
ASOUND_SOURCE=${ASOUND_STATE_DIR}/asound.state
ASOUND_TARGET=/var/lib/alsa/asound.state

# If there is no source file existing, cannot do anything anyway!
if [ ! -f ${ASOUND_SOURCE} ]; then
    echo "Source asound.state not found: ${ASOUND_SOURCE}"
    exit 1
fi

MAX_SLEEP_SECS=20
SLEEP_SECS=1
SLEPT_SECS=0
SOUNDCARD_PREFIX="bytcr-rt5651"
while true
do
    ALSA_SOUNDCARD=$(cat /proc/asound/cards | awk -F: '{print $2}' | awk -F' - ' '{if ($1 != "") {print $2} }' | egrep "^(${SOUNDCARD_PREFIX})")
    if [ -n "$ALSA_SOUNDCARD" ]; then
        if [ -n "$(ls -A /dev/snd/control* 2>/dev/null)" ]; then
            echo "Found sound card: $SOUNDCARD_PREFIX"
            break
        fi
    fi
    sleep $SLEEP_SECS
    SLEPT_SECS=$(($SLEPT_SECS + $SLEEP_SECS))
    if [ $SLEPT_SECS -gt $MAX_SLEEP_SECS ]; then
        echo "Max time exceeded $MAX_SLEEP_SECS seconds. Exiting"
        exit 1
    fi
done

# Sleep a few secs - let rest of the system finish booting
sleep 2

# Check that bytcr_rt5651 sound card is present and activated in kernel
dmesg | fgrep -q "$DMESG_INDICATOR"
if [ $? -ne 0 ]; then
    echo "bytcr-rt5651 sound card not present"
    exit 0
fi

# Do not overwrite existing /var/lib/alsa/asound.state unless -f is used
if [ -f ${ASOUND_TARGET} ]; then
    if [ "$1" != "-f" ]; then
        echo "Not overwriting existing ${ASOUND_TARGET}"
        exit 0
    fi
fi

# If we got here ASOUND_TARGET is not present OR we got the -f option
mkdir -p $(dirname ${ASOUND_TARGET})
\cp -f ${ASOUND_SOURCE} ${ASOUND_TARGET}
/usr/sbin/alsactl restore 2>&1
exit $?
