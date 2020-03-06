# Read an INI file and output declare statements that can be safely
# 'eval'-ed in bash to set bash variables
#
# Usage:
#   eval "$(read_ini.sh [options] <path/to/ini_file>"
# Run read_ini.sh --help to see options and info on INI file
#
# Original from https://stackoverflow.com/a/37935960
# I added:
#   - Comment removal
#   - Safety check
#   - remove '[]' from section names
#   - Set variable names to ${section}__$var instead of ${var}${section}

PROG_NAME=$(basename $0)
ALLOW_DEREFERENCE=no
NEED_SECTIONS=no

function remove_comments() {
    # Reads stdin, writes stdout
    # Filters shell comments - starting after zero or more white space only
    cat | grep -v '^[[:space:]]*#' | grep -v '^[[:space:]]*$'
}

function show_usage() {
    mesg="
Usage:
    eval \"\$($PROG_NAME [options] <path/to/ini_file>)\"

Options:
      -h|--help              : Show usage and exit
      -d|--allow-dereference : allow \${!var_name} construct
      -s|--silent            : Suppress warnings on disallowed constructs
      -n|--need-sections     : Ignore variables outside sections

Examples:

Read /my/path/x.ini allowing \${\!var_name} construct:
    eval \"\$($PROG_NAME [options] -d /my/path/x.ini)\"

Read /my/path/x.ini suppressing warnings on disallowed constructs
    eval \"\$($PROG_NAME [options] -s /my/path/x.ini)\"


What is supported in INI file
  - Comments must start with #
  - Comments can have leading white space
  - Sections are optional - unless -n is specified
  - Variables outside any section will be named for the INI file variable
  - Variables inside a section will named \${section}__\$var - note TWO _
  - Can reference earlier vars and env vars using standard \${var}
  - References allowed in section names, variable names and values

Constraints (on INI file):
  - Cannot have code followed by comment
  - Following constructs are NOT allowed because I consider them unsafe
      - \$(command_or_function) - execution not expected in CONFIG
      - \`command_or_function\` - execution not expected in CONFIG
      - \${!var_name} - DEREFERENCING - value of variable with name that
        is value of var_name - can allow with -d option
"
    echo "$mesg"
}

function check_safety() {
    # Parameters: variable names - must be global !
    # Returns: 0 if all parameters are safe; 1 otherwise
    if [ "$ALLOW_DEREFERENCE" = "yes" ]; then
        local UNSAFE_PATTERNS='(\$\(|`)'
    else
        local UNSAFE_PATTERNS='(\$\(|`|\$\{\!)'
    fi
    for check_var in $*
    do
        local x=${check_var}
        [[ $x =~ $UNSAFE_PATTERNS ]] && return 1
    done
    return 0
}

function read_ini() {
    # $1: name of INI file (only for warnings)
    # reads stdin
    local ini_file=$1
    while IFS='= ' read var val
    do
        if [[ $var == \[*] ]]
        then
            section=$(echo $var | sed -e 's/^\[//' -e 's/\]$//')
        elif [[ $val ]]
        then
            if [ -n "$section" ]; then
                local x=${section}__${var}
            else
                if [ "$NEED_SECTIONS" = "yes" ]; then
                    >&2 echo "Ignoring variable outside sections: ${var}"
                    continue
                fi
                local x=${var}
            fi

            # ------------------- Safety check start ---------------------
            local safe=yes
            check_safety $section $var $val || safe=no
            if [ "$safe" != "yes" ]; then
                if [ -n "$section" ]; then
                    >&2 echo "$ini_file: Unsafe: declare ${section}__${var}= ${val}"
                else
                    >&2 echo "$ini_file: Unsafe: declare ${var}= ${val}"
                fi
                continue
            fi
            # ------------------- Safety check end -----------------------

            # If we got here, safe=yes
            # Next declare is needed to cross-reference within INI
            eval "declare -x ${x}=$val"
            echo "declare $x=${!x}"
        fi
    done
}

function process_cmdline() {
    # Parameters: command line parameters to script
    
    local OPTS_COMPLETE=no
    local SHOW_WARNINGS=yes
    local ini_path=

    if [ -z "$1" ]; then
        show_usage
        exit 0
    fi
    while [ -n "$1" ]
    do
        case "$1" in
            -h|--help)
                if [ "$OPTS_COMPLETE" != "yes" ]; then
                    show_usage
                    exit 0
                fi
                ini_path=$1
                shift 1
                ;;
            -d|--allow-dereference)
                if [ "$OPTS_COMPLETE" != "yes" ]; then
                    ALLOW_DEREFERENCE=yes
                else
                    ini_path=$1
                fi
                shift 1
                ;;
            -s|--silent)
                if [ "$OPTS_COMPLETE" != "yes" ]; then
                    SHOW_WARNINGS=no
                else
                    ini_path=$1
                fi
                shift 1
                ;;
            -n|--need-sections)
                if [ "$OPTS_COMPLETE" != "yes" ]; then
                    NEED_SECTIONS=yes
                else
                    ini_path=$1
                fi
                shift 1
                ;;
            --)
                if [ "$OPTS_COMPLETE" != "yes" ]; then
                    OPTS_COMPLETE=yes
                else
                    ini_path=$1
                fi
                shift 1
                ;;
            *)
                if [ -z "$ini_path" ]; then
                    ini_path=$1
                else
                    >&2 echo "ini path already set. Ignoring parameter: $1"
                fi
                shift 1
                ;;
        esac
    done

    normalized_ini_path=$(readlink -e -- $ini_path 2>/dev/null)
    if [ $? -eq 0 ]; then
        if [ ! -f "$ini_path" ]; then
            >&2 echo "INI path does not exist: $ini_path"
            return 1
        fi
    else
        >&2 echo "INI path does not exist: $ini_path"
        return 1
    fi
    ini_path=$normalized_ini_path

    if [ "$SHOW_WARNINGS" = "yes" ]; then
        cat -- "$ini_path" | remove_comments | read_ini "$ini_file"
    else
        cat -- "$ini_path" | remove_comments | read_ini "$ini_file" 2>/dev/null
    fi
}

process_cmdline $*
exit $?
