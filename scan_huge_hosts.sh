#!/bin/sh
PSSH_CMD='/usr/bin/parallel-ssh'
SSH_USER='fsp'
if [ ! -s iplist ];then
    echo "Host's iplist file is not Exist in Current Directory: iplist"
    echo "请先创建文件:iplist（文件内容为一行一个IP地址）"
    exit 200
fi

rm -f /tmp/ping_ok /tmp/ping_fail /tmp/ssh_result /tmp/ssh_ok /tmp/ssh_timeout /tmp/ssh_error
touch /tmp/ping_ok /tmp/ping_fail /tmp/ssh_result /tmp/ssh_ok /tmp/ssh_timeout /tmp/ssh_error
for i in `cat iplist` ;do
nohup ping -c5 -W1 $i >/dev/null 2>&1  && echo $i >> /tmp/ping_ok &
nohup ping -c5 -W1 $i >/dev/null 2>&1  || echo $i >> /tmp/ping_fail &
done

while true; do
    source_count=`cat iplist|wc -l`
    dest_count=`cat /tmp/ping_*|wc -l`
    if [ $source_count -eq $dest_count ];then
        break
    fi
done

if [ -s /tmp/ping_ok ];then 
    $PSSH_CMD -h /tmp/ping_ok -l $SSH_USER -t5 -p1000 -O StrictHostKeyChecking=no -O IdentityFile=/root/.ssh/fsp-id_rsa "uptime" |grep -e SUCCESS -e FAILURE > /tmp/ssh_result
fi
grep SUCCESS /tmp/ssh_result |awk '{print $NF}' > /tmp/ssh_ok
grep FAILURE /tmp/ssh_result |while read line ; do
    echo "$line"|grep  'Timed out' >/dev/null
    if [ $? -eq 0 ];then
         echo "$line"|awk '{print $4}' >> /tmp/ssh_timeout
    else
         echo "$line"|awk '{print $4}' >> /tmp/ssh_error
    fi
done

echo "ping_Alive and ssh_Normal Host:"
cat /tmp/ssh_ok
echo ''
echo "ping_Down Host:"
cat /tmp/ping_fail
echo ''
echo "ping_Alive and ssh_Error Host: ## Maybe Reason: 1.Password or PublicKey Error 2.sshd Return Connection Reset/refused"
cat /tmp/ssh_error
echo ''
echo "ping_Alive and ssh_Timeout Host: ## Maybe Reason: Host is Busying and Load is High"
cat /tmp/ssh_timeout

