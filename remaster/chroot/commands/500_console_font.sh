#!/bin/bash
# Fix console font (esp on HiDPI machines)

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SETUPCON_DIR=${PROG_DIR}/../setupcon
SETUPCON_DIR=$(readlink -m "$SETUPCON_DIR")
[[ -d "$SETUPCON_DIR" ]] || exit 0

SETUPCON_SERVICE_FILE=fix_tty1_font.service
SETUPCON_CONSOLE_SETUP=console-setup

# First add to /etc/default/console-setup
[[ -f "$SETUPCON_DIR"/"$SETUPCON_CONSOLE_SETUP" ]] && {
    cat "$SETUPCON_DIR"/"$SETUPCON_CONSOLE_SETUP" >> /etc/default/console-setup
    echo "Setup /etc/default/console-setup"
    # Add service
    [[ -f "$SETUPCON_DIR"/"$SETUPCON_SERVICE_FILE" ]] && {
        \cp -f "$SETUPCON_DIR"/"$SETUPCON_SERVICE_FILE" /etc/systemd/system/ && \
        mkdir -p /etc/systemd/system/default.target.wants && \
        ln -sf /etc/systemd/system/"$SETUPCON_SERVICE_FILE" /etc/systemd/system/default.target.wants/ && \
        echo "Setup $SETUPCON_SERVICE_FILE"
    } || {
        echo "File not found: ${SETUPCON_DIR}/${SETUPCON_SERVICE_FILE}"
    }
} || {
    echo "File not found: ${SETUPCON_DIR}/${SETUPCON_CONSOLE_SETUP}"
}
