#!/bin/sh
# 针对udp大包（大于1500字节）的收发连通性测试，配合抓包来定位
# 此脚本所在主机为源主机，target变量为目标主机，抓包在两端都运行

echo 'test now'
target='139.9.228.126'
while true;do
    date=$(date +"%Y-%m-%d-%H:%M:%S")
    ssh $target "killall -9 nc"
    ssh $target "nohup nc -u -l 3891 >/root/udp_test/$date.txt &"
    cat /root/more1500byte | nc -u $target 3891
    sleep 10
done
