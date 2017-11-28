#!/bin/bash
# Path to config file relative to dir with this script
CONFIG_FILE=./config.kernel
# Patch file path relative to dir with this script
# All patches expected to be in one file
PATCH_FILE=./all_patches.patch
# KERNEL_SOURCE_SCRIPT should be in current dir and echo URL of kernel source
KERNEL_SOURCE_SCRIPT=./get_kernel_source_url.py
SHOW_AVAIL_KERNELS_SCRIPT=./show_available_kernels.py
UPDATE_CONFIG_SCRIPT=./update_kernel_config.py
CHECK_REQD_PKGS_SCRIPT=./required_pkgs.sh
IMAGE_NAME=bzImage

#-------------------------------------------------------------------------
# Following are plain filenames - will be created in KERNEL_BUILD_DIR
# or current dir if KERNEL_BUILD_DIR/debs if KERNEL_BUILD_DIR is not set
#-------------------------------------------------------------------------
# Output of build_kernel (ONLY)
COMPILE_OUT_FILENAME=compile.out
# Output of make silentoldconfig (ONLY)
SILENTCONFIG_OUT_FILENAME=silentconfig.out
# Output of ANSWER_QUESTIONS_SCRIPT - answers chosen
CHOSEN_OUT_FILENAME=chosen.out

#-------------------------------------------------------------------------
# Probably don't have to change anything below this
#-------------------------------------------------------------------------

CURDIR=$(printf %q "$(readlink -f $PWD)")

if [ "$1" = "-h" -o "$1" = "--help" ]; then
    if [ -f "${CURDIR}/README" ]; then
        cat "${CURDIR}/README"
        exit 0
    fi
fi


COMPILE_OUT_FILENAME=$(basename "$COMPILE_OUT_FILENAME")
SILENTCONFIG_OUT_FILENAME=$(basename "$SILENTCONFIG_OUT_FILENAME")
CHOSEN_OUT_FILENAME=$(basename "$CHOSEN_OUT_FILENAME")

START_END_TIME_FILE="/tmp/start_end.time"
CHECK_REQD_PKGS_SCRIPT=$(printf %q "${CURDIR}/${CHECK_REQD_PKGS_SCRIPT}")
KERNEL_SOURCE_SCRIPT=$(printf %q "${CURDIR}/${KERNEL_SOURCE_SCRIPT}")
SHOW_AVAIL_KERNELS_SCRIPT=$(printf %q "${CURDIR}/${SHOW_AVAIL_KERNELS_SCRIPT}")
UPDATE_CONFIG_SCRIPT=$(printf %q "${CURDIR}/${UPDATE_CONFIG_SCRIPT}")
if [ -z "$NUM_THREADS" ]; then
    NUM_THREADS=$(lscpu | grep '^CPU(s)' | awk '{print $2}')
fi
printf "Using %d threads\n" $NUM_THREADS
MAKE_THREADED="make -j$NUM_THREADS"
INDENT="    "
CONFIG_FILE_PATH="${CURDIR}/${CONFIG_FILE}"
if [ -n "$KERNEL_CONFIG" ]; then
    if [ -f "$KERNEL_CONFIG" ] ; then
        CONFIG_FILE_PATH="${KERNEL_CONFIG}"
        echo "Using config from environment: ${KERNEL_CONFIG}"
    else
        echo "Ignoring non-existent config from environment: ${KERNEL_CONFIG}"
    fi
fi
if [ -z "$KERNEL_CONFIG_PREFS" ]; then
    KERNEL_CONFIG_PREFS="${CURDIR}/config.prefs"
fi

$CHECK_REQD_PKGS_SCRIPT
if [ $? -ne 0 ]; then
    exit 1
fi


#-------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------
function choose_deb_dir {
    # If KERNEL_BUILD_DIR env var is set, set DEB_DIR to that dir
    # All components of KERNEL_BUILD_DIR except last component must already exist
    # If last component of KERNEL_BUILD_DIR doesn't exist, it is created
    # If KERNEL_BUILD_DIR is not set or All components of KERNEL_BUILD_DIR
    # except last component do not exist, DEB_DIR is set to 
    # ${CURDIR}/debs

    unset DEB_DIR
    if [ -n "${KERNEL_BUILD_DIR}" ]; then
        KERNEL_BUILD_DIR=$(readlink -f "${KERNEL_BUILD_DIR}")
        BUILD_DIR_PARENT=$(dirname "${KERNEL_BUILD_DIR}")
        if [ -d "${BUILD_DIR_PARENT}" ]; then
            if [ -e "${KERNEL_BUILD_DIR}" ]; then
                if [ ! -d "${KERNEL_BUILD_DIR}" ]; then
                    \rm -f "${KERNEL_BUILD_DIR}"
                    if [ $? -ne 0 ]; then
                        echo "Could not delete non-directory ${KERNEL_BUILD_DIR}"
                        exit 1
                    fi
                    mkdir -p "${KERNEL_BUILD_DIR}"
                    if [ $? -ne 0 ]; then
                        echo "Could not create ${KERNEL_BUILD_DIR}"
                        exit 1
                    fi
                else    # KERNEL_BUILD_DIR is an existing dir
                    find "${KERNEL_BUILD_DIR}" -mindepth 1 -delete
                    if [ $? -ne 0 ]; then
                        echo "Could not empty ${KERNEL_BUILD_DIR}"
                        exit 1
                    fi
                fi
            else
                mkdir -p "${KERNEL_BUILD_DIR}"
                if [ $? -ne 0 ]; then
                    echo "Could not create ${KERNEL_BUILD_DIR}"
                    exit 1
                fi
            fi
            DEB_DIR="${KERNEL_BUILD_DIR}"
            echo "Building in: ${KERNEL_BUILD_DIR}"
        else
            echo "Parent directory does not exist: ${BUILD_DIR_PARENT}"
            echo "Ignoring KERNEL_BUILD_DIR: ${KERNEL_BUILD_DIR}"
        fi

    fi
    if [ -z "${DEB_DIR}" ]; then
        DEB_DIR=$(printf %q "${CURDIR}/debs")
        rm -rf "${DEB_DIR}"
        mkdir "${DEB_DIR}"
    fi
}

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

    echo "Building kernel $KERN_VER in ${BUILD_DIR}"
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
        if [ -f "${CONFIG_FILE_PATH}" ]; then
            cp "${CONFIG_FILE_PATH}" .config
            local config_kern_ver_lines="$(grep '^# Linux.* Kernel Configuration' ${CONFIG_FILE_PATH})"
            if [ $? -eq 0 ]; then
                local kver=$(echo "$config_kern_ver_lines" | head -1 | awk '{print $3}')
                echo "Restored config: seems to be from version $kver"
            else
                echo "Restored config (version not found in comment)"
            fi
        else
            echo ".config not found: ${CONFIG_FILE_PATH}"
            exit 1
        fi
    fi
}

function run_make_silentoldconfig {
    # Runs make silentoldconfig, answering any questions
    # Expects the following:
    #   - Linux source should have been retrieved and extracted
    #   - BUILD_DIR should have been set (set_build_dir)
    #   - .config must have already been restored (restore_kernel_config)
    #   - $UPDATE_CONFIG_SCRIPT must have been set and must be executable
    # If any of the above expectations are NOT met, compilation aborts

    # If $CONFIG_PREFS is set and read-able:
    #   If $UPDATE_CONFIG_SCRIPT is set and executable, it is run
    # If (and only if) $UPDATE_CONFIG_SCRIPT return code is 100,
    # make silentoldconfig is called for SECOND time, again using 
    # $ANSWER_QUESTIONS_SCRIPT
    if [ -z "$BUILD_DIR" ]; then
        echo "BUILD_DIR not set"
        exit 1
    fi
    if [ ! -d "$BUILD_DIR" ]; then
        echo "BUILD_DIR is not a directory: $BUILD_DIR"
        exit 1
    fi
    if [ ! -f "${BUILD_DIR}/.config" ]; then
        echo ".config not found: ${BUILD_DIR}/.config"
        exit 1
    fi
    if [ -z "$UPDATE_CONFIG_SCRIPT" ]; then
        echo "UPDATE_CONFIG_SCRIPT not set"
        exit 1
    fi
    if [ ! -x "$UPDATE_CONFIG_SCRIPT" ]; then
        echo "Not executable: $UPDATE_CONFIG_SCRIPT"
        exit 1
    fi
    local SILENTCONFIG_OUT_FILE="${DEB_DIR}/${SILENTCONFIG_OUT_FILENAME}"
    local CHOSEN_OUT_FILE="${DEB_DIR}/${CHOSEN_OUT_FILENAME}"
    local MAKE_CONFIG_CMD="make silentoldconfig"
    
    OLD_DIR=$(pwd)
    cd "${BUILD_DIR}"
    PYTHONUNBUFFERED=yes $UPDATE_CONFIG_SCRIPT "${BUILD_DIR}" "${SILENTCONFIG_OUT_FILE}" "${CHOSEN_OUT_FILE}" "${MAKE_CONFIG_CMD}" "${KERNEL_CONFIG_PREFS}"
    ret=$?

    cd "$OLD_DIR"
    return $ret
}

function build_kernel {
    SECONDS=0
    local COMPILE_OUT_FILE="${DEB_DIR}/${COMPILE_OUT_FILENAME}"
    \cp -f /dev/null "${COMPILE_OUT_FILE}"
    local elapsed=''

    show_timing_msg "Kernel build start" "yestee" ""
    run_make_silentoldconfig
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
# Show available kernels and kernel version of available config
if [ -x "${SHOW_AVAIL_KERNELS_SCRIPT}" ]; then
    $SHOW_AVAIL_KERNELS_SCRIPT
fi
    
choose_deb_dir
get_kernel_source
set_build_dir
apply_patches
restore_kernel_config
build_kernel
