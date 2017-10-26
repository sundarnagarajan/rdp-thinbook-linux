#!/bin/bash
SOUNDCARD_PREFIX=bytcht
ALSA_SOUNDCARD=$(cat /proc/asound/cards | awk -F: '{print $2}' | awk -F' - ' '{if ($1 != "") {print $2} }' | grep "^${SOUNDCARD_PREFIX}")
if [ -z "$ALSA_SOUNDCARD" ]; then
    echo "No sound card matching $SOUNDCARD_PREFIX found"
    exit 1
fi
echo "Using sound card $ALSA_SOUNDCARD"
echo "Front-Left"
speaker-test -d ${ALSA_SOUNDCARD} -t wav -c2 -s1 1>/dev/null 2>&1
echo "Front-Right"
speaker-test -d ${ALSA_SOUNDCARD} -t wav -c2 -s2 1>/dev/null 2>&1
