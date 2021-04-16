#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster
REMASTER_DEBS_DIR="${REMASTER_DIR}"/debs

for src_dir in "${PROG_DIR}/../kernel-debs" "${PROG_DIR}/../zfs-kernel-debs" "${PROG_DIR}/../zfs-userspace-debs"
do
    src_dir=$(readlink -m "$src_dir")
    if [ -d "$src_dir" ]; then
        mkdir -p "$REMASTER_DEBS_DIR"
        echo "${src_dir}  -->  ${REMASTER_DEBS_DIR}"
        \cp -r "$src_dir" "${REMASTER_DEBS_DIR}"/
    else
        echo "src_dir not found: $src_dir"
    fi
done
