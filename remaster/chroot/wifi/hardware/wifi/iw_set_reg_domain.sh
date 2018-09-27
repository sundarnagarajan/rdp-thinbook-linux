#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")
PROG_NAME=$(basename $0)

COUNTRY_FILE=/etc/default/iw_regulatory_country
IW_PATH=/sbin/iw
FOUND=0

if [ -f "$COUNTRY_FILE" ]; then
    . $COUNTRY_FILE 1>/dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ -n "$COUNTRY" ]; then
            if [ -x $IW_PATH ]; then
                $IW_PATH reg set $COUNTRY
                $IW_PATH reg get
            else
                echo "iw not found: $IW_PATH"
                exit 1
            fi
        else
            echo "COUNTRY variable not set"
            exit 1
        fi
    else
        echo "Error sourcing $COUNTRY_FILE"
        exit 1
    fi

else
    echo "File not found: $COUNTRY_FILE"
    exit 1
fi
