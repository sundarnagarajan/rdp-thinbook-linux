#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")
PROG_NAME=$(basename $0)
LOGCMD="/usr/bin/logger -t ${PROG_NAME}"

DMESG_INDICATOR="bytcr_rt5651 bytcr_rt5651: snd-soc-dummy-dai <-> media-cpu-dai mapping ok"
ASOUND_STATE_DIR=/usr/share/alsa/ucm/bytcr-rt5651
ASOUND_SOURCE=${ASOUND_STATE_DIR}/asound.state
ASOUND_TARGET=/var/lib/alsa/asound.state


# If there is no source file existing, cannot do anything anyway!
if [ ! -f ${ASOUND_SOURCE} ]; then
    $LOGCMD "Source asound.state not found: ${ASOUND_SOURCE}"
    exit 1
fi

# Check that bytcr_rt5651 sound card is present and activated in kernel
dmesg | fgrep -q "$DMESG_INDICATOR"
if [ $? -ne 0 ]; then
    $LOGCMD "bytcr-rt5651 sound card not present"
    exit 0
fi

# Do not overwrite existing /var/lib/alsa/asound.state unless -f is used
if [ -f ${ASOUND_TARGET} ]; then
    if [ "$1" != "-f" ]; then
        $LOGCMD "Not overwriting existing ${ASOUND_TARGET}"
        exit 0
    fi
fi

# If we got here ASOUND_TARGET is not present OR we got the -f option
\cp -f ${ASOUND_SOURCE} ${ASOUND_TARGET}
/usr/sbin/alsactl restore 2>&1 | $LOGCMD
exit $?
