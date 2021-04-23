#!/bin/bash
# Fix console font (esp on HiDPI machines)

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
FAILED_EXIT_CODE=1


SETUPCON_DIR=${PROG_DIR}/../setupcon
SETUPCON_DIR=$(readlink -m "$SETUPCON_DIR")
[[ -d "$SETUPCON_DIR" ]] || exit $FAILED_EXIT_CODE

SETUPCON_CONSOLE_SETUP_DEFAULT=console-setup.default
SETUPCON_CONSOLE_SETUP_LARGE=console-setup.large
SETUPCON_THRESHOLD_CHECK=dpi_meets_threshold.sh
SETUPCON_TTY1_SERVICE_FILE=fix_tty1_font.service
SETUPCON_CONSOLEFONT_SERVICE_FILE=fix_console-font.service

for f in "${SETUPCON_THRESHOLD_CHECK}" "${SETUPCON_CONSOLE_SETUP_LARGE}" "${SETUPCON_CONSOLEFONT_SERVICE_FILE}" "${SETUPCON_TTY1_SERVICE_FILE}"
do
    [[ -f "${SETUPCON_DIR}"/"$f" ]] || {
        echo "File not found: ${SETUPCON_DIR}/$f"
        exit $FAILED_EXIT_CODE
    }
done

for pkg in console-setup-linux
do
    dpkg -l $pkg 2>/dev/null | grep -q '^ii' || {
        echo "Package not installed: $pkg"
        exit $FAILED_EXIT_CODE
    }
done
for cmd in setupcon openvt
do
    command -v $cmd 1>/dev/null 2>&1 || {
        echo "Command not found: $cmd"
        exit $FAILED_EXIT_CODE
    }
done

[[ -f /etc/default/console-setup ]] || {
    echo "File not found: /etc/console-setup"
    exit $FAILED_EXIT_CODE
}
# Actual steps after this

\cp -f /etc/default/console-setup /etc/default/${SETUPCON_CONSOLE_SETUP_DEFAULT} || exit $FAILED_EXIT_CODE
\cp -f "${SETUPCON_DIR}"/"${SETUPCON_CONSOLE_SETUP_LARGE}" /etc/default/ || exit $FAILED_EXIT_CODE
\cp -f "${SETUPCON_DIR}"/"${SETUPCON_THRESHOLD_CHECK}" /usr/local/bin/ || exit $FAILED_EXIT_CODE
\cp -f "${SETUPCON_DIR}"/"${SETUPCON_CONSOLEFONT_SERVICE_FILE}" /etc/systemd/system/ || exit $FAILED_EXIT_CODE
\cp -f "${SETUPCON_DIR}"/"${SETUPCON_TTY1_SERVICE_FILE}" /etc/systemd/system/ || exit $FAILED_EXIT_CODE
mkdir -p /etc/systemd/system/default.target.wants && \
    ln -sf /etc/systemd/system/"${SETUPCON_CONSOLEFONT_SERVICE_FILE}" /etc/systemd/system/default.target.wants/ && \
    echo "Setup ${SETUPCON_CONSOLEFONT_SERVICE_FILE}" && \
    ln -sf /etc/systemd/system/"${SETUPCON_TTY1_SERVICE_FILE}" /etc/systemd/system/default.target.wants/ && \
    echo "Setup ${SETUPCON_TTY1_SERVICE_FILE}"
