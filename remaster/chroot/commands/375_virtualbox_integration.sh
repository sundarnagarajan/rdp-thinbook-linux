#!/bin/bash
# Depends on 020_set_dns.sh 045_apt_update.sh

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

VBOX_DIR=${PROG_DIR}/../virtualbox

if [ ! -d ${VBOX_DIR} ]; then
    echo "VBOX_DIR not a directory: $VBOX_DIR"
    exit 0
fi
VBOX_DIR=$(readlink -e $VBOX_DIR)
test "$(ls -A $VBOX_DIR)"
if [ $? -ne 0 ]; then
    echo "No files to copy: $VBOX_DIR"
    exit 0
fi
for svc_file in vbox_client_integration.service virt_what_virtualbox.service
do
    svc_file_path=${VBOX_DIR}/virtualbox/services/$svc_file
    if [ ! -f "$svc_file_path" ]; then
        echo "service file not found: $svc_file_path"
        exit 0
    fi
done

mkdir -p /root
cp -r ${VBOX_DIR}/virtualbox /root/

function install_virtualbox_guest_dkms() {
    test "$(ls -A ${VBOX_DIR}/*.deb)"
    local ret=1
    if [ $? -eq 0 ]; then
        echo "Installing downloaded DEBs: "
        local oldpwd=$(pwd)
        cd "${VBOX_DIR}"
        ls -1 *.deb | sed -e 's/^/    /'
        # we know we need dkms
        apt-get -y --no-install-recommends --no-install-suggests install dkms || return 1
        dpkg -i ${VBOX_DIR}/*.deb
        ret=$?
        cd "$oldpwd"
        if [ $ret -ne 0 ]; then
            apt-get -y --no-install-recommends --no-install-suggests -f install
            return $?
        fi
    else
        echo "No DEBS under ${VBOX_DIR}"
        local REQUIRED_PKGS="virtualbox-guest-dkms"
        echo "Installing $REQUIRED_PKGS"
        apt-get install -y $REQUIRED_PKGS 2>/dev/null
        ret=$?
        if [ $ret -ne 0 ]; then
            echo "Install failed: $REQUIRED_PKGS"
            apt-get -y --no-install-recommends --no-install-suggests -f install 2>/dev/null
            return 1
        fi
    fi
}

install_virtualbox_guest_dkms
apt-get -y --no-install-recommends --no-install-suggests virt-what 1>/dev/null 2>&1

# Setup and enable services
# First copy the new service files (anyway)
VBOX_DIR=/root/virtualbox
if [ ! -d ${VBOX_DIR}/services ]; then
    echo "virtualbox integration services dir not found: ${VBOX_DIR}/services"
    exit 0
fi
svc_dir=${VBOX_DIR}/services
for svc_file in vbox_client_integration.service virt_what_virtualbox.service
do
    if [ ! -f ${svc_dir}/$svc_file ]; then
        echo "Service file not found: ${svc_dir}/svc_file"
        continue
    fi
    cp ${svc_dir}/$svc_file /etc/systemd/system/
done    

# Another check - using systemd
SYSTEMD_PAGER="" systemctl --plain list-unit-files virtualbox-guest-utils.service | grep -q virtualbox-guest-utils.service
if [ $? -ne 0 ]; then
    echo "virtualbox-guest-utils.service not found"
    exit 0
fi
cd /etc/systemd/system
systemctl daemon-reload
for svc in vbox_client_integration.service virt_what_virtualbox.service
do
    systemctl enable $svc
done
