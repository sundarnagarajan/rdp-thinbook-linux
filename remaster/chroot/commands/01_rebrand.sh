#!/bin/bash
# Rebrand distro (/etc/lsb-release, /etc/os-release etc)

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SCRIPTS_DIR=${PROG_DIR}/../rebrand

if [ ! -d ${SCRIPTS_DIR} ]; then
    echo "SCRIPTS_DIR not a directory: $SCRIPTS_DIR"
    exit 0
fi

SCRIPTS_DIR=$(readlink -e $SCRIPTS_DIR)
INSTALL_SCRIPT=/root/rebrand/rebrand.py

mkdir -p /root
cp -r ${SCRIPTS_DIR} /root/

if [ ! -f ${INSTALL_SCRIPT} ]; then
    echo "Not found: ${INSTALL_SCRIPT}"
    exit 0
fi

PY=python
which $PY 1>/dev/null
if [ $? -ne 0 ]; then
    PY=python3
    which $PY 1>/dev/null
    if [ $? -ne 0 ]; then
        echo "Could not find python2 or python3"
        exit 0
    fi
fi

# Copy original and new rebranded files under SCRIPTS_DIR/backup
# So that revert_ubuntu_brand.sh can find and use them
# We don't change /etc/dpkg/origins/default - just back it up and
# flip some symlinks
REBRAND_FILES="/etc/issue /etc/issue.net /etc/lsb-release /etc/os-release"
BACKUP_DIR=/root/rebrand/backup
OLD_DISTRO_ID=$(cat /etc/lsb-release | head -1 | cut -d= -f2)
mkdir -p $BACKUP_DIR
# Backup original rebranded files
for f in $REBRAND_FILES
do
    dn=$(dirname $f)
    fn=$(basename $f)
    if [ -f $f ]; then
        mkdir -p ${BACKUP_DIR}/$dn
        \cp -Lf $f ${BACKUP_DIR}/${f}.orig
    fi
done

$PY $INSTALL_SCRIPT

# Backup new rebranded files
for f in $REBRAND_FILES
do
    dn=$(dirname $f)
    fn=$(basename $f)
    if [ -f $f ]; then
        mkdir -p ${BACKUP_DIR}/$dn
        \cp -Lf $f ${BACKUP_DIR}/${f}.new
    fi
done
