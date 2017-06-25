#!/bin/bash

###################################################
#
#       Type     :      check zookeeper service
#       Function :      
#       Usage    :      ./check_nuwa_zk.sh
#       Creator  :      zhe.lizh     Date    : 2012.12.20
#       Modifier :                   Date    :
#       ChangeLog:
#
###################################################
#profile
export LANG=en_US.UTF-8
export PATH="/usr/ali/bin:/usr/ali/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin"


#conf
self="check_nuwa_zk"
switch="/opt/monitor_lock/check_nuwa_zk.lock"
ok_level="OK - "
error_level="ERROR - "
warning_level="WARNING - "
critical_level="CRITICAL - "
level="$ok_level"
msg=""
ret_code=""
me="/bin/me"

zk_list="/tmp/zookeeper_list.lz"
lockfile="/tmp/lockfile.$self.lz"

trap "rm -f $lockfile 2>/dev/null;exit 1" 2 9 15

#function
i_exit()
{
    local rt=$1
    local is_clean=$2
    [[ $is_clean -eq 1 ]] && rm -f "$lockfile" &>/dev/null
    exit $rt
}

shell_timeout()
{
    local waittime="$1"
    shift
    local cmd="$@"
    $cmd &
    local PID=$!
    { sleep $waittime;kill -9 $PID &>/dev/null; } &>/dev/null &
    local KILLERPID=$!
    wait $PID &>/dev/null
    if [[ $? -eq 0 ]];then
        kill -9 $KILLERPID &>/dev/null
    fi
}

self_check()
{
    #proc lock
    local proc_num=$(cat "$lockfile" 2>/dev/null |wc -l)
    local count=0
    if [ -f "$lockfile" ] && [[ $proc_num -le $count ]];then
        echo "${error_level}$lockfile exist. limit: $count now: $proc_num"
        echo $$ >> "$lockfile" 2>/dev/null
        i_exit 201 0
    elif [ -f "$lockfile" ] && [[ $proc_num -gt $count ]];then
        echo $$ > "$lockfile" 2>/dev/null
    elif [ ! -f "$lockfile" ];then
        echo $$ > "$lockfile" 2>/dev/null
    fi
}

get_zk_list()
{
    [ ! -f "$zk_list" ] && \
    shell_timeout 5 $me | awk '/Local_nuwa/{print $NF}' | tr '|' '\n' > "$zk_list"

    for ip in $(cat "$zk_list" 2>/dev/null);do
        ipcalc -cs "$ip" || \
        { shell_timeout 5 $me | awk '/Local_nuwa/{print $NF}' | tr '|' '\n' > "$zk_list"; break; }
    done
}

check_zk()
{
    local timeout="10"
    local limit="$1"
    exec 4<"$zk_list"
    while read -u4 ip;do
        local srvr=$(echo srvr | nc -w $timeout $ip 10240)
        local Outstanding=$(echo "$srvr" | awk '/Outstanding/{print $NF}')
        local temp=$(echo "$Outstanding" | sed 's/ //g'|sed -n '/^[0-9][0-9]*$/p')
        #if Outstanding not a number or get srvr info failed
        [ -n "$temp" ] || \
        { msg="get $ip Outstanding failed|$msg";level="$warning_level";continue; }
        #if Outstanding > limit
        [[ "$Outstanding" -gt "$limit" ]] && \
        { msg="$ip Outstanding $Outstanding>$limit|$msg";level="$warning_level"; }
    done
}

#main
main()
{
    #check lock
    [ -e "$switch" ] && \
    { echo "${error_level}$switch exist, turn off this monitor.";i_exit 101 0; }
    self_check

    [ ! -x "$me" ] && \
    { echo "${warning_level}$me not exist or exec.";i_exit 102 1; }

    local args="$1"
    local args="${args# }"
    local args="${args% }"
    local limit="${args:=10000}"
    get_zk_list
    check_zk "$limit"
    [ -z "$msg" ] && msg="cluster zookeeper good."
    echo "${level}$msg"
    i_exit 0 1
}

#main begin
main "$@"
