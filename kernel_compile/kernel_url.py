#!/usr/bin/env python
import sys
import subprocess
import re
import traceback
from collections import namedtuple


KernelURL = namedtuple('KernelURL', [
    'ktype',
    'kver',
    'download_url',
    'sig_url'
])


def get_url_html_src(url, show_exception=True):
    '''
    url-->str: including protocol (https etc)
    Returns-->str, or None if an exception occurred
    '''
    cmd = "curl -s -f '%s'" % url
    try:
        return subprocess.check_output(cmd, shell=True)
    except:
        if show_exception:
            sys.stderr.write(traceback.format_exc())
        return None


def kver_from_url(url):
    '''
    Returns-->str (or None if url does not look like kernel url)
    '''
    try:
        url_file = url.rsplit('/', 1)[1]
        pat = 'linux-(?P<KVER>.*?)\.tar'
        return re.search(pat, url_file).groupdict()['KVER']
    except:
        return None


def match_and_lstrip(src, pat, group=None):
    '''
    src-->str: HTML source
    pat-->str: regular expression
    group-->str or None: If set, that element from groupdict is returned
    Returns-->tuple:
        match-->str: matched part
        rest-->str: part of src AFTER match
    If pat does not match, returns (None, src)
    '''
    try:
        m = re.search(pat, src)
        if group:
            m_str = m.groupdict()[group]
        else:
            m_str = src[m.start():m.end()]
        return (m_str, src[m.end():])
    except:
        return (None, src)


def get_download_and_sig_urls(src):
    '''
    src-->str: HTML source
    Returns-->tuple:
        download_url-->str (or None if not found)
        sig_url-->str (or None if not found)
    '''
    download_url = None
    sig_url = None
    pat_tar = '<td>\[<a href="(?P<URL>.*?)" title="Download complete tarball">tarball</a>\]'    # noqa: E501
    pat_sig = '<td>\[<a href="(?P<URL>.*?)" title="Download PGP verification signature">pgp</a>\]'    # noqa: E501
    pat_href = '<a href="(?P<URL>.*?)"'
    (download_url, s1) = match_and_lstrip(src, pat_tar, group='URL')
    if not download_url:
        (download_url, s1) = match_and_lstrip(src, pat_href, group='URL')
    (sig_url, s2) = match_and_lstrip(s1, pat_sig, group='URL')
    return (download_url, sig_url)


def extract_src(src, begin='', end=''):
    '''
    src-->str: HTML source
    begin, end-->str: regular expressions
    Returns-->str: part starting with begin and BEFORE (not including) end
    Returns-->None if pattern was not matched
    '''
    if begin:
        if end:
            pat = '(?P<INTERESTED>%s.*?)%s' % (begin, end)
        else:
            pat = '(?P<INTERESTED>%s.*)' % (begin)
    else:
        if end:
            pat = '(?P<INTERESTED>.*?)%s' % (end)
        else:
            return src

    m = re.search(pat, src, re.MULTILINE + re.DOTALL)
    if not m:
        return None
    return m.groupdict()['INTERESTED']


def get_kernel_urls(show_exception=True):
    '''
    Returns-->LIST of KernelURL namedtuples

    This is the method that makes assumptions about the structure of HTML
    source of https://www.kernel.org

    Assumptions:
        - Area of interest is between:
            '<table id="latest">'
            AND
            '<section id="extras" class="body">'
        - Ignore everything after '<section id="extras" class="body">'
        - Table (highlighted in yellow) named 'latest' comes FIRST
        - Table row named 'latest_button' is within this table (next)
        - Table named 'releases' comes AFTER table 'latest'
        - Each ktype (mainline, stable, longterm etc.) is identified by a ROW
            that has a table row that looks like: '<td><KTYPE>:</td>'
            where '<KTYPE>' is ktype
            - Order: mainline, stable, longterm, linux-next
        - At most 1 mainline
        - At most 1 stable
        - Zero or more longterm
    '''
    pat_latest_table = '<table id="latest">'
    pat_end_extras = '<section id="extras" class="body">'
    pat_latest_button = '<td id="latest_button">'
    pat_releases_table = '<table id="releases">'

    pat_mainline_td = '<td>mainline:</td>'
    pat_stable_td = '<td>stable:</td>'
    pat_longterm_td = '<td>longterm:</td>'
    pat_linux_next_td = '<td>linux-next:</td>'

    ret = []
    try:
        s = get_url_html_src('https://www.kernel.org')
        # Use only part between pat_latest_table and pat_end_extras
        s_interest = extract_src(
            s, begin=pat_latest_table, end=pat_end_extras)
        if not s_interest:
            return ret
        # Assumptions on ORDER of tables / rows:
        #   - If tbl_latest is present, it is FIRST
        #   - If tbl_releases is present itis AFTER tbl_latest (last)
        #   - Within tbl_releases:
        #       - At most one mainline row - first row
        #       - At most one stable row - AFTER mainline row if present
        #       - Zero or more longterm rows - AFTER stable, mainline
        #           rows if present

        tbl_releases = extract_src(s_interest, begin=pat_releases_table)
        if tbl_releases:
            tbl_latest = extract_src(s_interest, end=pat_releases_table)
        else:
            tbl_latest = s_interest

        if tbl_releases:
            # Start from the end - linux-next
            row_linux_next = extract_src(tbl_releases, begin=pat_linux_next_td)
            if row_linux_next:
                tbl_releases = extract_src(tbl_releases, end=pat_linux_next_td)
            # rowlist_longterm
            rowlist_longterm = extract_src(
                tbl_releases, begin=pat_longterm_td)
            if rowlist_longterm:
                tbl_releases = extract_src(tbl_releases, end=pat_longterm_td)

            # stable
            row_stable = extract_src(
                tbl_releases, begin=pat_stable_td)
            if row_stable:
                tbl_releases = extract_src(tbl_releases, end=pat_stable_td)

            # mainline
            row_mainline = extract_src(
                tbl_releases, begin=pat_mainline_td)
            # if row_mainline:
            #     tbl_releases = extract_src(tbl_releases, end=pat_mainline_td)
        else:
            row_mainline = ''
            row_stable = ''
            rowlist_longterm = ''
            row_linux_next = ''

        # Latest release
        if tbl_latest:
            (m, tbl_latest) = match_and_lstrip(tbl_latest, pat_latest_button)
            if m:
                (dl_url, sig_url) = get_download_and_sig_urls(tbl_latest)
                ret.append(KernelURL(
                    ktype='latest',
                    kver=kver_from_url(dl_url),
                    download_url=dl_url,
                    sig_url=sig_url
                ))
        # mainline
        if row_mainline:
            (dl_url, sig_url) = get_download_and_sig_urls(row_mainline)
            if dl_url:
                ret.append(KernelURL(
                    ktype='mainline',
                    kver=kver_from_url(dl_url),
                    download_url=dl_url,
                    sig_url=sig_url
                ))
        # stable
        if row_stable:
            (dl_url, sig_url) = get_download_and_sig_urls(row_stable)
            if dl_url:
                ret.append(KernelURL(
                    ktype='stable',
                    kver=kver_from_url(dl_url),
                    download_url=dl_url,
                    sig_url=sig_url
                ))
        # Find longterm releases, one by one
        if not rowlist_longterm:
            return ret

        m = re.search(pat_longterm_td, rowlist_longterm)
        while m:
            (dl_url, sig_url) = get_download_and_sig_urls(rowlist_longterm)
            if dl_url:
                ret.append(KernelURL(
                    ktype='longterm',
                    kver=kver_from_url(dl_url),
                    download_url=dl_url,
                    sig_url=sig_url
                ))
            rowlist_longterm = rowlist_longterm[m.end():]
            m = re.search(pat_longterm_td, rowlist_longterm)
    except:
        if show_exception:
            sys.stderr.write(traceback.format_exc())
    return ret


def filter_kernel_urls(l, ktype=None, kver=None):
    '''
    l-->LIST of KernelURL namedtuples - as returned by get_kernel_urls()
    ktype-->str or None
        If str, must be one of: latest|mainline|stable|longterm|linux-next
        If None, any type of kernel is allowed
    kver-->str or None: If str: filename part of url will be checked
        to ensure it starts with linux-<kver>
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
        if kver and not u.kver.startswith(kver):
            continue
        ret.append(u)
    if ret:
        return ret[0]
    else:
        return None
