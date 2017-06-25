#!/bin/sh
echo $$ > /tmp/iobench.pid
while true
do
if [ -f /tmp/iobench.pid ];then
   if pidof fio >/dev/null ; then
      exit 200
   else
      fio -filename=/test11 -direct=1 -iodepth 64  -thread -rw=randrw -rwmixread=70 -ioengine=libaio -bs=16k -size=10G -numjobs=1 -runtime=1000 -group_reporting -name=mytest  |tee /tmp/iobench.log
   fi
else
   exit 100
fi
done
