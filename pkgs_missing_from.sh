#!/bin/bash
REQD_PKGS="$*"

MISSING_PKGS=$(dpkg -l $REQD_PKGS 2>/dev/null | sed -e '1,4d'| grep -v '^ii' | awk '{printf("%s ", $2)}')
MISSING_PKGS="$MISSING_PKGS $(dpkg -l $REQD_PKGS 2>&1 1>/dev/null | sed -e 's/^dpkg-query: no packages found matching //' | tr '\n' ' ')"
MISSING_PKGS="$(echo ${MISSING_PKGS} | sed -e 's/^[ \t]*//' -e 's/[ \t]*$//')"
if [ -n "${MISSING_PKGS}" ]; then
	INSTALL_CMD="One or more required packages are missing. Install them with:\nsudo apt-get install $MISSING_PKGS"
    ret=1
else
    echo "All required packages are installed"
    echo "Required packages:"
    echo $REQD_PKGS | fmt -w 70 | sed -e 's/^/    /'
    echo ""
    ret=0
    exit $ret
fi
echo -e $INSTALL_CMD
exit $ret
