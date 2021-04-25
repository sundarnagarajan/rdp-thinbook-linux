#!/bin/sh
PROG_DIR=$(dirname "$0")

if [ -x "$PROG_DIR"/dpi_meets_threshold ]; then
    "$PROG_DIR"/dpi_meets_threshold $@
    ret=$?
    if [ $ret -eq 0 ]; then
        >&2 echo "Meets threshold"
        # Do other things
    else
        >&2 echo "Does not meet threshold"
        exit $ret
    fi
fi
