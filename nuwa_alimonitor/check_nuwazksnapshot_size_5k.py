#!/usr/ali/bin/python2.5
# -*- coding: UTF-8 -*-

from __future__ import with_statement
import sys
import os
import os.path
import re

ZOO_CFG = '/apsara/nuwa/conf/zoo.cfg'
SNAPSHOT_PREFIX = 'snapshot.'
MAX_THRESHOLD = 100

def printCritical(info):
    print 'Critical - %s' % info

def printWarning(info):
    print 'Warning - %s' % info

def printOK(info):
    print 'OK - %s' % info

def InvalidParameter(Exception):
    pass

def getZxidFromFilename(filename, prefix):
    if not filename.startswith(prefix):
        raise InvalidParameter('"%s" must start with "%s"' % (filename, prefix))
    else:
        return int(filename[len(prefix):], 16)

if __name__ == '__main__':
    if not os.path.exists(ZOO_CFG) or not os.path.isfile(ZOO_CFG):
        printCritical('can not find file: %s' % ZOO_CFG)
        sys.exit(1)

    if not sys.argv[1].isdigit() or (int(sys.argv[1]) > MAX_THRESHOLD):
        printCritical('invalid parameter. Usage: %s threshold. And threshold(MB) should be no more than %d'
                % (sys.argv[0], MAX_THRESHOLD))
        sys.exit(1)
    else:
        snapshot_size_shreshold = int(sys.argv[1])  

    with open(ZOO_CFG) as f:
        content = f.read()

    pattern = re.compile('dataDir=(.*)$', re.MULTILINE)
    m = pattern.search(content)
    if not m:
        printCritical('dataDir is configured incorrectly in %s' % ZOO_CFG)
        sys.exit(1)

    disk = m.group(1).strip()
    snapshot_dir = os.path.join(disk, 'version-2')
    if not os.path.exists(snapshot_dir) or not os.path.isdir(snapshot_dir):
        printCritical('"%s" is not a valid snapshot directory' % snapshot_dir)
        sys.exit(1)

    snapshots = [snapshot for snapshot in os.listdir(snapshot_dir) if snapshot.startswith(SNAPSHOT_PREFIX)]
    if not snapshots:
        printWarning('not find snapshot!')
        sys.exit(1)

    newest_snapshot = max(snapshots, key=lambda x: getZxidFromFilename(x, SNAPSHOT_PREFIX))
    snapshot_size = os.stat(os.path.join(snapshot_dir, newest_snapshot)).st_size
    if snapshot_size > (snapshot_size_shreshold * 1024 * 1024): 
        printCritical('size of snapshot is %.3f(MB), larger than threshold %d(MB)' 
                % (snapshot_size / (1024.0 * 1024), snapshot_size_shreshold))
    else:
        printOK('snapshot size is OK')
