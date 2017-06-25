#!/bin/sh

stime=`date +%s`
starttime=`date -d @$stime +"%Y-%m-%d-%H-%M-%S"`
mkdir "io_hang_record_$starttime"

trap "get_slow_io" 2 3 15

get_slow_io(){
echo 'exec here...wait'
etime=`date +%s`
ntime=$stime
rm -f ~/io_hang_record_$starttime/slow_io_stats.txt  >/dev/null 2>&1

while true;do
if [ $ntime -le $etime ];then
   logtime2=`date -d @$ntime +"%Y-%m-%d %H:%M:"`
   echo "|$stime|$ntime|$etime|$logtime2|"
   pssh -t5 -i -h .config_cluster/iplist_vm  "find /var/log/tdc -mmin -60 -a -name 'tdc.*LOG' |xargs tail -n100 |grep  'latency=.*ms' " |awk '{print $1,$2,$23}'|grep 'latency=.*ms' |grep "$logtime2" >> ~/io_hang_record_$starttime/slow_io_stats.txt
   ntime=`echo "$ntime+60"|bc`
else
   break
fi
done

exit 100
}

while true;do
logtime=`date +"%H:%M:%S"`
mkdir -p io_hang_record_$starttime/$logtime
pssh -p100 -t5 -i -o ~/io_hang_record_$starttime/$logtime  -h .config_cluster/iplist_vm "/usr/alisys/dragoon/libexec/alimonitor/check_kvm_io_hang "
sleep 1
done

