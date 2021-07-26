#!/bin/bash

###################################################
#
#       Type     :      check nuwa service
#       Function :      
#       Usage    :      ./check_houyi_nuwa.sh
#       Creator  :      zhe.lizh     Date    : 2012.12.20
#       Modifier :                   Date    :
#	ChangeLog:
#
###################################################
#profile
export LANG=en_US.UTF-8
export PATH="/usr/ali/bin:/usr/ali/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin:/usr/local/sbin"


#conf
self="check_houyi_nuwa"
switch="/opt/monitor_lock/check_houyi_nuwa.lock"
ok_level="OK - "
error_level="ERROR - "
warning_level="WARNING - "
critical_level="CRITICAL - "
level="$ok_level"
msg=""
ret_code=""
nuwa_console="/apsara/deploy/nuwa_console"

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
	if [ -e "$lockfile" ] && [[ $proc_num -le $count ]];then
		echo "${error_level}$lockfile exist. limit: $count now: $proc_num"
		echo $$ >> "$lockfile" 2>/dev/null
		i_exit 201 0
	elif [ -e "$lockfile" ] && [[ $proc_num -gt $count ]];then
		echo $$ > "$lockfile" 2>/dev/null
	elif [ ! -e "$lockfile" ];then
		echo $$ > "$lockfile" 2>/dev/null
	fi
}

nuwa_check()
{
	local nuwa_info=$(echo ls | $nuwa_console --address=nuwa://localcluster/ --console 2>&1|grep Error)
	echo "$nuwa_info" > "$tmpfile"
	#if get info failed,nuwa hung,error or ag apsara hung
	[ -n "$nuwa_info" ] && \
	{ msg="nuwa service error, maybe ag apsara hung.log:$tmpfile|$msg";level="$critical_level"; }
}

#main
main()
{
	#check lock
	[ -e "$switch" ] && \
	{ echo "${error_level}$switch exist, turn off this monitor.";i_exit 101 0; }
	self_check

	[ ! -x "$nuwa_console" ] && \
	{ echo "${warning_level}$nuwa_console not exist or exec.";i_exit 102 1; }

	nuwa_check
	[ -z "$msg" ] && msg="cluster nuwa good."
	echo "${level}$msg"
	i_exit 0 1
}

#main begin
main "$@"
