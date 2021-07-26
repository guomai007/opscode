#!/home/tops/bin/python

'''Check coredump file.

Usage: python check_ecs_coredump.py <n_seconds_ago>
'''

import os
import re
import sys
import glob
import time
import signal

try:
    import simplejson as json
except:
    import json

def get_core_pattern():
    '''Get core pattern from sysctl configure.'''
    fp = open('/proc/sys/kernel/core_pattern')
    core_pattern = fp.read()
    fp.close()

    return core_pattern.strip()

def get_coredump_dir(core_pattern):
    '''Get coredump base directory.'''
    return os.path.basename(core_pattern)

def get_coredump_glob(core_pattern):
    '''Get coredump file glob pattern.'''
    return re.sub(r'%[spughte]', '*', core_pattern)

def get_coredump_regexp(core_pattern):
    '''Get coredump file regular expression pattern.'''
    core_pattern = core_pattern.replace('%p', '(?P<pid>\d+)')
    core_pattern = core_pattern.replace('%u', '(?P<uid>\d+)')
    core_pattern = core_pattern.replace('%g', '(?P<gid>\d+)')
    core_pattern = core_pattern.replace('%t', '(?P<timestamp>\d+)')
    core_pattern = core_pattern.replace('%h', '(?P<hostname>\w*)')
    core_pattern = core_pattern.replace('%e', '(?P<execname>\w+)')
    core_pattern = core_pattern.replace('%s', '(?P<signum>\d+)')

    return core_pattern

def get_signal_dict():
    '''Get the dictionary from signal number to its name.'''
    return dict((k, v) for v, k in signal.__dict__.iteritems() if v.startswith('SIG'))

def walk_coredumps(from_timestamp = None):
    '''Check all coredump files generated.'''
    core_pattern = get_core_pattern()
    signal_dic = get_signal_dict()

    coredump_glob = get_coredump_glob(core_pattern)

    # Create coredump regexp pattern
    coredump_regexp = get_coredump_regexp(core_pattern)
    coredump_regexp = re.compile(coredump_regexp)

    coredump_list = glob.glob(coredump_glob)
    msg = []

    for coredump in coredump_list:
        m = coredump_regexp.search(coredump)

        if m is None: continue

        # Get the coredump information from filename
        coredump_info = m.groupdict()

        for key, value in coredump_info.items():
            # Convert string to integer
            if value.isdigit():
                coredump_info[key] = int(value)

        timestamp = coredump_info.get('timestamp', 0)

        # Skip too old coredump files based on the timestamp
        if from_timestamp is not None and timestamp <= from_timestamp:
            continue

        # Add local time
        if timestamp != 0:
            localtime = time.localtime(timestamp)
            coredump_info['localtime'] = time.strftime("%Y-%m-%d %H:%M:%S", localtime)

        # Add signal name
        if 'signum' in coredump_info:
            coredump_info['signame'] = signal_dic[coredump_info['signum']]

        msg.append(coredump_info)

    # No coredump files found, change the MSG type to dict
    if not msg:
        msg = [{'execname': ''}]

    print json.dumps({'collection_flag': 0, 'MSG': msg})

def main():
    '''The main entry.'''
    try:
        # from timestamp: sys.argv[1] seconds ago
        from_timestamp = int(time.time()) - int(sys.argv[1])
    except (IndexError, ValueError):
        from_timestamp = None

    walk_coredumps(from_timestamp)

if __name__ == '__main__':
    main()