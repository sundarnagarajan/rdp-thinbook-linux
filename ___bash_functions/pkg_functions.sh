#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<

#BASHDOC
# ------------------------------------------------------------------------
# Functions related to packaging system
# ------------------------------------------------------------------------
#BASHDOC

# ___SRC_DIR is directory of this script or pwd if BASH_SOURCE not set
if [[ -z "${___SRC_DIR+_}" ]]; then
    [[ -n "${BASH_SOURCE+_}" ]] && ___SRC_DIR=$(dirname $(readlink -e ${BASH_SOURCE[0]})) || ___SRC_DIR="$(pwd)"
    readonly ___SRC_DIR
fi
# Explicitly source ___minimal_functions.sh using ___SRC_DIR to cause error if
# ___minimal_functions.sh has not been sourced yet
[[ -n "${PS1+_}" ]] || set -e
declare -p -F source_file 1>/dev/null 2>&1 && source_file "${___SRC_DIR}/___minimal_functions.sh" || source "${___SRC_DIR}/___minimal_functions.sh"

source_file "${___SRC_DIR}/var_functions.sh" || exit 1


function pkg_missing_from() {
    # args: names of packages
    # Outputs (stdout) list of missing packages on a single line separated by space
    # Returns: 0 if no packages we missing; 1 otherwise
    # Lists packages that are not installed or not in install state 'ii'
    # Note: this will ALSO list unknown package names that can NEVER be installed
    [[ $# -lt 1 ]] && return 0
    local missing=$(dpkg-query --show --showformat='${db:Status-Abbrev} ${Package}\n' $@ 2>&1 | sed -e 's/^dpkg-query: no packages found matching/un/' | awk '$1 != "ii" {print $2}' | tr '\n' ' ')
    if [[ -n "$missing" ]]; then
        echo "$missing"
        return 1
    else
        return 0
    fi
}

function pkg_apt_op_analysis() {
    # $1: Name of (non-associative) array variable (without '$')
    # $2: apt operation - could be any of:
    #   install
    #   'install --reinstall'
    #   remove
    #   'remove --purge'
    #   autoremove
    #   'autoremove --purge'
    # Rest of command line args
    # Sets components 1, 2, 3, 4 of ARG1 variable to following
    #   ARG1[1] : int : status code:
    #       0 - No packages to install remove; all package names were found
    #       LSB bit 1 set: Packages to install - check with $(( ${ARG1[1]} & 1 ))
    #       LSB bit 2 set: Packages to install - check with $(( ${ARG1[1]} & 2 ))
    #       LSB bit 3 set: Packages to install - check with $(( ${ARG1[1]} & 4 ))
    #   ARG1[2]: packages that would be installed
    #   ARG1[3]: packages that would be REMOVED
    #   ARG1[4]: Bad package names that were not found
    #   ARG1[5] : int : apt-get return code
    # Returns: non-zero: if ARG1 is not an existing array variable; 0 otherwise
    # Note that if ANY of the package names cannot be found, only bad package
    # names (ARG1[4]) will be set and ARG1[2] and ARG1[3] will NOT be set
    #
    # set USE_PERL to 1 to use perl parsing
    local USE_PERL=0
    # set APT_CMD to 'apt' to use 'apt' instead of 'apt-get'
    local APT_CMD=apt-get
    #
    [[ $# -lt 2 ]] && return 1
    var_is_array $1 || return 2
    declare -n res=$1
    local OPERATION=$2
    local bad_pkg_names=""
    local to_install=""
    local to_remove=""
    res[2]="$to_install"
    res[3]="$to_remove"
    res[4]="$bad_pkg_names"

    if [[ $# -lt 2 ]]; then
        res[1]=0
        res[5]=0
        return 0
    fi
    shift
    # Only run $APT_CMD once (it is slow)
    res[5]=0
    local apt_out=$($APT_CMD --dry-run $OPERATION $@ 2>&1) || res[5]=$?


    if [[ "$USE_PERL" -ne 0 ]]; then
        # Using perl - does not depend on output of $APT_CMD --dry-run '^(Inst|Remv|E:)'
        bad_pkg_names=$(echo "$apt_out" | perl -wnl -e '/^E: Unable to locate package (\S+)$/ and print $1' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
        if [[ -z "$bad_pkg_names" ]]; then
            to_install=$(echo "$apt_out" | perl -0777 -wnl -e '/^The following NEW packages will be installed:\n(^\s+.*?)\n^\S+/gms and print $1' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
            to_remove=$(echo "$apt_out" | perl -0777 -wnl -e '/^The following packages will be REMOVED:\n(^\s+.*?)\n^\S+/gms and print $1' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
        fi
    else
        # Use output of $APT_CMD --dry-run '^(Inst|Remv|E:)'
        bad_pkg_names=$(echo "$apt_out" | awk '$0 ~ "^E: Unable to locate package " {print $6}' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
        if [[ -z "$bad_pkg_names" ]]; then
            to_install=$(echo "$apt_out" | awk '$0 ~ "^Inst " {print $2}' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
            to_remove=$(echo "$apt_out" | awk '$0 ~ "^Remv " {print $2}' | tr '\n' ' ' | sed -e 's/ [ ]*/ /g' -e 's/^ //' -e s'/ $//')
        fi
    fi

    # set ARG1
    res[2]="$to_install"
    res[3]="$to_remove"
    res[4]="$bad_pkg_names"
    res[1]=0
    [[ -n "$to_install" ]] && res[1]=$(( ${res[1]} | 1 ))
    [[ -n "$to_remove" ]] && res[1]=$(( ${res[1]} | 2 ))
    [[ -n "$bad_pkg_names" ]] && res[1]=$(( ${res[1]} | 4 ))
    return 0
}


function pkg_apt_would_install_remove() {
    # $1: Name of (non-associative) array variable (without '$')
    # Rest of command line args
    # Sets components 1, 2, 3, 4 of ARG1 variable to following
    #   ARG1[1] : int : status code:
    #       0 - No packages to install remove; all package names were found
    #       LSB bit 1 set: Packages to install - check with $(( ${ARG1[1]} & 1 ))
    #       LSB bit 2 set: Packages to install - check with $(( ${ARG1[1]} & 2 ))
    #       LSB bit 3 set: Packages to install - check with $(( ${ARG1[1]} & 4 ))
    #   ARG1[2]: packages that would be installed
    #   ARG1[3]: packages that would be REMOVED
    #   ARG1[4]: Bad package names that were not found
    #   ARG1[5] : int : apt-get return code
    # Returns: non-zero: if ARG1 is not an existing array variable; 0 otherwise
    # Note that if ANY of the package names cannot be found, only bad package
    # names (ARG1[4]) will be set and ARG1[2] and ARG1[3] will NOT be set
    #
    [[ $# -lt 1 ]] && return 1
    local VAR_NAME=$1
    shift
    ret=0
    pkg_apt_op_analysis $VAR_NAME "install" $@ || ret=$?
    return $ret
}

function pkg_apt_install_would_install_remove() {
    # $1: Name of (non-associative) array variable (without '$')
    # Rest of command line args
    # Sets components 1, 2, 3, 4 of ARG1 variable to following
    #   ARG1[1] : int : status code:
    #       0 - No packages to install remove; all package names were found
    #       LSB bit 1 set: Packages to install - check with $(( ${ARG1[1]} & 1 ))
    #       LSB bit 2 set: Packages to install - check with $(( ${ARG1[1]} & 2 ))
    #       LSB bit 3 set: Packages to install - check with $(( ${ARG1[1]} & 4 ))
    #   ARG1[2]: packages that would be installed
    #   ARG1[3]: packages that would be REMOVED
    #   ARG1[4]: Bad package names that were not found
    #   ARG1[5] : int : apt-get return code
    # Returns: non-zero: if ARG1 is not an existing array variable; 0 otherwise
    # Note that if ANY of the package names cannot be found, only bad package
    # names (ARG1[4]) will be set and ARG1[2] and ARG1[3] will NOT be set
    #
    [[ $# -lt 1 ]] && return 1
    local VAR_NAME=$1
    shift
    ret=0
    pkg_apt_op_analysis $VAR_NAME "install" $@ || ret=$?
    return $ret
}

function pkg_apt_remove_would_install_remove() {
    # $1: Name of (non-associative) array variable (without '$')
    # Rest of command line args
    # Sets components 1, 2, 3, 4 of ARG1 variable to following
    #   ARG1[1] : int : status code:
    #       0 - No packages to install remove; all package names were found
    #       LSB bit 1 set: Packages to install - check with $(( ${ARG1[1]} & 1 ))
    #       LSB bit 2 set: Packages to install - check with $(( ${ARG1[1]} & 2 ))
    #       LSB bit 3 set: Packages to install - check with $(( ${ARG1[1]} & 4 ))
    #   ARG1[2]: packages that would be installed
    #   ARG1[3]: packages that would be REMOVED
    #   ARG1[4]: Bad package names that were not found
    #   ARG1[5] : int : apt-get return code
    # Returns: non-zero: if ARG1 is not an existing array variable; 0 otherwise
    # Note that if ANY of the package names cannot be found, only bad package
    # names (ARG1[4]) will be set and ARG1[2] and ARG1[3] will NOT be set
    #
    [[ $# -lt 1 ]] && return 1
    local VAR_NAME=$1
    shift
    ret=0
    pkg_apt_op_analysis $VAR_NAME "remove --purge" $@ || ret=$?
    return $ret
}

function pkg_apt_autoremove_would_install_remove() {
    # $1: Name of (non-associative) array variable (without '$')
    # Rest of command line args
    # Sets components 1, 2, 3, 4 of ARG1 variable to following
    #   ARG1[1] : int : status code:
    #       0 - No packages to install remove; all package names were found
    #       LSB bit 1 set: Packages to install - check with $(( ${ARG1[1]} & 1 ))
    #       LSB bit 2 set: Packages to install - check with $(( ${ARG1[1]} & 2 ))
    #       LSB bit 3 set: Packages to install - check with $(( ${ARG1[1]} & 4 ))
    #   ARG1[2]: packages that would be installed
    #   ARG1[3]: packages that would be REMOVED
    #   ARG1[4]: Bad package names that were not found
    #   ARG1[5] : int : apt-get return code
    # Returns: non-zero: if ARG1 is not an existing array variable; 0 otherwise
    # Note that if ANY of the package names cannot be found, only bad package
    # names (ARG1[4]) will be set and ARG1[2] and ARG1[3] will NOT be set
    #
    [[ $# -lt 1 ]] && return 1
    local VAR_NAME=$1
    shift
    ret=0
    pkg_apt_op_analysis $VAR_NAME "autoremove --purge" $@ || ret=$?
    return $ret
}

function deb_files_2_pkg_names() {
    # $@ filenames
    # Outputs to stdout: space-separated list of package names
    local pkgs=""
    for f in $@
    do
        local ret=0
        p=$(dpkg-deb -f $f Package) || ret=1
        if [[ $ret -eq 0 ]]; then
            pkgs="$pkgs $p"
        fi
    done
    echo $pkgs
}

function colored_installation_status() {
    # $@ package names
    # Outputs on stdout: "XX pkg_name>"
    # Colors output only if output is a TTY

    local esc=""
    local RS=""
    local HC=""
    local UL=""
    local INV=""
    local FBLK=""
    local FRED=""
    local FGRN=""
    local FYEL=""
    local FBLE=""
    local FMAG=""
    local FCYN=""
    local FWHT=""
    local BBLK=""
    local BRED=""
    local BGRN=""
    local BYEL=""
    local BBLE=""
    local BMAG=""
    local BCYN=""
    local BWHT=""

    # Colors only if stdout is a TTY
    if [[ -t 1 ]]; then
        esc=$(printf '\033')
        RS="${esc}[0m"    # reset
        HC="${esc}[1m"    # hicolor
        UL="${esc}[4m"    # underline
        INV="${esc}[7m"   # inverse background and foreground
        FBLK="${esc}[30m" # foreground black
        FRED="${esc}[31m" # foreground red
        FGRN="${esc}[32m" # foreground green
        FYEL="${esc}[33m" # foreground yellow
        FBLE="${esc}[34m" # foreground blue
        FMAG="${esc}[35m" # foreground magenta
        FCYN="${esc}[36m" # foreground cyan
        FWHT="${esc}[37m" # foreground white
        BBLK="${esc}[40m" # background black
        BRED="${esc}[41m" # background red
        BGRN="${esc}[42m" # background green
        BYEL="${esc}[43m" # background yellow
        BBLE="${esc}[44m" # background blue
        BMAG="${esc}[45m" # background magenta
        BCYN="${esc}[46m" # background cyan
        BWHT="${esc}[47m" # background white
    fi

    out=$(dpkg-query --show --showformat='${db:Status-Abbrev} ${Package}\n' $@  2>&1 | \
        sed -e 's/^dpkg-query: no packages found matching/un/' | \
        sed -e "s/^ii/${HC}${FBLE}ii/" -e "s/^un/${HC}${FRED}un/" -e "s/\$/${RS}/"
    )
    echo -e "$out"
}



___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
