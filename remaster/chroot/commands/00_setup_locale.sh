#!/bin/bash
#
# On Ubuntu 18.04 live server ISO, when running update-initramfs -u
# you get errors that look like:
#
# perl: warning: Setting locale failed.
# perl: warning: Please check that your locale settings:
# 	LANGUAGE = "en_US",
# 	LC_ALL = (unset),
# 	LANG = "en_US.UTF-8"
#     are supported and installed on your system.
# perl: warning: Falling back to the standard locale ("C").
#

echo "Setting up locales"
locale-gen en_US en_US.UTF-8 1>/dev/null 2>&1
dpkg-reconfigure --frontend=noninteractive locales 1>/dev/null 2>&1
