#!/bin/sh
###sailuo@taobao.com 2014-10-28
log="/tmp/removeDdisk.log"
echo "----"`date "+%Y-%m-%d %H:%M:%S"`"----" >>$log

lsscsi|grep ATA >/dev/shm/lsscsi.txt
echo ">>>[lsscsi]:" >>$log
cat /dev/shm/lsscsi.txt >>$log

lsiutil > /dev/shm/lsiutil.txt 2>&1 <<EOF
1
16
0
0
EOF
echo ">>>[lsiutil]:" >>$log
cat /dev/shm/lsiutil.txt >>$log

Ddisks1=`ps x|grep "jbd2/sd"|grep " D "|awk '{print $NF}'|cut -c7-9|sort -u|grep -v sda`
echo "" >>$log
echo ">>>[Ddisks1]:"$Ddisks1 >>$log
#1.Do umount
for s in $Ddisks1;do
  for s1 in `df|grep /dev/$s|awk '{print $NF}'`;do
  	echo ">>>[exec]:umount -l "${s1} >>$log
  	umount -l $s1
  done
done

sleep 10

Ddisks2=`ps x|grep "jbd2/sd"|grep " D "|awk '{print $NF}'|cut -c7-9|sort -u|grep -v sda`
echo ">>>[Ddisks2]:"$Ddisks2 >>$log
#2.Do delete Ddisk2
for s in $Ddisks2;do
  	if [ -f /sys/block/${s}/device/delete ];then
  	   echo ">>>[exec]:echo 1 > /sys/block/"${s}"/device/delete" >>$log
  	   echo 1 > /sys/block/${s}/device/delete
  	else
  		 echo ">>>[exec_cancel]:/sys/block/"${s}"/device/delete not exit!" >>$log
  	fi
done

sleep 10

Ddisks3=`ps x|grep "jbd2/sd"|grep " D "|awk '{print $NF}'|cut -c7-9|sort -u|grep -v sda`
echo ">>>[Ddisks3]:"$Ddisks3 >>$log
#3.Do disable scsi_port
for s in $Ddisks3;do
		#only do [0:0:N:0] scsi.
    scsi_PhyNum=`grep /dev/${s} /dev/shm/lsscsi.txt|awk '{print $1}'|grep "\[0:0:"|awk -F: '{print $3}'`
    if [ -z "$scsi_PhyNum" ];then
    	echo ">>>[exec_cancel]:"/dev/${s}_`grep /dev/${s} /dev/shm/lsscsi.txt|awk '{print $1}'` is not start with "0:0:",no handle! >>$log
    	continue
    fi
    scsi_Handle=`grep "SATA Target" /dev/shm/lsiutil.txt |awk '{print $4,$6}'|grep ^${scsi_PhyNum}|awk '{print $NF}'`
    if [ -z "$scsi_Handle" ];then
    	echo ">>>[exec_cancel]:"SCSI_Handle_PhyNum $scsi_Handle $scsi_PhyNum is not exit,no handle! >>$log
    	continue
    fi
    echo ">>>[exec]:disable SCSI_Handel_PhyNum "$scsi_Handle $scsi_PhyNum >>$log
lsiutil > /dev/shm/lsiutil_disableScsi.txt 2>&1 <<EOF
1
80
$scsi_Handle
$scsi_PhyNum
0
0
EOF
		cat /dev/shm/lsiutil_disableScsi.txt >>$log
done
echo "" >>$log
