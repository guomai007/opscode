#!/bin/sh

if [ ! $# -ge 1 ];then
echo 'Usage:$0 ClusterName'
echo 'Usage:$0 ay73k'
exit 2
fi

cuname=`echo $1 |tr '[A-Z]' '[a-z]'`
armory -eg aliyun_${cuname}_server --fields=nodename,dns_ip -l > /tmp/$cuname 2>&1  
if grep 'no result' /tmp/$cuname >/dev/null;then
   echo "Error - armory group:aliyun_${cuname}_server isnot Exist"
   exit 100
fi

awk -F, '{print $2}' /tmp/$cuname > /tmp/${cuname}_iplist
time=`date +"%Y-%m-%d %H:%M:%S"`
ssh_err_nc=`pssh -t5 -h /tmp/${cuname}_iplist "uptime " |grep FAILURE | egrep -o '1[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+'`
rm -f /tmp/${cuname}_ping_ok /tmp/${cuname}_ping_fail
for i in $ssh_err_nc ;do
nohup ping -c5 -W1 $i >/dev/null  && echo $i >> /tmp/${cuname}_ping_ok &
nohup ping -c5 -W1 $i >/dev/null  || echo $i >> /tmp/${cuname}_ping_fail &
done

sleep 6
echo "$time >>" |tee -a /tmp/${cuname}_log
echo "ssh Error but ping is OK::" |tee -a /tmp/${cuname}_log
grep -f /tmp/${cuname}_ping_ok /tmp/$cuname 2>/dev/null|sort -t, -k1 |tee -a /tmp/${cuname}_log
echo ''
echo "ssh Error and ping failure::" |tee -a /tmp/${cuname}_log
grep -f /tmp/${cuname}_ping_fail /tmp/$cuname 2>/dev/null|sort -t, -k1|tee -a /tmp/${cuname}_log
echo '' >> /tmp/${cuname}_log
