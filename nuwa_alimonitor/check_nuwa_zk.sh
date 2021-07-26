#!/bin/bash

###################################################
#
#       Type     :      check zookeeper service
#       Function :      
#       Usage    :      ./check_nuwa_zk.sh
#       Creator  :      zhe.lizh     Date    : 2012.12.20
#       Modifier :                   Date    :
#	ChangeLog:
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
tmpfile="/tmp/tmpfile.$self.lz"

trap "rm -f $lockfile $tmpfile 2>/dev/null;exit 1" 2 9 15

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

check_zk_switch()
{
	local timeout="10"
	local limit="30"
	local elect=""
	local datetime=$(date "+%Y%m%d%H%M%S")

	local check_count=$(cat "$tmpfile" 2>/dev/null)
	[ -z "$check_count" ] && check_count=0
	local check_count=$((++check_count))

	exec 4<"$zk_list"
	while read -u4 ip;do
		local srvr=$(echo srvr | nc -w $timeout $ip 10240)
		local Zxid=$(echo "$srvr" | awk '/Zxid/{print $NF}')
		local Mode=$(echo "$srvr" | awk '/Mode/{print $NF}')
		local temp=$(python -c "print $Zxid >> 32L" 2>/dev/null)
		#if temp not a number or get srvr info failed
		[ -z "$temp" ] && continue

		#if zxid >> 32L change,ELECT happen
		local info="$ip::$Mode::$temp"
		local old_log="/dev/shm/$self.$ip.old_log"
		local cur_log="/dev/shm/$self.$ip.cur_log"
		local bak_log="/tmp/$self.$ip.$datetime"
		#first run
		[ ! -f "$old_log" ] && echo "$info" > "$old_log"

		echo "$info" > "$cur_log"
		diff "$old_log" "$cur_log" &>/dev/null
		if [ $? -ne 0 ] && [[ "$check_count" -le $limit ]];then
		#if status change and check_count <= limit
			{ msg="$ip $Mode $Zxid|$msg";level="$critical_level";elect="ELECT happen LOG:/dev/shm/$self.*.old_log"; } 
			echo "$check_count" > "$tmpfile"
			cat "$old_log" "$cur_log" > "$bak_log" 2>/dev/null
		else
		#if status not change or more then limit
			echo "$info" > "$old_log"
			echo 0 > "$tmpfile"
		fi
	done
	[ -n "$elect" ] && msg="$elect|$msg"
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
	check_zk_switch
	[ -z "$msg" ] && msg="cluster zookeeper good."
	echo "${level}$msg"
	i_exit 0 1
}

#main begin
main "$@"
