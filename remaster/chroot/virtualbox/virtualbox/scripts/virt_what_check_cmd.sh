#!/bin/bash
VIRT_WHAT=$(/usr/bin/which virt-what 2>/dev/null)
if [ -z "$VIRT_WHAT" ]; then
    # Try checking output of lscpu instead
    if [ -x /usr/bin/lscpu ]; then
        /usr/bin/lscpu | grep -q hypervisor
        ret=$?
        if [ $ret -eq 0 ]; then
            >&2 echo "Running in hypervisor; starting $(basename $0)"
        else
            >&2 echo "Running in hypervisor; NOT starting $(basename $0)"
        fi
        return $ret
    else
        >&2 echo "Neither virt-what nor lscpu not found"
        exit 0
    fi
fi
$VIRT_WHAT | grep -q virtualbox
ret=$?
if [ $ret -eq 0 ]; then
    >&2 echo "Running in virtualbox; starting $(basename $0)"
else
    >&2 echo "Not running in virtualbox; NOT starting $(basename $0)"
fi
exit $ret
