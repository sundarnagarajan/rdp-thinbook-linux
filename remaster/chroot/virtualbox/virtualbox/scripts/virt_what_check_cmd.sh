#!/bin/bash
VIRT_WHAT=$(/usr/bin/which virt-what 2>/dev/null)
if [ -z "$VIRT_WHAT" ]; then
    >&2 echo "virt-what not found"
    exit 0
fi
$VIRT_WHAT | grep -q virtualbox
ret=$?
if [ $ret -eq 0 ]; then
    >&2 echo "Running in virtualbox"
    >&2 echo "$(basename $0) : OK"
else
    >&2 echo "Not running in virtualbox"
    >&2 echo "$(basename $0) : Not started"
fi
exit $ret
