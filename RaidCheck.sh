#!/bin/sh
if [ ! $# -ge 1 ];then
echo 'Usage:$0 Host/IP'
exit 2
fi

for i in $@;do
echo ''
    echo "================================= $i ===================================="
echo ''
model=`ssh $i "sudo /usr/sbin/dmidecode |grep Prod|grep ProLiant -o"`
if [ "$model" = 'ProLiant' ];then
    echo '--------------------------------- RaidGroup State ------------------------------------'
    ssh $i "sudo hpacucli ctrl slot=0 logicaldrive all show status"
    echo '--------------------------------- Physical Disk State ------------------------------------'
    ssh $i "sudo hpacucli ctrl slot=0 physicaldrive all show status"
else
    echo '--------------------------------- RaidGroup State ------------------------------------'
    ssh $i "sudo MegaCli64 -LDInfo -LALL -aAll |grep State -B5"
    echo '--------------------------------- Physical Disk State ------------------------------------'
    ssh $i "sudo MegaCli64 -PDList -aAll|grep state "
fi

done
