#!/usr/bin/env python
import subprocess
import re
import os
import shutil
import sys
from collections import OrderedDict
# On Ubuntu 18.04 live server ISO, only PY3 is available
if sys.version_info.major == 3:
    import configparser as ConfigParser
else:
    import ConfigParser


CONFIG_FILE = 'rebrand.config'
CONFIG_SECTION = 'rebrand'
SCRIPT_DIR = os.path.realpath(
    os.path.dirname(__file__))
WORD_CHARS = '[a-zA-Z0-9.-_]'


def get_config_values():
    '''
    Returns-->dict: values from CONFIG_SECTION of CONFIG_FILE
    '''
    ret = {}
    if not os.path.isfile(
        os.path.join(SCRIPT_DIR, CONFIG_FILE)
    ):
        return ret
    try:
        cfg = ConfigParser.ConfigParser()
        cfg.read(os.path.join(SCRIPT_DIR, CONFIG_FILE))
        ret = dict(cfg.items(CONFIG_SECTION))
        word_pat = '(?P<id>%s+)' % WORD_CHARS
        if ret['new_distro_id']:
            m = re.match(word_pat, ret['new_distro_id'])
            if m:
                ret['new_distro_id'] = m.groupdict()['id']
        if ret['etc_subdir']:
            m = re.match(word_pat, ret['etc_subdir'])
            if m:
                ret['etc_subdir'] = m.groupdict()['id']
    except:
        pass
    return ret


def get_old_distro():
    '''
    Gets DISTRIB_ID from /etc/lsb-release
    Returns-->str
    '''
    try:
        CMD = 'cat /etc/lsb-release | head -1 | cut -d= -f2'
        ret = subprocess.check_output(CMD, shell=True).splitlines()[0]
        return ret
    except:
        return None


OLD_DISTRO_ID = get_old_distro()


def backup_and_replace(existing, new_link):
    '''
    existing-->str: path: may be symlink or file
    new_link-->str: path: Will be removed if it exists and recreated

    existing will be copied to new_link under the same dir as existing
    existing will be renamed to existing.OLD_DISTRO_ID (if possible)
        under the same dir as existing
    Returns-->boolean: whether successful
    '''
    path_base = os.path.dirname(existing)
    existing_base = os.path.basename(existing)
    new_link = os.path.join(path_base, new_link)
    new_link_dir = os.path.dirname(new_link)
    bak_existing = os.path.join(
        path_base,
        '%s.%s' % (existing_base, OLD_DISTRO_ID or 'old')
    )
    try:
        if not os.path.exists(existing):
            return False
        try:
            os.unlink(new_link)
        except:
            pass
        if not os.path.isdir(new_link_dir):
            os.makedirs(new_link_dir)
        shutil.copyfile(existing, new_link)
        if os.path.islink(existing):
            os.rename(existing, bak_existing)
        elif os.path.isfile(existing):
            shutil.copy(existing, bak_existing)
        try:
            os.unlink(existing)
        except:
            pass
        os.symlink(
            os.path.relpath(new_link, start=path_base),
            existing
        )
        return True
    except:
        return False


def update_etc_dpkg_origins_default(new_distro, f='/etc/dpkg/origins/default'):
    if new_distro:
        return backup_and_replace(f, new_distro)


def update_etc_os_release(cfg_dict, f='/etc/os-release'):
    '''
    cfg_dict-->dict: returned by get_config_values()
    Returns-->boolean: success / failure
    '''
    f_base = os.path.basename(f)
    etc_path = os.path.dirname(f)
    f = os.path.join(SCRIPT_DIR, f)
    if cfg_dict['etc_subdir']:
        etc_subdir = cfg_dict['etc_subdir']
    else:
        etc_subdir = ''
    f_target = os.path.join(etc_subdir, f_base)

    # Read and change contents of f in in-memory dict
    d = OrderedDict()
    try:
        d = OrderedDict([
            x.split('=', 1) for x in open(f, 'r').read().splitlines()
        ])
        if d['NAME'] and cfg_dict['new_distro_id']:
            old_name = d['NAME'].replace('"', '')
            d['NAME'] = cfg_dict['new_distro_id'].capitalize()
        if d['ID'] and cfg_dict['new_distro_id']:
            d['ID'] = cfg_dict['new_distro_id'].capitalize()
        if d['HOME_URL'] and cfg_dict['new_home_url']:
            d['HOME_URL'] = '"%s"' % (cfg_dict['new_home_url'],)
        if d['SUPPORT_URL'] and cfg_dict['new_support_url']:
            d['SUPPORT_URL'] = '"%s"' % (cfg_dict['new_support_url'],)
        if d['BUG_REPORT_URL'] and cfg_dict['new_bug_report_url']:
            d['BUG_REPORT_URL'] = '"%s"' % (cfg_dict['new_bug_report_url'],)

        if old_name and d['PRETTY_NAME'] and cfg_dict['new_distro_id']:
            new_pretty_name = d['PRETTY_NAME'].replace(
                old_name, cfg_dict['new_distro_id'].capitalize())
            d['PRETTY_NAME'] = new_pretty_name
    except:
        print('Error parsing %s' % (f))
        return False
    if not backup_and_replace(f, f_target):
        return False
    f_target = os.path.join(etc_path, f_target)
    if d:
        with open(f_target, 'w') as x:
            for (k, v) in d.items():
                x.write('%s=%s\n' % (k, v))
            x.flush()
    else:
        return False
    return True


def simple_update_1_file(inp_file, old_val, new_val):
    '''
    inp_file-->str: path to file to be changed
    old_val-->str: to change in inp_file (case-insensitive)
    new_val: str: new value for old_val after replacement
    Returns-->int: return code of sed command
    '''
    sed_cmd = "'s/%s/%s/gI'" % (old_val, new_val)
    CMD = "sed -i %s '%s'" % (sed_cmd, inp_file)
    return subprocess.call(CMD, shell=True) == 0


def make_rebranding_changes():
    d = get_config_values()
    # Some changes depend exactly and only on OLD_DISTRO_ID and new_distro_id
    for f in ['/etc/issue', '/etc/issue.net', '/etc/lsb-release']:
        if OLD_DISTRO_ID and d['new_distro_id']:
            if simple_update_1_file(f, OLD_DISTRO_ID, d['new_distro_id']):
                print('Updated %s' % (f,))
            else:
                print('Update failed: %s' % (f,))
        else:
            if not OLD_DISTRO_ID:
                print('Not updating %s : did not find OLD_DISTRO_ID' % (f,))
            if not d['new_distro_id']:
                print('Not updating %s : did not find new_distro_id' % (f,))

    f = '/etc/os-release'
    if update_etc_os_release(cfg_dict=d, f=f):
        print('Updated %s' % (f,))
    else:
        print('Update failed: %s' % (f,))

    if d['new_distro_id']:
        f = '/etc/dpkg/origins/default'
        if update_etc_dpkg_origins_default(d['new_distro_id'], f=f):
            print('Updated %s' % (f,))
        else:
            print('Update failed: %s' % (f,))
    else:
        print('Not updating %s : did not find new_distro_id' % (f,))


if __name__ == '__main__':
    make_rebranding_changes()
