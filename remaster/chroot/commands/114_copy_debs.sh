#!/bin/bash
PROG_PATH=${PROG_PATH:-$(readlink -e $0)}
PROG_DIR=${PROG_DIR:-$(dirname ${PROG_PATH})}
PROG_NAME=${PROG_NAME:-$(basename ${PROG_PATH})}
REMASTER_DIR=/root/remaster

for src_dir in "${PROG_DIR}/../kernel-debs" "${PROG_DIR}/../zfs-kernel-debs" "${PROG_DIR}/../zfs-userspace-debs"
do
    src_dir=$(readlink -m "$src_dir")
    if [ -d "$src_dir" ]; then
        dest_dir=${REMASTER_DIR}/$(basename $src_dir)
        ls "$src_dir"/*.deb 2>/dev/null grep -q '\.deb$' || continue
        mkdir -p "$dest_dir"
        \cp -rv "$src_dir"/*.deb "$dest_dir"/
    else
        echo "src_dir not found: $src_dir"
    fi
done

exit 0
