#!/bin/bash
export TOP_DIR=$(readlink -e $(dirname $0))
KERNEL_BUILD_CONFIG=kernel_build.config ./kernel_build/scripts/tail_all_debug.sh
