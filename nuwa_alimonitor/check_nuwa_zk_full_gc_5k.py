#!/usr/ali/bin/python2.5
# -*- coding: UTF-8 -*-

from __future__ import with_statement
import sys
import os
import os.path
import time
import re

GC_LOG = '/apsara/nuwa/log/gc.log'
TMP_FILE = '/tmp/nuwa/check_zk_full_gc_gc.log'

if __name__ == '__main__':
    if not os.path.exists(GC_LOG) or not os.path.isfile(GC_LOG):
        print 'Critical - can not find file: %s' % GC_LOG
        sys.exit(1)

    if os.path.exists(TMP_FILE) and os.path.isfile(TMP_FILE):
        isWarning = False
        with open(TMP_FILE) as f:
            last_delta_time = f.readline()
    else:
        isWarning = True
        last_delta_time = '0'
        try:
            os.mkdir(os.path.dirname(TMP_FILE))
        except:
            pass
        with open(TMP_FILE, 'w') as f:
            f.write(last_delta_time)

    last_delta_time = float(last_delta_time)
    with open(GC_LOG) as f:
        lines = f.readlines()
    pattern = re.compile('^.*?: (.*?): (.*?)$')
    logs = [pattern.match(x) for x in lines]
    logs = [(float(x.group(1)), x.group(2)) for x in logs if x]
    logs = [(x, y) for x, y in logs if x > last_delta_time]
    try:
        log_delta_time = max(x for x, _ in logs)
    except ValueError:
        log_delta_time = last_delta_time
    isFullGC = any(x for _, x in logs if x.startswith('[Full GC'))

    with open(TMP_FILE, 'w') as f:
        f.write('%.6f' % log_delta_time)

    if isFullGC:
        if isWarning:
            print 'Critical - full gc happened! create new temp file for check zookeeper full gc.'
        else:
            print 'Critical - full gc happened!'
    else:
        if isWarning:
            print 'Warning - create new temp file for check zookeeper full gc; no full gc happen.'
        else:
            print 'OK - no full gc happen.'
