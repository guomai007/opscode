#!/bin/sh
###sailuo@taobao.com 2014-10-28
###bin.guob update 2016-04-14

if [ ! $# -ge 1 ];then
echo "Usage:$0 SlotNum|sdb"
echo "Example:$0 Slot2 Slot3"
echo "Example:$0 sdb"
exit 2
fi
bad_disks=$@
log="/tmp/kick_bad_disk.log"
echo "StartTime:`date "+%Y-%m-%d %H:%M:%S"`" >>$log
echo ">>>[BAD_DISKS]:"$bad_disks >>$log

lsscsi|grep ATA >/dev/shm/lsscsi.txt
sudo lsiutil > /dev/shm/lsiutil.txt 2>&1 <<EOF
1
16
0
0
EOF

#1.Do umount First
for s in $bad_disks;do
   if echo $s|grep sd[b-z] >/dev/null ; then
      device="/dev/$s"
   elif echo $s|grep [Ss]lot[^0] >/dev/null ; then
      slotnum=`echo $s |sed 's/[Ss]lot//'`
      device=`cat /dev/shm/lsscsi.txt |grep "^\[0:0:${slotnum}:0\]" |awk '{print $NF}'`
   else
      echo "invalid parameter:$s"
      exit 100
   fi
sudo umount -l "${device}1"  >/dev/null 2>&1
if [ $? -eq 0 ];then
   echo ">>>[exec]:SUCCESS umount -l ${device}1" >>$log
else
   echo ">>>[exec]:FAIL umount -l ${device}1" >>$log
fi

done

#2.Do disable scsi_port
for s in $bad_disks ;do
   if echo $s|grep sd[b-z] >/dev/null ; then
      scsi_PhyNum=`cat /dev/shm/lsscsi.txt |grep "/dev/$s" | awk '{print $1}'|awk -F: '{print $3}'`
   elif echo $s|grep [Ss]lot[^0] >/dev/null ; then
      scsi_PhyNum=`echo $s |sed 's/[Ss]lot//'`
   else
      echo "invalid parameter:$s"
      exit 100
   fi
    #do kick bad disk just for [0:0:N:0] scsi controller
    if [ -z "$scsi_PhyNum" ];then
    	echo ">>>[exec_cancel]:Device:${s} is not Exist!" >>$log
    	continue
    fi
    scsi_Handle=`grep "SATA Target" /dev/shm/lsiutil.txt |awk '{print $4,$5}'|grep ^${scsi_PhyNum}|awk '{print $NF}'`
    if [ -z "$scsi_Handle" ];then
    	echo ">>>[exec_cancel]:"SCSI_Handle_PhyNum [$scsi_Handle] [$scsi_PhyNum] is not Exist,no handle! >>$log
    	continue
    fi

sudo lsiutil > /dev/shm/lsiutil_disableScsi.txt 2>&1 <<EOF
1
80
$scsi_Handle
0
0
EOF
sleep 8
if lsscsi |grep "\[0:0:${scsi_PhyNum}:0\]" >/dev/null;then
   echo "Kick Disk $s Fail"
   echo ">>>[exec]:FAIL disable SCSI_Handel_PhyNum [$scsi_Handle] [$scsi_PhyNum]" >>$log
else
   echo "Kick Disk $s OK"
   echo ">>>[exec]:SUCCESS disable SCSI_Handel_PhyNum [$scsi_Handle] [$scsi_PhyNum]" >>$log
fi
done

echo "" >>$log
