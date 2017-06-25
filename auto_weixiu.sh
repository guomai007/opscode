#!/bin/sh
stamp=`date +"%Y-%m-%d"`
tt=`date +"%Y-%m-%d-%H-%M"`
record_log="/home/admin/maintain/weixiu-$stamp"
localdisk_cluster='AY117B AY119B AY11N AY122B AY127B AY12C AY66H AY66I AY66J AY72E AY73E AY73G AY73H AY81E'
#trap "rm -f /tmp/host_weixiu.txt && exit 100" 2 3 15

idc_confirm() {
if [ $# -ne 1 ];then echo '$stamp ERROR - exception,argument not match!' ;  exit 255 ;fi
orderId=$1
prefix='http://idc.alibaba-inc.com/repairapi!confirm.jspa?'
body="userName=bin.guob&orderId=$orderId&remark=null"
ret=`curl -m 10 --connect-timeout 5 -s "$prefix$body"`
if [ "$ret" = "SUCCESS" ];then
return 0
else
return 1
fi
}

idc_query_count() {
if [ $# -ne 1 ];then echo '$stamp ERROR - exception,argument not match!' ;  exit 255 ;fi
nodegroup=$1
prefix='http://idc.alibaba-inc.com/repairapi!search.jspa?'
body="isCount=true&nodegroup=$nodegroup&states=3,k,l,挂"
ret=`curl -m 10 --connect-timeout 5 -s "$prefix$body"`
if [ "$ret" = '0' ];then
return 0
else
return 1
fi
}

idc_query_host() {
if [ $# -ne 1 ];then echo '$stamp ERROR - exception,argument not match!' ;  exit 255 ;fi
ip=$1
prefix='http://idc.alibaba-inc.com/repairapi!search.jspa?'
body="isCount=false&ip=$ip&states=3,k,l,挂"
ret=`curl -m 10 --connect-timeout 5 -s "$prefix$body"`
if echo "$ret"|grep orderId >/dev/null;then
return 1
else
return 0
fi
}


if [ -s "/tmp/host_weixiu-$tt" ];then echo "file /tmp/host_weixiu-$tt exist..." ; exit 100 ;fi
### Get ALL LocalDisk NC IDC_Maintain Host ###
go2ecsopsdb -Ne "select master_role,ip,idc_status,reason,order_id  from apsara_master_idc where idc_status='PE待确认' and cluster_name like 'AY%';"  > /tmp/host_weixiu-$tt
sudo rm -f /tmp/nc-weixiu.txt
for cu in $localdisk_cluster;do
   lowercase=`echo $cu|tr '[A-Z]' '[a-z]'`
   nodegroup="aliyun_""$lowercase""_server"
   prefix='http://idc.alibaba-inc.com/repairapi!search.jspa?'
   body="isCount=false&nodegroup=$nodegroup&states=2&types=1&format=shell"
   curl -m 10 --connect-timeout 5 -s "$prefix$body" |sed 's/;;/\n/g' |grep 'orderId::' >> /tmp/nc-weixiu.txt
done

while read line ;do
   orderid=`echo "$line" |awk -F'\\\|\\\|' '{print $1}'|awk -F:: '{print $2}'`
   ip=`echo "$line" |awk -F'\\\|\\\|' '{print $3}'|awk -F:: '{print $2}'`
   nodegroup=`echo "$line" |awk -F'\\\|\\\|' '{print $11}'|awk -F:: '{print $2}'`
   state=`echo "$line" |awk -F'\\\|\\\|' '{print $16}'|awk -F:: '{print $2}'`
   type=`echo "$line" |awk -F'\\\|\\\|' '{print $17}'|awk -F:: '{print $2}'`
   role=`echo $nodegroup|sed  's/aliyun_\(ay.*\)_server/\1_nc/'`
   echo -e "$role\t$ip\t$state\t$type\t$orderid" >> /tmp/host_weixiu-$tt
done < /tmp/nc-weixiu.txt


### All Master|AG|NC IDC Maintain ###
while read newline;do
line=`echo "$newline" |perl -pe 's/\s+/  /g'`
if echo $line|grep _pg_ >/dev/null ;then
   role=`echo $line|awk '{print $1}'| awk -F_ '{print $3}'`
   cuname=`echo $line|awk '{print $1}'|awk -F_ '{print $1}'`
   nodegroup="aliyun_""$cuname""_pangumaster"
   type=`echo $line|awk '{print $4}'`
   orderid=`echo $line|awk '{print $NF}'`
   if [ "$type" = '硬盘故障' ];then
      if [ "$role" != 'primary' ];then
         if idc_query_count $nodegroup;then
            if idc_confirm $orderid;then
               echo -ne "$line||Result:success_auto_confirm\n" >> $record_log
            else
               echo -ne "$line||Result:failed_auto_confirm\n" >> $record_log
            fi
         else
            echo -ne "$line||Result:wait_confirm\n" >> $record_log
         fi
      else
         echo -ne "$line||Result:to_be_manual_confirm\n" >> $record_log
      fi
   else
      echo -ne "$line||Result:wait_confirm\n" >> $record_log
   fi
elif echo $line|grep _nuwa_ > /dev/null ;then
   cuname=`echo $line|awk '{print $1}'|awk -F_ '{print $1}'`
   nodegroup="aliyun_""$cuname""_zk"
   type=`echo $line|awk '{print $4}'`
   orderid=`echo $line|awk '{print $NF}'`
   if [ "$type" = '硬盘故障' ];then
      if idc_query_count $nodegroup;then
         if idc_confirm $orderid;then
            echo -ne "$line||Result:success_auto_confirm\n" >> $record_log
         else
            echo -ne "$line||Result:failed_auto_confirm\n" >> $record_log
         fi 
      else
         echo -ne "$line||Result:wait_confirm\n" >> $record_log
      fi
   else
      echo -ne "$line||Result:wait_confirm\n" >> $record_log
   fi
elif echo $line|grep _fuxi_ > /dev/null ;then
   cuname=`echo $line|awk '{print $1}'|awk -F_ '{print $1}'`
   nodegroup="aliyun_""$cuname""_fuximaster"
   type=`echo $line|awk '{print $4}'`
   orderid=`echo $line|awk '{print $NF}'`
   if [ "$type" = '硬盘故障' ];then
      if idc_query_count $nodegroup;then
         if idc_confirm $orderid;then
            echo -ne "$line||Result:success_auto_confirm\n" >> $record_log
         else
            echo -ne "$line||Result:failed_auto_confirm\n" >> $record_log
         fi
      else
         echo -ne "$line||Result:wait_confirm\n" >> $record_log
      fi
   else
      echo -ne "$line||Result:wait_confirm\n" >> $record_log
   fi
else 
   ip=`echo $line|awk '{print $2}'`
   type=`echo $line|awk '{print $4}'`
   orderid=`echo $line|awk '{print $NF}'`
   if [ "$type" = '硬盘故障' ];then
      if idc_query_host $ip ;then
         if idc_confirm $orderid;then
            echo -ne "$line||Result:success_auto_confirm\n" >> $record_log
         else
            echo -ne "$line||Result:failed_auto_confirm\n" >> $record_log
         fi
      else
         echo -ne "$line||Result:wait_confirm\n" >> $record_log
      fi
   else
      echo -ne "$line||Result:wait_confirm\n" >> $record_log
   fi
fi

done < /tmp/host_weixiu-$tt

