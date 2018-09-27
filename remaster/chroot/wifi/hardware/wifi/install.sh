#!/bin/bash
PROG_DIR=$(printf %q "$(readlink -e $(dirname $0))")
SCRIPTS_DIR=$(printf %q "${PROG_DIR}/scripts")

# Check that required scripts are present
if [ ! -f ${SCRIPTS_DIR}/iw_set_reg_domain.service ]; then
    echo "Missing file: ${SCRIPTS_DIR}/iw_set_reg_domain.service"
    exit 1
fi

if [ ! -f ${PROG_DIR}/iw_set_reg_domain.sh ]; then
    echo "Missing file: ${PROG_DIR}/iw_set_reg_domain.sh"
    exit 1
fi

\cp -f ${SCRIPTS_DIR}/iw_set_reg_domain.service /etc/systemd/system/
mkdir -p /etc/systemd/system/network-online.target.wants
\rm -f /etc/systemd/system/network-online.target.wants/iw_set_reg_domain.service
ln -s /etc/systemd/system/iw_set_reg_domain.service /etc/systemd/system/network-online.target.wants/

# Install a default config file
COUNTRY_FILE=/etc/default/iw_regulatory_country
echo "COUNTRY=US" > $COUNTRY_FILE
