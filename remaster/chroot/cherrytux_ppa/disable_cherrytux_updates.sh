#!/bin/bash
# ------------------------------------------------------------------------
# This script holds back cherrytux-image and cherrytux-headers so that
# you will not get automatic kernel updates from the cherrytux PPA
# ------------------------------------------------------------------------
for p in cherrytux-image cherrytux-headers
do
    apt-mark showhold | fgrep -qx $p
    if [ $? -ne 0 ]; then
        apt-mark hold $p
    fi
done
