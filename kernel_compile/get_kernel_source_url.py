#!/usr/bin/env python
'''
Following environment variables can be set to override default logic:
    KERNEL_CONFIG    : FULL PATH to existing config file
                       Will override config.kernel in this directory
    KERNEL_VERSION   : Will override version from config file
                       Will filter available kernels
    KERNEL_TYPE      : Will filter available kernels
                       IGNORED if it is not a recognized type:
                           latest|mainline|stable|longterm

Default logic:
    - Kernel version is set from existing config file
    - Descending order of perference of kernel types:
        - latest
        - mainline
        - stable
        - longterm
    - By default will only choose major version same as config
        Can override with KERNEL_VERSION
    - By default will use config.kernel in current dir
        Can override with KERNEL_CONFIG
    - By default will choose first matching kernel, in descending order
        of preference of kernel type as above.
        Can override (filter) with KERNEL_TYPE
'''
import sys
from choose_kernel import get_chosen_kernel_url

kurl = get_chosen_kernel_url(verbose=False)
if kurl:
    sys.stdout.write(kurl.download_url + '\n')
