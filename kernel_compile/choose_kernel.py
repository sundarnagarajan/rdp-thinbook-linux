#!/usr/bin/env python
import os
import re
from kernel_url import get_kernel_urls, filter_kernel_urls


def get_chosen_kernel_url(verbose=False):
    '''
    verbose-->boolean: If True, user-centric output is printed to stdout
    Returns-->kernel_url.KernelURL namedtuple or None
    '''
    script_dir = os.path.dirname(os.path.realpath(__file__))
    config_file = os.path.join(script_dir, 'config.kernel')
    override_config_file = os.environ.get('KERNEL_CONFIG', None)
    if override_config_file:
        if os.path.isfile(override_config_file):
            config_file = os.path.realpath(override_config_file)
            if verbose:
                print('Using config: %s' % (config_file,))
        else:
            if verbose:
                print('Ignoring non-existent config file: %s' % (
                    override_config_file,))

    override_ktype = os.environ.get('KERNEL_TYPE', None)
    override_kver = os.environ.get('KERNEL_VERSION', None)
    if (override_ktype or override_kver):
        if override_ktype is not None and override_ktype not in [
            'latest',
            'mainline',
            'stable',
            'longterm'
        ]:
            if verbose:
                print('Ignoring invalid KERNEL_TYPE in environment: %s' % (
                    override_ktype,
                ))
            override_ktype = None

    l = get_kernel_urls()
    if verbose:
        fmt = '    %-16s %-10s %-10s'
        print('Available kernels:')
        print(fmt % ('Type', 'Version', 'Rel. Date'))
        for u in l:
            print(fmt % (
                u.ktype, u.kver,
                u.release_date or ''
            ))

    kver = None
    ktype = None

    try:
        cfg_src = open(config_file, 'r').read()
        pat = '\# Linux.*? (?P<KVER>.*?) Kernel Configuration'
        m = re.search(pat, cfg_src)
        if m:
            kver = m.groupdict()['KVER']
            # Take only major and minor version, not revision number
            kver = '.'.join(kver.split('.')[:2])
    except:
        pass
    if kver:
        if verbose:
            print('Available config is from kernel %s' % (kver,))
        # Do not filter based on config - we know how to upgrade config!
        # kurl = filter_kernel_urls(l, kver=kver)
        kurl = filter_kernel_urls(l)
    else:
        kurl = filter_kernel_urls(l)

    if kurl:
        if verbose:
            print('Will choose: %s (%s)' % (
                kurl.kver, kurl.ktype))

        if (override_ktype or override_kver):
            kurl = filter_kernel_urls(
                l,
                ktype=override_ktype,
                kver=override_kver,
            )
            if kurl:
                if verbose:
                    print('Based on settings, will choose %s (%s)' % (
                        kurl.kver, kurl.ktype
                    ))
            else:
                if verbose:
                    print('No available kernels based on settings %s (%s)' % (
                        kver, ktype
                    ))
    else:
        if verbose:
            print('No available kernels based on settings %s (%s)' % (
                kver, ktype
            ))
    return kurl
