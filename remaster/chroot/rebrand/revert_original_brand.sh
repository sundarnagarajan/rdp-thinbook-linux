#!/bin/bash
# Revert to original branding - for END USER to run

PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}

SCRIPTS_DIR=${PROG_DIR}

if [ ! -d ${SCRIPTS_DIR} ]; then
    echo "SCRIPTS_DIR not a directory: $SCRIPTS_DIR"
    exit 0
fi

SCRIPTS_DIR=$(readlink -e $SCRIPTS_DIR)
# We don't change /etc/dpkg/origins/default - just back it up and
# flip some symlinks
REBRAND_FILES="/etc/issue /etc/issue.net /etc/lsb-release /etc/os-release"
BACKUP_DIR=${SCRIPTS_DIR}/backup

if [ ! -d "${BACKUP_DIR}" ]; then
    echo "BACKUP_DIR: not a directory: $BACKUP_DIR"
    exit 1
fi

# If $1 is --force, will permit:
#   - reverting even if current files are different
#   - reverting even if all original files are not available

if [ "$1" = "--force" ]; then
    FORCE=yes
else
    FORCE=no
fi

# Do not proceed unless all original files are available
if [ "$FORCE" != "yes" ]; then    
    for f in $REBRAND_FILES
    do
        if [ "$FORCE" != "yes" ]; then
            if [ ! -f ${BACKUP_DIR}/${f}.orig ]; then
                echo "Backup not found: ${BACKUP_DIR}/${f}.orig"
                echo "Will not proceed - use --force to override"
                exit 0
            fi
        fi
    done
fi

for f in $REBRAND_FILES
do
    if [ -f ${BACKUP_DIR}/${f}.new ]; then
        # Do not revert if the new rebranded file has been changed since originally created
        diff --brief $f ${BACKUP_DIR}/${f}.new 1>/dev/null
        if [ $? -ne 0 ]; then
            if [ "$FORCE" != "yes" ]; then
                echo "$f has been changed - will not overwrite. Use --force to override"
                exit 0
            fi
        fi
    else
        if [ "$FORCE" != "yes" ]; then
            echo "Backup not found: ${BACKUP_DIR}/${f}.new"
            exit 0
        fi
    fi
    # The actual restore
    if [ -f ${BACKUP_DIR}/${f}.orig ]; then
        diff --brief ${BACKUP_DIR}/${f}.orig $f 1>/dev/null
        if [ $? -eq 0 ]; then
            echo "File unchanged: $f"
        else
            \cp -f ${BACKUP_DIR}/${f}.orig $f
        fi
    else
        echo "Backup not found: ${BACKUP_DIR}/${f}.orig"
    fi
done
