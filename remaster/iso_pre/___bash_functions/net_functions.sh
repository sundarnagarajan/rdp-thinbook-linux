#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<

#BASHDOC
# ------------------------------------------------------------------------
# Functions related to network operations
# bash-specific and may need bash version 4
# Packages: dnsutils(dig), git(git), curl(curl), iproute2(ip), gawk(awk) 
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


function net_if_list() {
    # Outputs list of interface names one per line to stdout
    while read word _; do printf '%s\n' "$word"; done <<< $(ip -4 -br -o link list)
}

function net_if_state_list() {
    # $1: state of interface (optional)
    # Outputs list of interface names in that state one per line to stdout
    # If no state is chosen all local interface names are printed
    local state=""
    [[ $# -gt 0 ]] && state=$1
    if [[ $state =~ ^[[:space:]]*$ ]]; then   # state is empty
        while read word _; do printf '%s\n' "$word"; done <<< $(ip -4 -br -o link list)
    else
        ip -4 -br -o link list | awk -v state=$state '$2==toupper(state) {print $1}'
    fi
}

function net_mac_list() {
    # Outputs list of interface MAC addresses one per line to stdout
    ip -4 -br -o link list | awk '{print $3}'
}

function net_if_mac() {
    # $1: interface name
    # Outputs MAC for specific interface
    [[ $# -lt 1 ]] && return 1
    ip -4 -br -o link list | awk -v IF=$1 '$1==IF {print $3}'
}

function net_ip_list() {
    # Outputs list of IP addresses one per line
    # $1 : interface name (optional). If specified only output IP for that interface
    local if_name=""
    if [[ $# -gt 0 ]]; then
        if_name=$1
    fi
    if [[ -n "$if_name" ]]; then
        ip -4 -br -o addr list | awk -v IF=$if_name '$1==IF {print $3}' | cut -d/ -f1
    else
        ip -4 -br -o addr list | awk '{print $3}' | cut -d/ -f1
    fi
}

function net_is_local_ip() {
    # $1: IPv4 address
    # Returns: 0 if $1 is a local IP; 1 otherwise
    [[ $# -lt 1 ]] && return 1
    local IP=$1
    [[ $IP  =~ ^[[:space:]]*$ ]] && return 1
    ip -4 -br -o addr list | awk '{print $3}' | cut -d/ -f1 | fgrep -qx "$IP"

}

function net_check_dns() {
    # $1: hostname (optional)
    # Returns: 0 if resolvable; 1 otherwise
    # +search is important and necessary to use short hostnames
    local ___HN=
    if [[ -n "${1+_}" ]]; then
        ___HN="$1"
    else
        ___HN="www.google.com"
    fi
    IP=$(dig +time=2 +tries=1 +retry=0 +short +search "$HN" 2>/dev/null)
    if [[ -z "$IP" ]]; then
        return 1
    fi
    return 0
}

function net_is_ipv4() {
    # $1: IP address as string
    # Returns:
    #   0 if it matches '\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}
    #   1 otherwise
    [[ $# -lt 1 ]] && return 1
    [[ "$1" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
}

function net_is_git_url() {
    # $1: URL
    # Returns:
    #   0: if URL is a git repository (having a HEAD)
    #   non-zero: otherwise - including if git command not found
    local GIT_ASKPASS=true git ls-remote "$1" HEAD 1>/dev/null 2>&1
    return $?
}

function net_is_valid_url() {
    # $1: URL
    # Returns:
    #   0: if URL is a valid HTTP(S) URL
    #   1: otherwise
    curl -s -f -I "$1" 1>/dev/null 2>&1
    return $?
}

___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true
