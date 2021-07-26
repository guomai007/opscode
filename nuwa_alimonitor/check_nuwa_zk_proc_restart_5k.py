#!/usr/ali/bin/python2.5
# -*- coding: UTF-8 -*-

from __future__ import with_statement
import sys
import os
import os.path
import datetime
import re

DATETIME_FORMAT = '%Y-%m-%d %H:%M:%S'
FIRST_BEGIN_TIME = '1970-01-01 00:00:00,000'
ZOODIRECTOR_LOG_DIR = '/apsara/nuwa/log'
JAVA_BIN = '/apsara/nuwa/java4zk'
ZOODIRECTOR_LOG_PREFIX = 'zoodirector.log.'
TMP_FILE = '/tmp/nuwa/check_zk_proc_restart_zoodirector.log'
ZOODIRECTOR_LOG_OLD = 'zoodirector.log'

def getCurrentLocaltime():
    return datetime.datetime.now()

def convertDatetimeObject2Str(datetime_object):
    dt = datetime_object.strftime(DATETIME_FORMAT)
    return '%s,%03d' %(dt, datetime_object.microsecond/1000)

def convertStr2DatetimeObject(str_datetime):
    dt = datetime.datetime.strptime(str_datetime[:-4], DATETIME_FORMAT)
    dt = dt.replace(microsecond=int(str_datetime[-3:])*1000)
    return dt

if __name__ == '__main__':
    try:
        zoodirector_log = max(x for x in os.listdir(ZOODIRECTOR_LOG_DIR) if x.startswith(ZOODIRECTOR_LOG_PREFIX))
    except ValueError:
        zoodirector_log = ''
    
    if not zoodirector_log and os.path.exists(os.path.join(ZOODIRECTOR_LOG_DIR, ZOODIRECTOR_LOG_OLD)) \
            and os.path.isfile(os.path.join(ZOODIRECTOR_LOG_DIR, ZOODIRECTOR_LOG_OLD)):
        zoodirector_log = ZOODIRECTOR_LOG_OLD

    if not zoodirector_log:
        print 'Critical - can not find any zoodirector log in %s' % ZOODIRECTOR_LOG_DIR
        sys.exit(1)

    if os.path.exists(TMP_FILE) and os.path.isfile(TMP_FILE):
        isWarning = False
        with open(TMP_FILE) as f:
            last_check_time = convertStr2DatetimeObject(f.readline())
    else:
        isWarning = True
        last_check_time = convertStr2DatetimeObject(FIRST_BEGIN_TIME)
        try:
            os.mkdir(os.path.dirname(TMP_FILE))
        except:
            pass
        with open(TMP_FILE, 'w') as f:
            f.write(convertDatetimeObject2Str(last_check_time))

    cur_check_time = getCurrentLocaltime()

    pattern = re.compile('^(.*?) WARNING start \'%s' % (JAVA_BIN,))
    with open(os.path.join(ZOODIRECTOR_LOG_DIR, zoodirector_log)) as f:
        logs = f.readlines()
    logs = [pattern.match(x) for x in logs ]
    logmatches = [convertStr2DatetimeObject(x.group(1)) for x in logs if x]
    isRestarted = any(x for x in logmatches if x > last_check_time and x <= cur_check_time)

    with open(TMP_FILE, 'w') as f:
        f.write(convertDatetimeObject2Str(cur_check_time))

    if isRestarted:
        if isWarning:
            print 'Critical - zookeeper process restarted! create new temp file for check zookeeper process restart.'
        else:
            print 'Critical - zookeeper process restarted!'
    else:
        if isWarning:
            print 'Warning - create new temp file for check zookeeper process restart; zookeeper process is ok.'
        else:
            print 'OK - zookeeper process is ok.'
