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
START_END_TIME_FILE="/tmp/start_end.time"
if [ -z "$NUM_THREADS" ]; then
    NUM_THREADS=$(lscpu | grep '^CPU(s)' | awk '{print $2}')
fi
printf "INFO: Using %d threads\n" $NUM_THREADS
MAKE_THREADED="make -j$NUM_THREADS"
INDENT="    "

#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
function get_hms {
    # Converts a variable like SECONDS to hh:mm:ss format and echoes it
    # $1: value to convert - if not set defaults to using $SECONDS
    if [ -n "$1" ]; then
        duration=$1
    else
        duration=$SECONDS
    fi
    printf "%02d:%02d:%02d" "$(($duration / 3600))" "$(($duration / 60))" "$(($duration % 60))"
}

function show_timing_msg {
    # $1: Message
    # $2: tee or not: 'yestee' implies tee
    # $3 (optional): elapsed time (string)
    if [ "$2" = "yestee" ]; then
        if [ -n "$3" ]; then
            printf "%-39s: %-28s (%s)\n" "$1" "$(date)" "$3" | tee -a "$START_END_TIME_FILE"
        else
            printf "%-39s: %-28s\n" "$1" "$(date)" | tee -a "$START_END_TIME_FILE"
        fi
    else
        if [ -n "$3" ]; then
            printf "%-39s: %-28s (%s)\n" "$1" "$(date)" "$3" >> "$START_END_TIME_FILE"
        else
            printf "%-39s: %-28s\n" "$1" "$(date)" >> "$START_END_TIME_FILE"
        fi
    fi
}

function get_tar_fmt_ind {
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

function get_kernel_source {
    show_timing_msg "Retrieve kernel source start" "yestee"
    SECONDS=0

    # Retrieve and extract kernel source
    if [ ! -x "${KERNEL_SOURCE_SCRIPT}" ]; then
        echo "Kernel source script not found: ${KERNEL_SOURCE_SCRIPT}"
        exit 1
    fi
    local KERNEL_SOURCE_URL="$(${KERNEL_SOURCE_SCRIPT})"
    # Check URL is OK:
    curl -s -f -I "$KERNEL_SOURCE_URL" 1>/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "URL not accessible: $KERNEL_SOURCE_URL"
        exit 1
    fi
    local TAR_FMT_IND=$(get_tar_fmt_ind "$KERNEL_SOURCE_URL")
    DEB_DIR=$(printf %q "${CURDIR}/debs")

    rm -rf "${DEB_DIR}"
    mkdir "${DEB_DIR}"
    wget -q -O - -nd "$KERNEL_SOURCE_URL" | tar "${TAR_FMT_IND}xf" - -C "${DEB_DIR}"
    show_timing_msg "Retrieve kernel source finished" "yestee" "$(get_hms)"
}

function is_linux_kernel_source()
{
    # $1: kernel directory containing Makefile
    # Returns: 0 if it looks like linux kernel Makefile
    #          1 otherwise
    local help_out=$(make -s -C $1 help)
    for target in clean mrproper distclean config menuconfig xconfig oldconfig defconfig silentoldconfig modules_install modules_prepare kernelversion kernelrelease install
    do
        echo "$help_out" | grep -q "^[[:space:]][[:space:]]*$target[[:space:]][[:space:]]*-[[:space:]]"
        if [ $? -ne 0 ]; then
            return 1
        fi
    done
    return 0
}

function kernel_version()
{
    # $1: kernel directory containing Makefile
    #     May be:
    #         - Kernel build directory
    #         - /lib/modules/<kern_ver>/build
    #
    # If it is not a linux kernel source dir containing a Makefile
    # supporting kernelversion target, will echo nothing and return 1
    #
    if [ -z "$1" ]; then
        return 1
    fi
    local KERN_DIR=$(readlink -f "$1")
    if [ ! -d "$KERN_DIR" ]; then
        return 1
    fi
    is_linux_kernel_source "$KERN_DIR" || return 1
    # (At least newer) kernel Makefiles have a built in target to return kernel version
    echo $(make -s -C $KERN_DIR -s kernelversion 2>/dev/null)
    return $?
}

function set_build_dir {
    # Check there is exactly one dir extracted - we depend on this
    cd "${DEB_DIR}"
    if [ $(ls | wc -l) -ne 1 ]; then
        echo "Multiple top-level dir extracted - almost certainly wrong"
        exit 1
    fi
    BUILD_DIR=$(printf %q "${DEB_DIR}/$(ls | head -1)")
    cd "${CURDIR}"

    if [ ! -d "$BUILD_DIR" ]; then
        echo "Directory not found: BUILD_DIR: $BUILD_DIR"
        exit 1
    fi
    local KERN_VER=$(kernel_version "${BUILD_DIR}")
    if [ $? -ne 0 ]; then
        echo "Does not look like linux kernel source"
        exit 1
    fi

    echo "INFO: Building kernel $KERN_VER in ${BUILD_DIR}"
}

function apply_patches {
    if [ -n "$PATCH_FILE" ]; then
        if [ -f "${CURDIR}/${PATCH_FILE}" ]; then
            echo "Applying patches from ${CURDIR}/${PATCH_FILE}"
            cd "${BUILD_DIR}"
            patch -p1 < "${CURDIR}/${PATCH_FILE}" 2>&1 | sed -e "s/^/${INDENT}/"
            if [ $? -ne 0 ]; then
                echo "Patch failed" | sed -e "s/^/${INDENT}/"
                exit 1
            fi
        fi
    fi
}

function restore_kernel_config {
    cd "$BUILD_DIR"
    if [ ! -f .config ]; then
        if [ -f "${CURDIR}/${CONFIG_FILE}" ]; then
            cp "${CURDIR}/${CONFIG_FILE}" .config
            local config_kern_ver_lines="$(grep '^# Linux.* Kernel Configuration' ${CURDIR}/${CONFIG_FILE})"
            if [ $? -eq 0 ]; then
                local kver=$(echo "$config_kern_ver_lines" | head -1 | awk '{print $3}')
                echo "INFO: Restored config: seems to be from version $kver"
            else
                echo "INFO: Restored config (version not found in comment)"
            fi
        else
            echo ".config not found: ${CONFIG_FILE}"
            exit 1
        fi
    fi
}

function build_kernel {
    SECONDS=0
    local COMPILE_OUT_FILE="${DEB_DIR}/compile.out"
    \cp -f /dev/null "${COMPILE_OUT_FILE}"
    local elapsed=''

    show_timing_msg "Kernel build start" "yestee" ""
    # $MAKE_THREADED silentoldconfig 1>>"${COMPILE_OUT_FILE}" 2>&1
    $MAKE_THREADED allmodconfig 1>>"${COMPILE_OUT_FILE}" 2>&1
    [ $? -ne 0 ] && (tail -20 "${COMPILE_OUT_FILE}"; echo ""; echo "See ${COMPILE_OUT_FILE}"; exit 1)
    $MAKE_THREADED $IMAGE_NAME 1>>"${COMPILE_OUT_FILE}" 2>&1
    [ $? -ne 0 ] && (tail -20 "${COMPILE_OUT_FILE}"; echo ""; echo "See ${COMPILE_OUT_FILE}"; exit 1)
    show_timing_msg "Kernel $IMAGE_NAME build finished" "yestee" "$(get_hms)"

    show_timing_msg "Kernel modules build start" "notee" ""; SECONDS=0
    $MAKE_THREADED modules 1>>"${COMPILE_OUT_FILE}" 2>&1
    [ $? -ne 0 ] && (tail -20 "${COMPILE_OUT_FILE}"; echo ""; echo "See ${COMPILE_OUT_FILE}"; exit 1)
    show_timing_msg "Kernel modules build finished" "yestee" "$(get_hms)"

    show_timing_msg "Kernel deb build start" "notee" ""; SECONDS=0
    $MAKE_THREADED bindeb-pkg 1>>"${COMPILE_OUT_FILE}" 2>&1
    [ $? -ne 0 ] && (tail -20 "${COMPILE_OUT_FILE}"; echo ""; echo "See ${COMPILE_OUT_FILE}"; exit 1)

    \rm -f "${COMPILE_OUT_FILE}"
    show_timing_msg "Kernel deb build finished" "yestee" "$(get_hms)"
    show_timing_msg "Kernel build finished" "notee" ""

    echo "-------------------------- Kernel compile time -------------------------------"
    cat $START_END_TIME_FILE
    echo "------------------------------------------------------------------------------"
    echo "Kernel DEBS: (in $(readlink -f $DEB_DIR))"
    cd "${DEB_DIR}"
    ls -1 *.deb | sed -e "s/^/${INDENT}/"
    echo "------------------------------------------------------------------------------"
}

#-------------------------------------------------------------------------
# Actual build steps after this
#-------------------------------------------------------------------------
rm -f "$START_END_TIME_FILE"
get_kernel_source
set_build_dir
apply_patches
restore_kernel_config
build_kernel
