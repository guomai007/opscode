#!/bin/sh
while true ;do 
nohup sudo tcpdump -i eth0 -nn -C200 -W100 -Z root host 120.27.145.164 -w nc_eth0.pcap & 
nohup sudo tcpdump -i 62 -nn -C200 -W100 -Z root -w vm_vif.pcap &
sleep 3600
sudo killall -9 tcpdump
done
