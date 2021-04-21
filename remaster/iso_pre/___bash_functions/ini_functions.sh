#!/bin/bash
# Putting the bash shebang allows vim-bash to understand <<<

#BASHDOC
# ------------------------------------------------------------------------
# Functions relating to reading INI files
#
# -------------------------------------------------------------
# INI file format (for functions in this file, at least)
# There is no "standard" or RFC.
# See: https://en.wikipedia.org/wiki/INI_file
#
# - Lines starting with '#' or ';' (semi-colon) are comments
# - Comments MUST start with '#' or ';' WITHOUT leading white space
# - Empty lines or lines with only white space are ignored
# - Remaining lines are one of the following line types
#       - Line defining a section: [<sec_name>]
#         <sec_name> is the name of the section enclosed in []
#           - Section definition lines MUST NOT be indented
#       - Line defining an option (key=value) within a section
#           - Spaces surrounding '=' are AUTOMATICALLY removed
#           - Trailing spaces in value are preserved
#           - Option line CANNOT have leading spaces
#
#       - Lines defining option outside any section
#
# - Common rules for option lines (inside a section or not):
#   - Must be of the form 'KEY = VALUE'
#   - KEY cannot be enclosed in quotes (single or double)
#   - Value can be optionally enclosed in quotes (single / double)
#       - Quotes if present are automatically removed
#   - Everything following the '=' is taken to be part of the value
#     and LEADING spaces (only) are automatically stripped
#   - Trailing spaces after KEY and before the '=' are automatically
#     discarded and are not part of KEY
#   - VALUE can be empty (missing) and will be set to the empty string
#   - KEY CANNOT be empty
#
# Notes (differences between ini_read_python and ini_read_bash):
# -------------------------------------------------------------
# ini_read_bash:
#   - Section definition lines can have leading white space
#   - Option lines can have leading white space - automatically discarded
#   - Comments may have optional leading white space before '#' or ';'
#   - Empty KEY will cause an error
#
# ini_read_python
#   - Option lines with empty KEY are discarded
#
#
# Use ini_read - will automatically try to use ini_read_python
# if python is available, and use ini_read_bash otherwise
#
# Global variables:
#   ___PY_CMD_LIST
#       Contains commands to be searched for using 'env <cmd>'
#       to find a python executable
#       If not set, this defaults (is set) to:
#           "python3 python python2"
#   ___PY_CMD - is set to working python command
#       To avoid having to run find_python multiple times
#
# -------------------------------------------------------------
# Common "API" of ini_read , ini_read_python and ini_read_bash
#
# $1: Name of associative array var to store config entries in
# ARG1 (associative array) must already exist
# $2: section name for options in ini file outside any section
# $3: path to INI file
# $4: Name of associataive array to update value sources - can be ""
#     Mandatory - set ARG4 to "" if not interested in this map
# $5: Set to "noclobber" to avoid updating EXISTING values in ARG1
#     Optional
#
# ARG1 (associative array) keys will be of the form:
#   <section>___<option_name>
#
# ARG4 (if set) will have key-value pairs of the form:
#   key-->key that was updated in ARG1
#   value-->full path to INI file
#
# No interpolation is done
# No SHELL or environment variable expansion
# No eval
# No expansion of backticks (``) or $() constructs
# Spaces around '=' are removed
# Enclosing single or double quotes around VALUE are removed
#
# Returns:
#   0: Success: INI file found, successfully read
#   1: ARG1 (result associative array) not set
#   2: ARG2 (global section name) not set
#   3: ARG3 (INI file path) not set
#   4: ARG4 (sources associative array) not set
#   5: ARG1 (associative array) variable not found
#   6: ARG4 (associative array) variable not found
#   7: INI file path invalid - does not point at a regular file
#   8: INI file not readable
#   9: INI file had one or more errors
# -------------------------------------------------------------
#
# ini_read_bash derived from:
# https://github.com/rudimeier/bash_ini_parser
# Below is the COPYRIGHT statement in conformity with BSD-3-Clause License
#
# read_ini.sh from https://github.com/rudimeier/bash_ini_parser has been
# changed a LOT - probably beyond recognition - to:
#   - Add / Update VAR=VALUE pairs to an associative array
#   - Add global options not inside any section automatically
#     to a named global section
#   - Disable / remove code resetting other global vars
#   - Remove capability to extract only one section
#   - Remove all 'eval'
#   - Remove code for interpreting booleans
#   - ... and more ... probably
#
# ---- read_ini_bash Copyright (start) ------------------------------
# Copyright (c) 2009    Kevin Porter / Advanced Web Construction Ltd
#                       (http://coding.tinternet.info, http://webutils.co.uk)
# Copyright (c) 2010-2014     Ruediger Meier <sweet_f_a@gmx.de>
#                             (https://github.com/rudimeier/)
#
# License: BSD-3-Clause, see LICENSE file
# ---- read_ini_bash Copyright (end) --------------------------------
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

# For cmd_catch_stdout_stderr and cmd_find_python
source_file cmd_functions.sh


function ini_read_python() {
    # $1: Name of associative array var to store config entries in
    # ARG1 (associative array) must already exist
    # $2: section name for options in ini file outside any section
    # $3: path to INI file
    # $4: Name of associataive array to update value sources - can be ""
    #     Mandatory - set ARG4 to "" if not interested in this map
    # $5: Set to "noclobber" to avoid updating EXISTING values in ARG1
    #     Optional
    #
    # ARG1 (associative array) keys will be of the form:
    #   <section>___<option_name>
    #
    # ARG4 (if set) will have key-value pairs of the form:
    #   key-->key that was updated in ARG1
    #   value-->full path to INI file
    #
    # No interpolation is done
    # No SHELL or environment variable expansion
    # No eval
    # No expansion of backticks (``) or $() constructs
    # Spaces around '=' are removed
    # Enclosing single or double quotes around VALUE are removed
    #
    # Returns:
    #   0: Success: INI file found, successfully read
    #   1: ARG1 (result associative array) not set
    #   2: ARG2 (global section name) not set
    #   3: ARG3 (INI file path) not set
    #   4: ARG4 (sources associative array) not set
    #   5: ARG1 (associative array) variable not found
    #   6: ARG4 (associative array) variable not found
    #   7: INI file path invalid - does not point at a regular file
    #   8: INI file not readable
    #   9: Parsing INI file with python returned non-zero
    #   10: PYTHON not found or could not execute test code
    #
    [[ $# -lt 1 ]] && return 1
    [[ $# -lt 2 ]] && return 2
    [[ $# -lt 3 ]] && return 3
    [[ $# -lt 4 ]] && return 4
    var_is_map $1 || return 5
    local SOURCE_VAR==""
    if [ -n "$4" ]; then
        var_is_map $4 || return 6
        SOURCE_VAR=$4
    fi
    local NOCLOBBER=""
    if [[ $# -gt 4 ]]; then
        if [[ "$5" = "noclobber" ]]; then
            NOCLOBBER="noclobber"
        fi
    fi
    declare -n ___RESULT_VAR=$1
    local GLOBAL_SEC=$2
    local INI_FILE=$(readlink -e "$3") || return 7
    [[ -f "$INI_FILE" ]] || return 7
    [[ -r "$INI_FILE" ]] || return 8

    local PYTHON_CODE="
import sys
PY2 = False
if sys.version_info[0] < 3:
    PY2 = True
if PY2:
    from ConfigParser import SafeConfigParser
else:
    from configparser import SafeConfigParser
from io import StringIO

if len(sys.argv) < 3:
    exit(2)
global_sec = sys.argv[1]
ini_file = sys.argv[2]
fp_val = ('[%s]\n\n' % (global_sec,)) + open(ini_file, 'r').read()
if PY2:
    fp_val = fp_val.decode('utf8')
fp = StringIO(fp_val)
cfg = SafeConfigParser()
if PY2:
    cfg.readfp(fp, filename=ini_file)
else:
    fp.name = ini_file
    cfg.read_file(fp)
for s in cfg.sections():
    for (n, v) in cfg.items(section=s, raw=True):
        print('%s___%s=%s' % (s, n, v))
"
    var_declared ___PY_CMD || ret=10
    PYTHON_CMD=$___PY_CMD

    local ret=0
    declare STDOUT
    declare STDERR
    cmd_catch_stdout_stderr STDOUT STDERR env $PYTHON_CMD -c "$PYTHON_CODE" "$GLOBAL_SEC" "$INI_FILE" || ret=$?
    if [[ $ret -ne 0 ]]; then
        # env returns 125 if env itself failed and 127 if 'env <cmd> ' failed
        # In those cases, we return $ret as-is
        if [[ $ret -eq 125 || $ret -eq 127 ]]; then
            return $ret
        fi
        >&2 echo "Python Return code: $ret"
        >&2 echo -e "Error output:\n$STDERR"
        return 9
    fi

    declare -A LOCAL_RESULT
    declare -A LOCAL_SOURCE
    local OLD_IFS=$IFS
    # read does NOT do variable / brace / backtick etc expansion
    while read -r line
    do
        IFS="="
        # read does NOT do variable / brace / backtick etc expansion
        read -r VAR VAL <<< "${line}"
        IFS="${OLD_IFS}"

        # delete spaces around the equal sign (using extglob)
        VAR="${VAR%%+([[:space:]])}"
        VAL="${VAL##+([[:space:]])}"
        
        if [[ "${VAL}" =~ ^\".*\"$  ]]; then
            # remove existing double quotes
            VAL="${VAL##\"}"
            VAL="${VAL%%\"}"
        elif [[ "${VAL}" =~ ^\'.*\'$  ]]; then
            # remove existing single quotes
            VAL="${VAL##\'}"
            VAL="${VAL%%\'}"
        fi
        # Silently drop options where VAR is null
        [[ -n "$VAR" ]] && LOCAL_RESULT["$VAR"]=$VAL
    done <<<"$STDOUT"

    # Now copy LOCAL_RESULT to ___RESULT_VAR obeying no-clobber rules
    for ___key in "${!LOCAL_RESULT[@]}"
    do
        # no-clobber check
        ret=0
        var_map_has_elem ___RESULT_VAR "$___key" || ret=1
        # [[ -n ${___RESULT_VAR["$___key"]+_} ]] || ret=1
        if [[ $ret -eq 0 ]]; then
            if [[ "$NOCLOBBER" ]]; then
                continue
            fi
        fi
        ___RESULT_VAR["$___key"]=${LOCAL_RESULT["$___key"]}
        # Update LOCAL_SOURCE ALWAYS - will decide later whether
        # to copy to ___SOURCE_VAR
        LOCAL_SOURCE["$___key"]="$INI_FILE"
    done
    [[ -z "$SOURCE_VAR" ]] && return 0
    var_is_map "$SOURCE_VAR" || return 0
    declare -n ___SOURCE_VAR=$SOURCE_VAR
    for ___key in "${!LOCAL_SOURCE[@]}"
    do
        ___SOURCE_VAR["$___key"]=${LOCAL_SOURCE["$___key"]}
    done
    return 0
}

function ini_read_bash() {
    # $1: Name of associative array var to store config entries in
    # ARG1 (associative array) must already exist
    # $2: section name for options in ini file outside any section
    # $3: path to INI file
    # $4: Name of associataive array to update value sources - can be ""
    #     Mandatory - set ARG4 to "" if not interested in this map
    # $5: Set to "noclobber" to avoid updating EXISTING values in ARG1
    #     Optional
    #
    # ARG1 (associative array) keys will be of the form:
    #   <section>___<option_name>
    #
    # ARG4 (if set) will have key-value pairs of the form:
    #   key-->key that was updated in ARG1
    #   value-->full path to INI file
    #
    # No interpolation is done
    # No SHELL or environment variable expansion
    # No eval
    # No expansion of backticks (``) or $() constructs
    # Spaces around '=' are removed
    # Enclosing single or double quotes around VALUE are removed
    #
    # Returns:
    #   0: Success: INI file found, successfully read
    #   1: ARG1 (result associative array) not set
    #   2: ARG2 (global section name) not set
    #   3: ARG3 (INI file path) not set
    #   4: ARG4 (sources associative array) not set
    #   5: ARG1 (associative array) variable not found
    #   6: ARG4 (associative array) variable not found
    #   7: INI file path invalid - does not point at a regular file
    #   8: INI file not readable
    #   9: INI file contained one or more errors
    #
    [[ $# -lt 1 ]] && return 1
    [[ $# -lt 2 ]] && return 2
    [[ $# -lt 3 ]] && return 3
    [[ $# -lt 4 ]] && return 4
    var_is_map $1 || return 5
    local SOURCE_VAR==""
    if [ -n "$4" ]; then
        var_is_map $4 || return 6
        SOURCE_VAR=$4
    fi
    local NOCLOBBER=""
    if [[ $# -gt 4 ]]; then
        if [[ "$5" = "noclobber" ]]; then
            NOCLOBBER="noclobber"
        fi
    fi
    declare -n ___RESULT_VAR=$1
    local GLOBAL_SEC=$2
    local INI_FILE=$(readlink -e "$3") || return 7
    [[ -f "$INI_FILE" ]] || return 7
    [[ -r "$INI_FILE" ]] || return 8

	local LINE_NUM=0
	local SECTION=""
    declare -A LOCAL_RESULT
    declare -A LOCAL_SOURCE
	
	# IFS is used in "read" and we want to switch it within the loop
	local IFS_OLD="${IFS}"
	local IFS=$' \t\n'
	
    # read does NOT do variable / brace / backtick etc expansion
    local ret=0
	while read -r line || [ -n "$line" ]
	do
		((LINE_NUM++))

		# Skip blank lines and comments
		if [ -z "$line" -o "${line:0:1}" = ";" -o "${line:0:1}" = "#" ]
		then
			continue
		fi

		# Section marker?
		if [[ "${line}" =~ ^\[[a-zA-Z0-9_]{1,}\]$ ]]
		then
			# Set SECTION var to name of section (strip [ and ] from section marker)
			SECTION="${line#[}"
			SECTION="${SECTION%]}"
			continue
		fi

		# Valid var/value line? (check for variable name and then '=')
		if ! [[ "${line}" =~ ^[a-zA-Z0-9._]{1,}[[:space:]]*= ]]
		then
            >&2 echo "Error: Invalid line (${LINE_NUM}): $line"
			ret=9
            continue
		fi
        # If there were any errors, only parse remaining lines and
        # do not do any extra processing / parsing of VAR / VAL
        [[ $ret -ne 0 ]] && continue

		# split line at "=" sign
		IFS="="
        # read does NOT do variable / brace / backtick etc expansion
		read -r VAR VAL <<< "${line}"
		IFS="${IFS_OLD}"
		
		# delete spaces around the equal sign (using extglob)
		VAR="${VAR%%+([[:space:]])}"
		VAL="${VAL##+([[:space:]])}"


		# Construct variable name:
		if [ -z "$SECTION" ]
		then
			VARNAME=${GLOBAL_SEC}___${VAR}
		else
			VARNAME=${SECTION}___${VAR}
		fi

		# remove enclosing single or double quotes in VAL
		if [[ "${VAL}" =~ ^\".*\"$  ]]
		then
			VAL="${VAL##\"}"
			VAL="${VAL%%\"}"
		elif [[ "${VAL}" =~ ^\'.*\'$  ]]
		then
			VAL="${VAL##\'}"
			VAL="${VAL%%\'}"
		fi
		
		LOCAL_RESULT[$VARNAME]=$VAL
	done  <"${INI_FILE}"
    [[ $ret -ne 0 ]] && return $ret

    # Now copy LOCAL_RESULT to ___RESULT_VAR obeying no-clobber rules
    for ___key in "${!LOCAL_RESULT[@]}"
    do
        # no-clobber check
        ret=0
        var_map_has_elem ___RESULT_VAR "$___key" || ret=1
        #[[ -n ${___RESULT_VAR["$___key"]+_} ]] || ret=1
        if [[ $ret -eq 0 ]]; then
            if [[ "$NOCLOBBER" ]]; then
                continue
            fi
        fi
        ___RESULT_VAR["$___key"]=${LOCAL_RESULT["$___key"]}
        # Update LOCAL_SOURCE ALWAYS - will decide later whether
        # to copy to ___SOURCE_VAR
        LOCAL_SOURCE["$___key"]="$INI_FILE"
    done
    [[ -z "$SOURCE_VAR" ]] && return 0
    var_is_map "$SOURCE_VAR" || return 0
    declare -n ___SOURCE_VAR=$SOURCE_VAR
    for ___key in "${!LOCAL_SOURCE[@]}"
    do
        ___SOURCE_VAR["$___key"]=${LOCAL_SOURCE["$___key"]}
    done
    return 0
}

function ini_read() {
    local CHECK_PYTHON_CODE="
import sys
PY2 = False
if sys.version_info[0] < 3:
    PY2 = True
if PY2:
    from ConfigParser import SafeConfigParser
else:
    from configparser import SafeConfigParser
from io import StringIO
"
    local ret=0
    var_declared ___PY_CMD || ret=1
    if [[ $ret -eq 0 ]]; then
        # Already have checked and python is found and OK
        ini_read_python $@ || ret=$?
    else
        ret=0
        declare -g ___PY_CMD=$(cmd_find_python "$CHECK_PYTHON_CODE") || ret=$?
        if [[ $ret -eq 0 ]]; then
            readonly ___PY_CMD
            ini_read_python $2 || ret=$?
        fi
    fi
    # env returns 125 if env itself failed and 127 if 'env <cmd> ' failed
    # In those cases, we retry with ini_read_bash
    if [[ $ret -ne 0 && $ret -ne 125 && $ret -ne 127 ]]; then
        return $ret
    fi
    # If we got here, python could not be found or did not work
    ret=0
    ini_read_bash $@ || ret=$?
    return $ret
}


___SOURCED[$(readlink -e ${BASH_SOURCE[0]})]=sourced
# ------------------------------------------------------------------------
# Do not proceed further if sourced from an interactive shell
# ------------------------------------------------------------------------
[[ "$___INTERACTIVE" = "yes" ]] && return || true


