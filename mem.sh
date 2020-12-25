#!/bin/sh

PSS=`cat /proc/[1-9]*/smaps 2>/dev/null | grep ^Pss |awk '{sum += $2};END {print sum/1024}'`

PageTable=`grep PageTables /proc/meminfo | awk '{print $2}'`
PageTable=`echo "scale=4;$PageTable/1024"|bc -l`

SlabInfo=`cat /proc/slabinfo |awk 'BEGIN{sum=0;}{sum=sum+$3*$4;}END{print sum/1024/1024}' `

HugePages_Total=`grep HugePages_Total /proc/meminfo |awk '{print $2}'`
HugePages_size=`grep Hugepagesize /proc/meminfo |awk '{print $2}'`
HugePages=`echo "scale=4;$HugePages_Total*$HugePages_size/1024"|bc -l`

echo PSS:$PSS"MB"
echo PageTable:$PageTable"MB"
echo SlabInfo:$SlabInfo"MB"
echo HugePages:$HugePages"MB"
printf "PSS+PageTable+SlabInfo+HugePages=%sMB\n" `echo $PSS + $PageTable + $SlabInfo + $HugePages|bc`

free -m
