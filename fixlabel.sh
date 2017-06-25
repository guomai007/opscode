#!/bin/sh
if [ ! -f /etc/fstab.bak ];then
   sudo cp /etc/fstab /etc/fstab.bak
fi

device1=`grep '/apsarapangu ' /etc/fstab| grep -v ^# |awk '{print $1}'` 
device2=`grep '/apsarapangu/backup ' /etc/fstab|grep -v ^# |awk '{print $1}'` 
if [ -b "$device1" ];then
   sudo e2label $device1 DISK1
   sudo sed -i "s#$device1#LABEL=DISK1#" /etc/fstab
fi
if [ -b "$device2" ];then
   sudo e2label $device2 DISK2
   sudo sed -i "s#$device2#LABEL=DISK2#" /etc/fstab
fi
