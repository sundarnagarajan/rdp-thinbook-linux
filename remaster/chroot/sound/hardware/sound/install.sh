#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")

# Check that required scripts are present
if [ ! -d ${PROG_DIR}/UCM ]; then
    echo "Missing dir: ${PROG_DIR}/UCM"
    exit 1
fi
if [ ! -f ${PROG_DIR}/rdp-sound-modules.conf ]; then
    echo "Missing file: ${PROG_DIR}/rdp-sound-modules.conf"
    exit 1
fi

\cp -frv ${PROG_DIR}/UCM/* /usr/share/alsa/ucm/
\cp -frv ${PROG_DIR}/rdp-sound-modules.conf /etc/modprobe.d/

# On RDP Thinbook, set the default output (sink)
# alsa_output.platform-bytcht_es8316.HiFi__hw_bytchtes8316__sink : 14-inch RDP Thinbook
# alsa_output.platform-bytcr_rt5651.HiFi__hw_bytcrrt5651__sink : 11-inch RDP Thinbook
OUTPUTS="alsa_output.platform-bytcht_es8316.HiFi__hw_bytchtes8316__sink alsa_output.platform-bytcr_rt5651.HiFi__hw_bytcrrt5651__sink"
if [ -f /etc/pulse/default.pa ]; then
    (
        echo ""
        echo "# On RDP Thinbook, set the default output (sink)"
        echo "# Sinks are tried IN ORDER. If only ONE of these sinks are available,"
        echo "# then that sink will be the default output"
        echo "# If more than one of these sinks are available, then the LAST one"
        echo "# will be the default output"
        echo "#"
        for output in $OUTPUTS
        do
            echo "set-default-sink $output"
        done
    ) >> /etc/pulse/default.pa
else
    echo "Missing file: /etc/pulse/default.pa"
fi
