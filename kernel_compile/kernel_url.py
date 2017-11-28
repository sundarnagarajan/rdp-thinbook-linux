'''
New version that uses the JSON API at www.kernel.org
'''
import sys
import subprocess
import json
from collections import namedtuple
import traceback


KernelURL = namedtuple('KernelURL', [
    'ktype',
    'kver',
    'download_url',
    'sig_url',
    'changelog_url',
    'release_date',
])
KERNEL_ORG_JSON_URL = 'https://www.kernel.org/releases.json'


def get_kernel_urls(show_exception=True):
    '''
    Returns-->LIST of KernelURL namedtuples
    '''
    ret = []
    try:
        CMD = "curl -s '%s'" % (KERNEL_ORG_JSON_URL,)
        j = subprocess.check_output(CMD, shell=True)
        d = json.loads(j.decode('utf8'))
        latest_version = d['latest_stable']['version']
        latest_kurl = None
        for rel in d['releases']:
            # Ignore releases without 'moniker' set
            ktype = rel.get('moniker', None)
            if not ktype:
                continue
            # Ignore linux-next
            if ktype == 'linux-next':
                continue
            # Ignore releases that don't have required fields
            try:
                kver = rel['version']
                dl_url = rel['source']
                sig_url = rel['pgp']
            except:
                if show_exception:
                    sys.stderr.write(traceback.format_exc())
                continue

            # changelog_url and release_date are optional
            cl_url = rel.get('changelog', None)
            try:
                rel_date = rel['released']['isodate']
            except:
                rel_date = None

            # Set ktype for latest kernel version
            if kver == latest_version:
                ktype = 'latest'
            kurl = KernelURL(
                ktype=ktype,
                kver=kver,
                download_url=dl_url,
                sig_url=sig_url,
                changelog_url=cl_url,
                release_date=rel_date,
            )
            # Keep the latest one aside to insert as first element later
            if ktype == 'latest':
                latest_kurl = kurl
            else:
                ret.append(kurl)

        # Add latest one as first element
        if latest_kurl:
            ret.insert(0, latest_kurl)
    except:
        if show_exception:
            sys.stderr.write(traceback.format_exc())
        pass
    return ret


def filter_kernel_urls(l, ktype=None, kver=None):
    '''
    l-->LIST of KernelURL namedtuples - as returned by get_kernel_urls()
    ktype-->str or None
        If str, must be one of: latest|mainline|stable|longterm|linux-next
        If None, any type of kernel is allowed
    kver-->str or None: If str:
        If kver has 2 components (e.g. 4.14), only kernel versions with
            first 2 version components that match are returned
        If kver has 3 components (e.g. 4.14.2), only kernel versions that
            match exactly are returned
        If kver has less than 2 or more than 3 components, only kernel
            versions that match exactly are returned
    Returns-->KernelURL namedtuple (single) - first matching
    Descending order of preference (if multiple match ktype and/or kver):
        - Latest
        - mainline
        - stable
        - longterm (in order they appear)
    '''
    ret = []
    for u in l:
        if ktype and u.ktype != ktype:
            continue
        if kver:
            l_kver = kver.split('.')
            l_u_kver = u.kver.split('.')
            if len(l_kver) == 2:
                if l_kver[:2] != l_u_kver[:2]:
                    continue
            else:
                if kver != u.kver:
                    continue
        ret.append(u)
    if ret:
        return ret[0]
    else:
        return None
