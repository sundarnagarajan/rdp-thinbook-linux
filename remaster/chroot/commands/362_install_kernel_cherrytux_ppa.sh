#!/bin/bash
# ------------------------------------------------------------------------
# Install kernel from cherrytux PPA
#
# Depends on 020_set_dns.sh 045_apt_update.sh 030_cherrytux_ppa.sh
# If Cherrytux PPA GGG key is not trusted, this script will do nothing
#
# This script automatically 'integrates' with 11_install_kernels.sh
# If 11_install_kernels.sh ran and created ${KERNEL_DEB_DIR}/$KP_LIST
# AND ${KERNEL_DEB_DIR}/$KP_LIST contains at least one linux-image-* package
# then this script will do nothing
# ------------------------------------------------------------------------

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
FAILED_EXIT_CODE=127

REMASTER_DIR=/root/remaster
CHERRYTUX_PPA_GPG_KEYID=ABF7C302A5B662BDE68E0EFE883F04480A577E61
KERNEL_DEB_DIR=${PROG_DIR}/../kernel-debs
KERNEL_DEB_DIR=$(readlink -e $KERNEL_DEB_DIR)
KP_LIST=kernel_pkgs.list
KP_LIST=${KERNEL_DEB_DIR}/$KP_LIST

# Check for Cherrytux PPA GPG trusted key
APT_KEY_OUT=$(apt-key list $CHERRYTUX_PPA_GPG_KEYID 2>/dev/null)
if [ -z "$APT_KEY_OUT" ]; then
    echo "Cherrytux PPA GPG key not trusted: $CHERRYTUX_PPA_GPG_KEYID"
    echo "Not installing anything"
    exit 1
fi

MIN_KERNEL=5.10
MAX_KERNEL_VER_INSTALLED=$(dpkg -l 'linux-image*' | grep '^ii' | awk '{print $3}' |sort -Vr | head -1)
[[ "$( (echo $MIN_KERNEL; echo $MAX_KERNEL_VER_INSTALLED) | sort -Vr | tail -1)" = "$MIN_KERNEL" ]] && {
    echo "Current kernel (${MAX_KERNEL_VER_INSTALLED}) meets minimum requirements (${MIN_KERNEL})"
    echo "Not installing new kernel"
    echo "cherrytux PPA setup and ready to use"
    exit 0
}

if [ -f $KP_LIST -a -s $KP_LIST ]; then
    grep -q '^linux-image' $KP_LIST
    if [ $? -eq 0 ]; then
        echo "Kernels already installed - not using cherrytux PPA"
        echo "cherrytux PPA setup and ready to use"
        exit 0
    fi
fi

REQUIRED_PKGS="cherrytux-image cherrytux-headers"
if [ -x /etc/grub.d/30_os-prober ]; then
    chmod -x /etc/grub.d/30_os-prober
fi
echo "Installing $REQUIRED_PKGS"
apt install -y --no-install-recommends --no-install-suggests $REQUIRED_PKGS 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Install failed: $REQUIRED_PKGS"
    exit $FAILED_EXIT_CODE
fi
# postpone update-initramfs to 920_update_initramfs.s

# Add kernel we installed to $KP_LIST
mkdir -p $KERNEL_DEB_DIR
touch $KP_LIST

dpkg -l linux-image-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST
dpkg -l linux-headers-[0-9]* | grep '^ii' | tail -1 | awk '{print $2}' >> $KP_LIST

echo "Installed following packages:"
dpkg -l cherrytux-image | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
dpkg -l cherrytux-headers | grep '^ii' | tail -1 | awk '{print $2}' | sed -e 's/^/    /'
cat $KP_LIST | sed -e 's/^/    /'
