#!/usr/bin/env python3
'''
Usage: update_kernel_config.py <PREFS_FILE> <BUILD_DIR>
                               <silent_out_file> <command_and_args>
    BUILD_DIR: Linux kernel source dir containing .config
        This directory should also contain scripts/config - called to
        modify .config

    silent_out_file: file to write output of make silentoldconfig
        will be created / overwritten

    chosen_out_file: file to write output of answer_questions()
        will be created / overwritten

    command_and_args: Command to call AFTER modifying .config
        Typically:
        answer_config_questions.py <silent_config_out> make silentoldconfig

    PREFS_FILE - containing kernel config preferences - one per line

'''
import sys
import os
import re
import subprocess
from collections import OrderedDict
import pexpect
import time
# from answer_config_questions import answer_questions


def debug(f, s):
    f.write(s + '\n')
    f.flush()


def answer_questions(cmd, out_file, chosen_out_file=None):
    c = pexpect.spawn(cmd, encoding='utf8', timeout=5)
    # print('Child process PID = %d' % (c.pid,))
    c.logfile = open(out_file, 'a+')
    if chosen_out_file:
        f = open(chosen_out_file, 'a+')
    else:
        f = sys.stdout

    pat_desc = '(?P<DESC>.*?)'
    pat_key = '\((?P<CONFIG_KEY>\S+)\)'
    pat_opts = '\[(?P<OPTS>\S+)]'
    pat_new = '\(NEW\)'
    pat = '^%s %s %s %s' % (pat_desc, pat_key, pat_opts, pat_new)

    question_patterns = [
        pexpect.EOF,
        pexpect.TIMEOUT,
        pat,
        '^\s*choice.*$',
    ]

    while not c.eof():
        ind = c.expect(question_patterns, timeout=2)
        if ind == 0:      # EOF
            break
        elif ind == 1:      # TIMEOUT
            debug(f, 'DEBUG: ----- TIMEOUT')
            c.sendline('')
            continue
        elif ind == 2:        # options to choose
            ans = ''
            if c.match:
                gd = c.match.groupdict()
                def_ans = [x for x in gd['OPTS'] if x in 'YNM']
                if def_ans:
                    def_ans = def_ans[0]
                else:
                    def_ans = 'UNKNOWN'
                if 'm' in gd['OPTS'].lower():
                    ans = 'm'
                    chosen = ans
                else:
                    chosen = def_ans
                desc = gd['DESC'].splitlines()[-1].strip('\r\n')
                debug(f, 'DESC: %s\nKEY: %s\nOPTS: %s\nANS: %s\n\n' % (
                    desc, gd['CONFIG_KEY'], gd['OPTS'], chosen
                ))
                c.sendline(ans)
            else:
                debug(
                    f,
                    'DEBUG: unexpected error: index == 1, but c.match is None')
        elif ind == 3:          # choice
            # debug(f, 'DEBUG: CHOICE: ----- ', c.after)
            debug(f, '--- CHOICE --- %s\n' % (c.after.splitlines()[-1],))
            c.sendline('')

    debug(f, '\nDEBUG: ----- COMPLETED\n')

    ret = c.isalive()
    if ret is True:
        time.sleep(1)
        ret = c.isalive()
    return(ret)


def show_help():
    p = os.path.basename(sys.argv[0])
    a1 = 'BUILD_DIR'
    a2 = 'silent_out_file'
    a3 = 'chosen_out_file'
    a4 = 'command_and_args'
    a5 = 'PREFS_FILE'
    print('Usage: %s <%s> <%s> <%s> <%s> <%s>' % (p, a1, a2, a3, a4, a5))
    print('')
    print('  %s: Linux kernel source dir containing .config' % (a1,))
    print('    This directory should also contain scripts/config')
    print('      - called to modify .config')
    print('')
    print('  %s: file to write output of make silentoldconfig' % (a2,))
    print('    will be created / overwritten')
    print('')
    print('  %s: file to write output of answer_questions' % (a3,))
    print('    will be created / overwritten')
    print('')
    print('  %s: Command to call AFTER modifying .config' % (a4,))
    print('    Typically: make silentoldconfig')
    print('')
    print('  %s: file with config preferences - one per line' % (a5,))


def get_prefs(f):
    '''
    f-->file path
    Returns-->dict:
        Key-->Config key
        Value-->config value: one of ['y', 'n', 'm']
    '''
    ret = OrderedDict()
    pat = '^\s*(?P<KEY>\S+)\s*=\s*(?P<VAL>\S+)'
    try:
        for l in open(f, 'r').read().splitlines():
            m = re.search(pat, l)
            if m:
                gd = m.groupdict()
                k = gd['KEY']
                if k.startswith('#'):
                    continue
                if k.startswith('CONFIG_'):
                    k = k[7:]
                ret[k] = gd['VAL']
    except:
        pass
    return ret


def non_matching_keys(prefs_dict, sc):
    '''
    prefs_dict-->dict: returned by get_prefs()
    sc-->str: path to scripts/config under Linux source
    Returns-->dict: subset of prefs_dict
    '''
    ret = OrderedDict()
    for (k, v) in prefs_dict.items():
        try:
            CMD = '%s --state %s' % (sc, k)
            x = subprocess.check_output(CMD, shell=True)
            x = x.strip().decode('utf8')
            v = v.strip()
            if x != v:
                ret[k] = v
        except:
            continue
    return ret


def update_keys(prefs_dict, sc):
    '''
    prefs_dict-->dict: returned by get_prefs()
    sc-->str: path to scripts/config under Linux source
    Returns-->Nothing
    '''
    for (k, v) in prefs_dict.items():
        try:
            CMD = '%s --set-val %s %s' % (sc, k, v)
            subprocess.call(CMD, shell=True)
        except:
            continue


if __name__ == '__main__':
    if len(sys.argv) == 2 and (sys.argv[1] == '-h' or sys.argv[1] == '--help'):
        show_help()
        exit(0)

    if len(sys.argv) < 6:
        show_help()
        exit(1)

    BUILD_DIR = sys.argv[1]
    SILENT_OUT_FILE = sys.argv[2]
    CHOSEN_OUT_FILE = sys.argv[3]
    CMD_AND_ARGS = sys.argv[4]
    PREFS_FILE = sys.argv[5]

    if not os.path.isdir(BUILD_DIR):
        print('Not a directory: %s' % (BUILD_DIR,))
        exit(1)
    KERNEL_CONFIG = os.path.join(BUILD_DIR, '.config')
    if not os.path.exists(KERNEL_CONFIG):
        print('.config not found: %s' % (KERNEL_CONFIG,))
        exit(1)
    SCRIPTS_CONFIG = os.path.join(BUILD_DIR, 'scripts/config')
    if not os.path.exists(SCRIPTS_CONFIG):
        print('scripts/config does not exist: %s' % (SCRIPTS_CONFIG,))
        exit(1)

    print('Using kernel config prefs from: %s' % (PREFS_FILE,))
    print('Using kernel build dir: %s' % (BUILD_DIR,))
    print('Using kernel config make command: %s' % (CMD_AND_ARGS,))
    print('Kernel config make output in %s' % (SILENT_OUT_FILE,))
    print('Kernel config make choices made in %s' % (CHOSEN_OUT_FILE,))

    # IMPORTANT - move to Linux kernel source dir
    os.chdir(BUILD_DIR)

    # Run make silentoldconfig once - always required
    ret = answer_questions(
        CMD_AND_ARGS, SILENT_OUT_FILE, chosen_out_file=CHOSEN_OUT_FILE)
    if ret != 0:
        print('Command failed: %s' % (CMD_AND_ARGS,))
        exit(ret)

    if not os.path.exists(PREFS_FILE):
        print('PREFS_FILE does not exist: %s' % (PREFS_FILE,))
        exit(0)

    prefs_dict = get_prefs(PREFS_FILE)
    if not prefs_dict:
        print('No kernel config prefs found')
        exit(0)

    to_change = non_matching_keys(prefs_dict, SCRIPTS_CONFIG)
    if not to_change:
        print('All your kernel config prefs are already set')
        exit(0)
    print('Setting following kernel config prefs')
    for (k, v) in to_change.items():
        print('\t%s = %s' % (k, v))

    # Update keys in config
    update_keys(to_change, SCRIPTS_CONFIG)
    # Run make silentoldconfig AGAIN - some new modules may have been enabled
    ret = answer_questions(
        CMD_AND_ARGS, SILENT_OUT_FILE, chosen_out_file=CHOSEN_OUT_FILE)
    if ret != 0:
        print('Command failed: %s' % (CMD_AND_ARGS,))
        exit(ret)

    still_wrong = non_matching_keys(to_change, SCRIPTS_CONFIG)
    if still_wrong:
        print('Following kernel config prefs were not set:')
        for (k, v) in still_wrong.items():
            print('\t%s = |%s| (current: |%s|)' % (k, v, to_change.get(k)))
    else:
        print('All your kernel config prefs have been set')
