#!/bin/bash
# Path to config file relative to dir with this script
CONFIG_FILE=./config.kernel
# Patch file path relative to dir with this script
# All patches expected to be in one file
PATCH_FILE=./all_rdp_patches.patch
# KERNEL_SOURCE_SCRIPT should be in current dir and echo URL of kernel source
KERNEL_SOURCE_SCRIPT=./get_kernel_source_url.sh
IMAGE_NAME=bzImage

#-------------------------------------------------------------------------
# Probably don't have to change anything below this
#-------------------------------------------------------------------------

CURDIR=$(printf %q "$(readlink -f $PWD)")
KERNEL_SOURCE_SCRIPT=$(printf %q "${CURDIR}/get_kernel_source_url.sh")
START_END_TIME_FILE="$CURDIR/start_end.time"
if [ -z "$NUM_THREADS" ]; then
    NUM_THREADS=$(lscpu | grep '^CPU(s)' | awk '{print $2}')
fi
echo "Using NUMTHREADS=$NUM_THREADS"
MAKE_THREADED="make -j$NUM_THREADS"

get_tar_fmt_ind()
{
	# $1: KERNEL_SRC URL - can be tar / xz / bz2 / gz
	# Echoes single-char fmt indicator - 'j', 'z' or ''
	# Exits (from script) if tar file ($1) has invalid suffix

	local URL=${1}
	local SUFFIX=$(echo "${URL}" | awk -F. '{print $NF}')
	case ${SUFFIX} in
		"tar")
			echo ''
			;;
		"xz")
			echo 'J'
			;;
		"bz2")
			echo 'j'
			;;
		"gz")
			echo 'z'
			;;
		*)
			echo "KERNEL_SRC has unknown suffix ${SUFFIX}: ${URL}"
			exit 1
			;;
	esac
}

rm -f "$START_END_TIME_FILE"
echo "Retrieve kernel source start:         $(date)" | tee -a "$START_END_TIME_FILE"

# Retrieve and extract kernel source
if [ ! -x "${KERNEL_SOURCE_SCRIPT}" ]; then
    echo "Kernel source script not found: ${KERNEL_SOURCE_SCRIPT}"
    exit 1
fi
KERNEL_SOURCE_URL="$(${KERNEL_SOURCE_SCRIPT})"
# Check URL is OK:
curl -s -f -I "$KERNEL_SOURCE_URL" 1>/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "URL not accessible: $KERNEL_SOURCE_URL"
    exit 1
fi
TAR_FMT_IND=$(get_tar_fmt_ind "$KERNEL_SOURCE_URL")
DEB_DIR=$(printf %q "${CURDIR}/debs")

rm -rf "${DEB_DIR}"
mkdir "${DEB_DIR}"
wget -q -O - -nd "$KERNEL_SOURCE_URL" | tar "${TAR_FMT_IND}xf" - -C "${DEB_DIR}"
echo "Retrieve kernel source finished:      $(date)" | tee -a "$START_END_TIME_FILE"
# Check there is exactly one dir extracted - we depend on this
cd "${DEB_DIR}"
if [ $(ls | wc -l) -ne 1 ]; then
    echo "More than one top-level dir extracted - this is almost certainly wrong"
    exit 1
fi
BUILD_DIR=$(printf %q "${DEB_DIR}/$(ls | head -1)")
cd "${CURDIR}"

if [ ! -d "$BUILD_DIR" ]; then
    echo "Directory not found: BUILD_DIR: $BUILD_DIR"
    exit 1
fi
echo "BUILD_DIR=${BUILD_DIR}"

# Apply patches
if [ -n "$PATCH_FILE" ]; then
    if [ -f "${CURDIR}/${PATCH_FILE}" ]; then
        cd "${BUILD_DIR}"
        patch -p1 < "${CURDIR}/${PATCH_FILE}"
        if [ $? -ne 0 ]; then
            echo "Patch failed"
            exit 1
        fi
    fi
fi

# Restore config
cd "$BUILD_DIR"
if [ ! -f .config ]; then
    if [ -f "${CURDIR}/${CONFIG_FILE}" ]; then
        cp "${CURDIR}/${CONFIG_FILE}" .config
        echo "Restored config"
    else
        echo ".config not found: ${CONFIG_FILE}"
        exit 1
    fi
fi


echo "Kernel build start:                   $(date)" | tee -a "$START_END_TIME_FILE"
$MAKE_THREADED silentoldconfig
$MAKE_THREADED $IMAGE_NAME
$MAKE_THREADED bindeb-pkg

echo "Kernel build finished:                $(date)" | tee -a "$START_END_TIME_FILE"
echo "-------------------------- Kernel compile time -------------------------------"
cat $START_END_TIME_FILE
echo "------------------------------------------------------------------------------"
echo "Kernel DEBS: (in $(readlink -f $DEB_DIR))"
cd "${DEB_DIR}"
ls -1 *.deb | sed -e 's/^/	/'
echo "------------------------------------------------------------------------------"
