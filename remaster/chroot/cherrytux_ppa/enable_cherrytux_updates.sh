#!/bin/bash
# ------------------------------------------------------------------------
# This script disables hold for cherrytux-image and cherrytux-headers
# so that you WILL get automatic kernel updates from the cherrytux PPA
# ------------------------------------------------------------------------
for p in cherrytux-image cherrytux-headers
do
    apt-mark showhold | fgrep -qx $p
    if [ $? -eq 0 ]; then
        apt-mark unhold $p
    fi
done
