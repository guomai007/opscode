#!/bin/sh
#****************************************************************#
# ScriptName: net_dirver_hot_up.sh
# Author: lei.xu@alibaba-inc.com
# Create Date: 2015-12-04 14:37
# Function:
#***************************************************************#

generate_patch_file(){
cat << 'EOF' > /usr/share/nic-drivers-suite/sources/igb-4.1.2-new-module.patch
diff -Naurp igb-4.1.2/src/Makefile igb-4.1.2/src.new/Makefile
--- igb-4.1.2/src/Makefile  2012-12-01 05:06:10.000000000 +0800
+++ igb-4.1.2/src.new/Makefile  2015-11-25 17:44:24.063454649 +0800
@@ -41,7 +41,7 @@ ifeq (,$(BUILD_KERNEL))
 BUILD_KERNEL=$(shell uname -r)
 endif

-DRIVER_NAME=igb
+DRIVER_NAME=igb_new

 ###########################################################################
 # Environment tests

diff -Naurp igb-4.1.2/src/igb_main.c igb-4.1.2/src.new/igb_main.c
--- igb-4.1.2/src/igb_main.c    2015-11-25 17:38:27.463125498 +0800
+++ igb-4.1.2/src.new/igb_main.c    2015-11-25 17:44:39.559817593 +0800
@@ -68,7 +68,7 @@
 #define BUILD 2-d
 #define DRV_VERSION __stringify(MAJ) "." __stringify(MIN) "." __stringify(BUILD) VERSION_SUFFIX DRV_DEBUG DRV_HW_PERF

-char igb_driver_name[] = "igb";
+char igb_driver_name[] = "igb_new";
 char igb_driver_version[] = DRV_VERSION;
 static const char igb_driver_string[] =
                                 "Intel(R) Gigabit Ethernet Network Driver";
EOF

cat << 'EOF' > /usr/share/nic-drivers-suite/sources/ixgbe-3.15.1-new-module.patch
diff -Naurp ixgbe-3.15.1/src/Makefile ixgbe-3.15.1/src.new/Makefile
--- ixgbe-3.15.1/src/Makefile   2013-04-25 01:01:44.000000000 +0800
+++ ixgbe-3.15.1/src.new/Makefile   2015-11-25 17:51:06.892869793 +0800
@@ -53,7 +53,7 @@ ifeq (,$(BUILD_KERNEL))
 BUILD_KERNEL=$(shell uname -r)
 endif

-DRIVER_NAME=ixgbe
+DRIVER_NAME=ixgbe_new

 ###########################################################################
 # Environment tests

diff -Naurp ixgbe-3.15.1/src/ixgbe_main.c ixgbe-3.15.1/src.new/ixgbe_main.c
--- ixgbe-3.15.1/src/ixgbe_main.c   2013-04-25 01:01:44.000000000 +0800
+++ ixgbe-3.15.1/src.new/ixgbe_main.c   2015-11-25 17:50:50.132479206 +0800
@@ -58,7 +58,7 @@
 #include "ixgbe_dcb_82599.h"
 #include "ixgbe_sriov.h"

-char ixgbe_driver_name[] = "ixgbe";
+char ixgbe_driver_name[] = "ixgbe_new";
 static const char ixgbe_driver_string[] =
                  "Intel(R) 10 Gigabit PCI Express Network Driver";
 #define DRV_HW_PERF
EOF

cat << 'EOF' > /usr/share/nic-drivers-suite/sources/tg3-3.124c.new-module.patch
diff -Naurp tg3-3.124c/Makefile tg3-3.124c.new/Makefile
--- tg3-3.124c/Makefile 2012-08-17 23:20:08.000000000 +0800
+++ tg3-3.124c.new/Makefile 2015-11-25 18:01:01.110596833 +0800
@@ -82,11 +82,12 @@ BCM_KVER := $(shell echo $(KVER) | cut -
 ifeq ($(BCM_KVER), 3)
 # Makefile for 2.5+ kernel

-BCM_DRV = tg3.ko
+BCM_DRV = tg3_new.ko

 ifneq ($(KERNELRELEASE),)

-obj-m += tg3.o
+obj-m += tg3_new.o
+tg3_new-objs := tg3.o

 else

@@ -98,7 +99,7 @@ endif
 else # ifeq ($(BCM_KVER),3)
 # Makefile for 2.4 kernel

-BCM_DRV = tg3.o
+BCM_DRV = tg3_new.o

 CC = gcc

@@ -154,8 +155,8 @@ endif
 .PHONEY: all clean install

 clean:
-   -rm -f tg3.o tg3.mod.c tg3.mod.o .tg3*
-   -rm -f tg3.ko tg3.ko.unsigned
+   -rm -f tg3.o tg3_new.o tg3_new.mod.c tg3_new.mod.o .tg3*
+   -rm -f tg3_new.ko tg3.ko.unsigned tg3_new.ko.unsigned
    -rm -f tg3.4.gz tg3_flags.h
    -rm -f Module.symvers Modules.symvers modules.order
    -rm -rf .tmp_versions Module.markers

diff -Naurp tg3-3.124c/tg3.c tg3-3.124c.new/tg3.c
--- tg3-3.124c/tg3.c    2015-11-25 17:54:15.593278593 +0800
+++ tg3-3.124c.new/tg3.c    2015-11-25 17:55:30.067021006 +0800
@@ -142,7 +142,7 @@ static inline void _tg3_flag_clear(enum
 #define tg3_flag_clear(tp, flag)           \
    _tg3_flag_clear(TG3_FLAG_##flag, (tp)->tg3_flags)

-#define DRV_MODULE_NAME        "tg3"
+#define DRV_MODULE_NAME        "tg3_new"
 #define TG3_MAJ_NUM            3
 #define TG3_MIN_NUM            124
 #define DRV_MODULE_VERSION \
EOF
sed -i "s/    /\t/g;/-rm -f/s/   /\t/;/DRV_MODULE_VERSION/s/ON /ON\t/;/define tg3_flag_clear/s/   /\t/" /usr/share/nic-drivers-suite/sources/tg3-3.124c.new-module.patch

cat << 'EOF' > /usr/share/nic-drivers-suite/sources/bnx2.new-module.patch
diff -Naurp src/bnx2.c src.new/bnx2.c
--- src/bnx2.c  2012-12-20 22:50:35.000000000 +0800
+++ src.new/bnx2.c  2015-11-25 18:08:06.564630449 +0800
@@ -90,7 +90,7 @@
 #include "bnx2_fw.h"
 #include "bnx2_fw2.h"

-#define DRV_MODULE_NAME        "bnx2"
+#define DRV_MODULE_NAME        "bnx2_new"
 #define DRV_MODULE_VERSION "2.2.3f"
 #define DRV_MODULE_RELDATE "Oct 25, 2012"

@@ -614,6 +614,7 @@ struct cnic_eth_dev *bnx2_cnic_probe2(st

    return cp;
 }
+#if 0
 #if !(defined(__VMKLNX__) && (VMWARE_ESX_DDK_VERSION >= 50000))
 #if defined(BNX2_INBOX)
 EXPORT_SYMBOL(bnx2_cnic_probe);
@@ -621,6 +622,7 @@ EXPORT_SYMBOL(bnx2_cnic_probe);
 EXPORT_SYMBOL(bnx2_cnic_probe2);
 #endif /* defined(BNX2_INBOX) */
 #endif
+#endif

 static void
 bnx2_cnic_stop(struct bnx2 *bp)

diff -Naurp src/Makefile src.new/Makefile
--- src/Makefile    2012-12-20 22:50:35.000000000 +0800
+++ src.new/Makefile    2015-11-25 18:09:35.094718840 +0800
@@ -160,14 +160,15 @@ BCM_CNIC:=1
 endif

 ifeq ($(BCM_CNIC), 1)
-BCM_DRV = bnx2.ko cnic.ko
+BCM_DRV = bnx2_new.ko cnic.ko
 else
-BCM_DRV = bnx2.ko
+BCM_DRV = bnx2_new.ko
 endif

 ifneq ($(KERNELRELEASE),)

-obj-m += bnx2.o
+obj-m += bnx2_new.o
+bnx2_new-objs := bnx2.o
 ifeq ($(BCM_CNIC), 1)
 obj-m += cnic.o
 endif
@@ -248,6 +249,6 @@ endif
 .PHONEY: all clean install

 clean:
-   -rm -f bnx2.o bnx2.ko bnx2.mod.c bnx2.mod.o bnx2.4.gz cnic.o cnic.ko cnic.mod.c cnic.mod.o .bnx2.*.cmd .cnic.*.cmd *.markers *.order *.symvers
+   -rm -f bnx2.o bnx2_new.o bnx2_new.ko bnx2_new.mod.c bnx2_new.mod.o bnx2.4.gz cnic.o cnic.ko cnic.mod.c cnic.mod.o .bnx2.*.cmd .cnic.*.cmd *.markers *.order *.symvers
    -rm -rf .tmp_versions
EOF
sed -i "/DRV_MODULE_NAME/s/    /\t/g;/DRV_MODULE_VERSION/s/ON /ON\t/g;/DRV_MODULE_RELDATE/s/TE /TE\t/g;/return cp/s/    / \t/;/-rm -f/s/    /\t/;/-rm -f/s/   /\t/" /usr/share/nic-drivers-suite/sources/bnx2.new-module.patch
}

build_drivers() {
	local drv
	local backup
	local KVER
	local LOG

	KVER="$1"
	LOG="$2".${KVER}

	rm -fr /tmp/nic-drivers-suite.building
	mkdir -p /tmp/nic-drivers-suite.building

	echo "`date "+%F %T"` Info: Installing new drivers for ${KVER}"
	rm -fr /tmp/nic-drivers-suite.building
	mkdir -p /tmp/nic-drivers-suite.building
	for drv in igb ixgbe tg3; do

		cd /usr/share/nic-drivers-suite/sources
		if [ $drv != tg3 ]; then
			tar zxf ${drv}-*.tar.gz -C /tmp/nic-drivers-suite.building
			cd /tmp/nic-drivers-suite.building/${drv}-*/src
		else
			tar jxf ${drv}-*.tar.bz2 -C /tmp/nic-drivers-suite.building
			cd /tmp/nic-drivers-suite.building/${drv}-*
		fi
		if [ $drv == igb ]; then
			patch -p2 < /usr/share/nic-drivers-suite/sources/igb-4.1.2-enable-RSS-default.patch >>${LOG} 2>&1
			patch -p2 < /usr/share/nic-drivers-suite/sources/igb-4.1.2-i350-disable_txb.v1.patch >>${LOG} 2>&1
			patch -p2 < /usr/share/nic-drivers-suite/sources/igb-4.1.2-disable-eee.patch >> ${LOG} 2>&1
			patch -p2 < /usr/share/nic-drivers-suite/sources/igb-4.1.2-new-module.patch >> ${LOG} 2>&1
		fi

		if [ $drv == ixgbe ]; then
			patch -p2 < /usr/share/nic-drivers-suite/sources/ixgbe-3.8.21-use-redhat-defined-macros-on-rhel6u2-or-later-release.patch >>${LOG} 2>&1
					patch -p2 < /usr/share/nic-drivers-suite/sources/ixgbe-3.15.1-enable-allow_unsupported_sfp.patch >>${LOG} 2>&1
					patch -p2 < /usr/share/nic-drivers-suite/sources/ixgbe-3.15.1-new-module.patch >>${LOG} 2>&1
		fi

		if [ $drv == tg3 ]; then
			patch -p1 < /usr/share/nic-drivers-suite/sources/tg3-3.124c.disable.ieee1588.and.use.rhel-ext.patch >>${LOG} 2>&1
			patch -p1 < /usr/share/nic-drivers-suite/sources/tg3-3.124c.new-module.patch >>${LOG} 2>&1
		fi

		if [ $drv != tg3 ]; then
			make BUILD_KERNEL=${KVER} -j 8 >>${LOG} 2>&1
		else
			sh makeflags.sh /lib/modules/${KVER}/build TG3_NO_EEE > tg3_flags.h
			make KVER=${KVER} >>${LOG} 2>&1
		fi
				dir_name=`find /lib/modules/${KVER}/ -name ${drv}.ko|sed "s/${drv}.ko$//"`
				cp -r ./${drv}_new.ko $dir_name
	done

	#Boardcom NIC drivers:bnx2
	cd /usr/share/nic-drivers-suite/sources
	rm -rf /tmp/nic-drivers-suite.building/netxtreme2-*
	tar jxf netxtreme2-*.tar.bz2 -C /tmp/nic-drivers-suite.building
	cd /tmp/nic-drivers-suite.building/netxtreme2-*/bnx2/src
	patch -p1 < /usr/share/nic-drivers-suite/sources/bnx2.new-module.patch >>${LOG} 2>&1
	make KVER=${KVER} >>${LOG} 2>&1
	dir_name=`find /lib/modules/${KVER}/ -name bnx2.ko|sed "s/bnx2.ko$//"`
	cp -r ./bnx2_new.ko $dir_name

	/sbin/depmod ${KVER}
}

build_new_driver(){
	####judge all new driver exists#####
	need=0
	for d in tg3_new igb_new ixgbe_new bnx2_new;do
		if ! modinfo $d 2>/dev/null |grep -q version;then
			need=1
			break
		fi
	done

	if [[ $need == "0" ]];then
		return
	fi

	for d in tg3 igb ixgbe bnx2;do
        if [[ `modinfo $d|grep "^version"|head -1|awk '{print $NF}'` != `modinfo ${d}_new|grep "^version"|head -1|awk '{print $NF}'` ]];then
            need=1
            break
        fi
    done

	if [[ $need == "0" ]];then
		return
	fi

	kver=`uname -r`
    if [ ! -e /lib/modules/${kver}/build ];then
        echo "`date "+%F %T"` Info: yum install kernel-devel for $kver"
        if echo "$kver" |grep -q xen;then
            kk=`echo $kver|sed "s/xen//"`
            yum install -y -b current kernel-xen-devel-${kk} >/dev/null 2>&1
            yum install -y kernel-xen-devel-${kk} >/dev/null 2>&1
        else
            yum install -y -b current kernel-devel-${kver} >/dev/null 2>&1
            yum install -y kernel-devel-${kver} >/dev/null 2>&1
        fi
        if [ ! -e /lib/modules/${kver}/build ];then
			    echo "fatal error: kernel-devel for ${kver} is not installed, I can't build drivers for it"
			    exit 7
        fi
	fi
	if [[ `rpm -q nic-drivers-src-suite-20140902-1.noarch|grep -v "is not installed"|wc -l` == "0" ]];then
        if rpm -qa|grep -q nic-drivers-src-suite ;then
            rpm -e `rpm -qa|grep nic-drivers-src-suite` >/dev/null 2>&1
        fi
        echo "`date "+%F %T"` Info: yum install nic-drivers-src-suite-20140902-1"
		yum install -y nic-drivers-src-suite-20140902-1.noarch >/dev/null 2>&1
		if [[ `rpm -q nic-drivers-src-suite-20140902-1|grep -v "is not installed"|wc -l` == "0" ]];then
			echo "fatal error: yum install -y nic-drivers-src-suite-20140902-1.noarch fail"
			exit 11
		fi
	fi
	generate_patch_file
    if [ -e /lib/modules/`uname -r`/build ];then
	    build_drivers `uname -r` /tmp/nic-drv.log
    fi
	for d in tg3_new igb_new ixgbe_new bnx2_new;do
		if ! modinfo $d 2>/dev/null |grep -q version;then
			echo "fatal error: driver:${d} is not exists"
			exit 9
		fi
	done
}

check_command(){
	if [ `which ethtool 2>/dev/null|wc -l` == "0"  \
        -o `which ifenslave 2>/dev/null |wc -l` == "0" \
        -o `which ifconfig 2>/dev/null |wc -l` == "0" \
        -o `which modprobe 2>/dev/null |wc -l` == "0" \
        -o `which lsmod 2>/dev/null |wc -l` == "0" \
        -o `which uname 2>/dev/null |wc -l` == "0" \
        -o `which cat 2>/dev/null |wc -l` == "0" \
        -o `which mv 2>/dev/null |wc -l` == "0" \
        -o `which ls 2>/dev/null |wc -l` == "0" \
        -o `which modinfo 2>/dev/null |wc -l` == "0" \
        -o `which ifenslave 2>/dev/null |wc -l` == "0" \
        -o `which sed 2>/dev/null |wc -l` == "0" \
        -o `which grep 2>/dev/null |wc -l` == "0" \
        -o `which awk 2>/dev/null |wc -l` == "0" \
        -o `which rmmod 2>/dev/null |wc -l` == "0" \
        -o `which echo 2>/dev/null |wc -l` == "0" ];then
		echo "fatal error: ethtool or ifenslave not exists"
		exit 1
	fi
}

check_bond_t(){
	######检查指定的bond设备是否为mod4，并且双网卡运行正常
	bond=$1
	bond_m=`grep "Bonding Mode: IEEE 802.3ad Dynamic link aggregation" /proc/net/bonding/${bond}|wc -l`
	if [[ "$bond_m" == "1" ]];then
		aggid=`cat /proc/net/bonding/$bond| grep -Po "(?<=Aggregator ID: )\d+" | sort | uniq | wc -l`
		agg_num=`cat /proc/net/bonding/$bond| grep "^Slave Interface:" | wc -l`
		upstatus=`cat /proc/net/bonding/$bond| grep -Po "(?<=MII Status: ).*" | sort | uniq | wc -l`
		if [ ${agg_num} -eq 2 -a ${aggid} -eq 1 -a ${upstatus} -eq 1 ];then
			echo "success"
		else
			echo "fail"
		fi
	else
		echo "fail"
	fi
}

check_bond(){
	###优先检查bond0
	bond_d=""
	if [ -f "/proc/net/bonding/bond0" ];then
		bond_d="bond0"
		bond_status=`check_bond_t bond0`
		if [[ "$bond_status" == "success" ]];then
			echo "bond0_success"
			return
		fi
	elif [[ `ls /proc/net/bonding/|grep -vw bond0|wc -l` == 0 ]];then
		echo "error_nobond"
		return
	fi
	###bond0失败，再检查是否有其他的bond
	for f in `ls /proc/net/bonding/|grep -vw bond0`;do
		bond_status=`check_bond_t $f`
		if [[ "$bond_status" == "success" ]];then
			bond_d="$f"
			echo "${f}_success"
			return
		fi
	done
	echo "${bond_d}_fail"
}



get_nic(){
	bond_dev=$1
	nic_string=""
	for nic in `cat /proc/net/bonding/$bond_dev |grep "^Slave Interface:" |awk '{print $NF}'`;do
		bus=`ethtool -i $nic|grep "bus-info"|awk '{print $NF}'`
		nic_d=`ethtool -i $nic|grep "^driver"|awk '{print $NF}'`
		if [ -f "/etc/sysconfig/network-scripts/ifcfg-${nic}" ];then
			nic_cfg_real='same'
		else
			nic_cfg_real='diff'
			if [[ `ls /sys/bus/pci/devices/${bus}/net/ 2>/dev/null |wc -l` != "1" && `ls /sys/bus/pci/devices/${bus}/net:${nic} 2>/dev/null|wc -l` != "1" ]];then
				echo "fatal error: ${nic} is not original device name"
				exit 10
			fi
		fi
		if [[ -d /sys/bus/pci/drivers/${nic_d}/${bus} && -f /sys/bus/pci/drivers/${nic_d}/bind && -f /sys/bus/pci/drivers/${nic_d}/unbind ]];then
			sleep 0.0001
		else
			echo "fatal error: pci bind and unbind interface is not exists in /sys"
			exit 19
		fi
		if [[ $nic_string"X" == "X"  ]];then
			nic_string="${nic}_${nic_cfg_real}"
		else
			nic_string="${nic_string}#${nic}_${nic_cfg_real}"
		fi
	done
	echo ${nic_string}
}


get_driver(){
	nic_str=$1
	nic_1=`echo $nic_str|awk -F"#" '{print $1}'|awk -F"_" '{print $1}'`
	nic_2=`echo $nic_str|awk -F"#" '{print $2}'|awk -F"_" '{print $1}'`
	nic_1_ethtool_str=`ethtool -i ${nic_1}`
	nic_driver=`echo "${nic_1_ethtool_str}"|grep "^driver"|awk '{print $NF}'`
	nic_driver_v=`echo "${nic_1_ethtool_str}"|grep "^version"|awk '{print $NF}'`

	nic_2_ethtool_str=`ethtool -i ${nic_2}`
	nic_2_driver=`echo "${nic_2_ethtool_str}"|grep "^driver"|awk '{print $NF}'`
	nic_2_driver_v=`echo "${nic_2_ethtool_str}"|grep "^version"|awk '{print $NF}'`
	if [[ ${nic_driver} != ${nic_2_driver} || ${nic_driver_v} != ${nic_2_driver_v} ]];then
		echo "fatal error: ${nic_1} and ${nic_2} driver are not same or version are not same"
		exit 13
	fi
	for dev in /sys/class/net/*/device
	do
		nic=`echo "$dev" |awk -F"/" '{print $5}'`
		if echo "$nic" |grep -qE "vif|tmp|usb|${nic_1}|${nic_2}" ;then
			continue
		fi
		if [[ `cat /sys/class/net/${nic}/operstate` == "up" ]];then
			other_nic_driver=`ethtool -i ${nic}|grep "^driver"|awk '{print $NF}'`
			if [[ $other_nic_driver == ${nic_driver} ]];then
				echo "fatal error: There is other nic:${nic} use the driver:${nic_driver} !"
				exit 25
			fi
		fi
	done
	echo "${nic_driver}#${nic_driver_v}"
}

compare_version(){
    v1=`echo $1|sed "s/-.*$//"|tr -d "[a-z]"|tr -d "[A-Z]"`
    v2=`echo $2|sed "s/-.*$//"|tr -d "[a-z]"|tr -d "[A-Z]"`

    dot_num=`echo $v2|awk -F"." '{print NF}'`
    if [[ `echo $v1|awk -F"." '{print NF}'` != $dot_num || $v1 == $v2 ]];then
        echo no
        return
    fi
    for i in `seq 1 $dot_num`;do
        if [[ $((`echo $v2|tr "." "\n"|head -$i|tail -1`-`echo $v1|tr "." "\n"|head -$i|tail -1`)) -gt 0 ]];then
            echo yes
            return
        elif [[ $((`echo $v2|tr "." "\n"|head -$i|tail -1`-`echo $v1|tr "." "\n"|head -$i|tail -1`)) -lt 0 ]];then
            echo no
            return
        fi
    done
    echo no
}

judge_driver_version(){
	driver_str=$1
	driver_name=`echo $driver_str|awk -F"#" '{print $1}'`
	driver_version=`echo $driver_str|awk -F"#" '{print $2}'`
    if [[ ${driver_name} == "igb" ]];then
        ret=`compare_version ${driver_version} "4.1.2-d"`
    elif [[ ${driver_name} == "ixgbe" ]];then
        ret=`compare_version ${driver_version} "3.15.1"`
    elif [[ ${driver_name} == "tg3" ]];then
        ret=`compare_version ${driver_version} "3.124c"`
    elif [[ ${driver_name} == "bnx2" ]];then
        ret=`compare_version ${driver_version} "2.2.3f"`
    else
	    echo "`date "+%F %T"` Info: driver is not (igb,ixgbe,tg3,bnx2),can not upgrade"
		exit 0
    fi
    if [[ $ret == "no" ]];then
        echo "`date "+%F %T"` Info: driver $driver_name-$driver_version need not to upgrade"
        exit 0
    fi

}


check_new_driver(){
	driver_str=$1
	driver_name=`echo $driver_str|awk -F"#" '{print $1}'`
	driver_version=`echo $driver_str|awk -F"#" '{print $2}'`
	dst_driver_version=`modinfo ${driver_name}|grep "^version"|awk '{print $NF}'`
	dst_new_driver_version=`modinfo ${driver_name}_new|grep "^version"|awk '{print $NF}'`
	if [[ ${driver_version}"X" == ${dst_driver_version}"X" ]];then
		echo "There is not a new ${driver_name} driver"
		exit 14
	fi

	if [[ ${dst_driver_version}"X" != ${dst_new_driver_version}"X" ]];then
		echo "There is not a ${driver_name}_new driver"
		exit 14
	fi
	echo "`date "+%F %T"` Info: new ${driver_name} is ready,version = ${dst_new_driver_version}"
}


unbind_nic(){
	driver_name=$1
	bus=$2
	echo "$bus" > /sys/bus/pci/drivers/${driver_name}/unbind
	sleep 5
}

bind_nic(){
	driver_name=$1
	bus=$2
	if [ ! -d /sys/bus/pci/drivers/${driver_name}/ ];then
		modprobe ${driver_name} >/dev/null 2>&1
		sleep 6
	fi
	if [[ `ls -ld /sys/bus/pci/drivers/${driver_name}/${bus} 2>/dev/null|wc -l` == 0 ]];then
		echo $bus > /sys/bus/pci/drivers/${driver_name}/bind
		sleep 12
		if [[ `ls -ld /sys/bus/pci/drivers/${driver_name}/${bus} 2>/dev/null|wc -l` == 0 ]];then
			echo "fatal error: bind ${bus} to ${driver} fail"
			recover_ifcfg
			exit 41
		fi
	else
		sleep 12
	fi
}

ifup_nic(){
	nic=$1
	if ! ifconfig ${nic} |grep -q "UP BROADCAST RUNNING";then
		echo "`date "+%F %T"` Info: ifconfig up $nic now !"
		ifconfig $nic up
		sleep 8
		if ! ifconfig ${nic} |grep -q "UP BROADCAST RUNNING";then
			echo "fail"
		else
			echo "success"
		fi
	else
		echo "success"
	fi
}



add_to_bond(){
	bond_dev=$1
	nic=$2
	sleep 8
	if cat /proc/net/bonding/${bond_dev}|grep -q "Slave Interface: $nic";then
		check_result=`check_bond_cycle $bond_dev`
		if [[ "$check_result" != "success" ]];then
			ifup_result=`ifup_nic $nic`
		fi
		check_result=`check_bond_cycle $bond_dev`
		if [[ "$check_result" != "success" ]];then
			echo "fatal error! add to bond fail, please check!"
			recover_ifcfg
			exit 23
		fi
	else
		if [[ `cat /proc/net/bonding/${bond_dev}|grep "^Slave Interface:"|wc -l` == "2" ]];then
			echo "bond status is OK before ${nic} added"
			recover_ifcfg
			exit 21
		fi
		echo "`date "+%F %T"` Info: add $nic to bond now ! "
		ifenslave $bond_dev $nic
		sleep 5
		check_result=`check_bond_cycle $bond_dev`
		if [[ "$check_result" != "success" ]];then
			ifup_result=`ifup_nic $nic`
		fi
		check_result=`check_bond_cycle $bond_dev`
		if [[ "$check_result" != "success" ]];then
			echo "fatal error! add to bond fail, please check!"
			recover_ifcfg
			exit 23
		fi
	fi
}

check_bond_cycle(){
	bond_dev=$1
	t="fail"
	for i in `seq 1 5`;do
		bond_s=`check_bond_t $bond_dev`
		if [[ "$bond_s" != "success" ]];then
			sleep 2
		else
			t="success"
			break
		fi
	done
	echo "$t"
}

get_new_nic_name(){
	bus=$1
	if [ -d /sys/bus/pci/devices/$bus/net/ ];then
		new_nic_name=`ls /sys/bus/pci/devices/$bus/net/`
	else
		new_nic_name=`ls -ld /sys/bus/pci/devices/$bus/net:* |awk -F":" '{print $NF}'|awk '{print $1}'`
	fi
	echo ${new_nic_name}
}
remove_from_bond(){
	bond_dev=$1
	nic=$2
	sleep 8
	for i in `seq 1 5`;do
		bond_s=`check_bond_t $bond_dev`
		if [[ "$bond_s" != "success" ]];then
			sleep 2
		else
			break
		fi
	done
	for i in `seq 1 5`;do
		echo "`date "+%F %T"` Info: remove $nic from bond now !"
        ifconfig $nic down
        sleep 2
		ifenslave -d $bond_dev $nic
		if ! cat /proc/net/bonding/${bond_dev}|grep -q "Slave Interface: $nic";then
			break
		else
			sleep 2
		fi
	done
}


upgrade_nic_driver(){
	new_driver_name=$1
	bond_dev=$2
	nic=$3
    echo "`date "+%F %T"` Info: upgrade ${nic}'s driver to ${new_driver_name}"
	bus=`ethtool -i $nic|grep "bus-info"|awk '{print $NF}'`
	old_driver_name=`ethtool -i $nic|grep "^driver"|awk '{print $NF}'`
	if [[ $old_driver_name == $new_driver_name ]];then
		echo "fatal error: ${nic}'s driver == new driver:${old_driver_name}"
		recover_ifcfg
		exit 39
	fi
	remove_from_bond $bond_dev $nic
	unbind_nic ${old_driver_name} $bus
	bind_nic ${new_driver_name} $bus

	driver_old_new_same=`echo "${nic_string}"|tr "#" "\n"|grep ${nic}|awk -F"_" '{print $2}'`
	new_nic_name=$nic
	if [[ "${driver_old_new_same}" == "diff" ]];then
		new_nic_name=`get_new_nic_name ${bus}`
		ip link set $new_nic_name name $nic
	fi
	add_to_bond $bond_dev $nic
	sleep 3
}


move_ifcfg(){
    echo "`date "+%F %T"` Info: move /etc/sysconfig/network-scriptes/ifcfg-*"
	cd /etc/sysconfig/network-scripts/
	for f in `ls ifcfg-*|grep -v ifcfg-lo`;do
		mv $f ../${f}_tmpfordriverup
	done
    updelay=`cat /sys/class/net/${bond_dev}/bonding/updelay`
    if [[ $updelay != "0" ]];then
        echo 0 > /sys/class/net/${bond_dev}/bonding/updelay
    fi
}

recover_ifcfg(){
    echo "`date "+%F %T"` Info: recover /etc/sysconfig/network-scriptes/ifcfg-*"
	cd /etc/sysconfig/
	for f in `ls ifcfg-*_tmpfordriverup`;do
		old_f=`echo $f|sed "s/_tmpfordriverup//"`
		mv $f network-scripts/${old_f}
	done
    if [[ $updelay != "0" ]];then
        echo $updelay > /sys/class/net/${bond_dev}/bonding/updelay
    fi
}


rmmod_driver(){
	driver=$1
	for dev in /sys/class/net/*/device
	do
		nic=`echo "$dev" |awk -F"/" '{print $5}'`
		if echo "$nic" |grep -qE "vif|tmp|usb" ;then
			continue
		fi
		if [[ `cat /sys/class/net/${nic}/operstate` != "up" ]];then
			continue
		fi
		bus=`ethtool -i ${nic}|grep "bus-info" |awk '{print $NF}'`
		if [[ `ls -ld /sys/bus/pci/drivers/${driver}/${bus} 2>/dev/null|wc -l` != 0 ]];then
			echo "fatal error: ${driver} is be used by ${nic}"
			recover_ifcfg
			exit 41
		fi
	done
    for b in `ls /sys/bus/pci/drivers/${driver}|grep -E .*:.*:.*`;do
        echo $b > /sys/bus/pci/drivers/${driver}/unbind
    done
	rmmod ${driver} >/dev/null 2>&1
	if lsmod|grep -qw $driver;then
		echo "fatal error: rmmod ${driver} driver fail"
		recover_ifcfg
		exit 37
	fi
	sleep 2
    echo "`date "+%F %T"` Info: rmmod driver ${driver} success"
}

insmod_driver(){
	dirver=$1
	if ! lsmod|grep -qw $driver;then
		modprobe $driver >/dev/null 2>&1
	fi
	sleep 3
	if ! lsmod|grep -qw $driver;then
		echo "fatal error: modprobe ${driver} driver fail"
		recover_ifcfg
		exit 35
	fi
    echo "`date "+%F %T"` Info: modprobe driver ${driver} success"
}

get_cpu_array(){
    slave_id=$1
    phy_array=($(cat /proc/cpuinfo  |grep "^physical id"|awk '{print $NF}'))
    core_array=($(cat /proc/cpuinfo  |grep "^core id"|awk '{print $NF}'))
    m=$((${#phy_array[@]}-1))
    cpu_array=()
    if [[ $slave_id == "0" ]];then
        m_array=($(seq 1 $m))
        tmp_array=($(cat /proc/cpuinfo  |grep "^physical id"|awk '{print $NF}'|sort -un))
    else
        m_array=($(seq $m -1 1))
        tmp_array=($(cat /proc/cpuinfo  |grep "^physical id"|awk '{print $NF}'|sort -unr))
    fi
    for k in `seq 1 20`;do
        phy_id_array=(${phy_id_array[@]} ${tmp_array[@]})
    done
    k=1
    for i in ${m_array[@]};do
        id=${phy_id_array[$k]}
        for j in ${m_array[@]};do
            if [[ ${phy_array[$j]} == "$id" ]];then
                cpu_array=(${cpu_array[@]} $j)
                phy_array[$j]="T"
                k=$(($k+1))
                break
            fi
        done
    done

    for k in `seq 1 2`;do
        cpu_array=(${cpu_array[@]} ${cpu_array[@]})
    done
    echo ${cpu_array[@]}
}

get_irq_array(){
    nic=$1
    if [[ `cat /proc/interrupts|grep -i "${nic}-"|wc -l` == "0" ]];then
        irq_array=($(cat /proc/interrupts | grep -iw ${nic} |cut -d: -f1 | sed "s/ //g"))
    else
        irq_array=($(cat /proc/interrupts | grep -i "${nic}-"|cut -d: -f1 | sed "s/ //g"))
    fi
    echo ${irq_array[@]}
}

nic_irq_bind(){
    nic=$1
    nic_num=$2
    echo "`date "+%F %T"` Info: set $nic interrupt smp_affinity"
    irq_array=($(get_irq_array $nic))
    cpu_array=($(get_cpu_array $nic_num))
    for i in `seq 0 $((${#irq_array[*]}-1))`;do
        cpu_num=$(echo "obase=16;$((2 ** ${cpu_array[$i]}))"|bc)
        echo $cpu_num > /proc/irq/${irq_array[$i]}/smp_affinity
        ##echo "echo $cpu_num > /proc/irq/${irq_array[$i]}/smp_affinity"
    done
}




main(){
	bond_s=`check_bond`
	if ! echo "$bond_s" |grep -q success;then
		echo "${bond_s}"
		return
	fi
	bond_dev=`echo $bond_s|awk -F"_" '{print $1}'`
	echo "`date "+%F %T"` Info: bond master $bond_dev is in mode 4"
	nic_string=`get_nic $bond_dev`
	if echo "${nic_string}"|grep -q "fatal error";then
		echo "${nic_string}"
		exit 10
	fi
	####nic_string=eth0_same#eth1_same or nic_string=slave0_diff#slave1_diff#####
	nic1=`echo $nic_string|awk -F"#" '{print $1}'|awk -F"_" '{print $1}'`
	nic2=`echo $nic_string|awk -F"#" '{print $2}'|awk -F"_" '{print $1}'`
	echo "`date "+%F %T"` Info: bond master $bond_dev has two slaves:${nic1} and ${nic2}"

    ###driver_str=igb#4.1.2-k####
	driver_str=`get_driver ${nic_string}`
	if echo "${driver_str}"|grep -q "fatal error";then
		echo "${driver_str}"
		exit 13
	fi
	echo "`date "+%F %T"` Info: ${nic1} and ${nic2} driver is `echo ${driver_str}|awk -F# '{print $1}'`, version is `echo ${driver_str}|awk -F# '{print $2}'`"


	old_driver=`echo $driver_str|awk -F# '{print $1}'`
	new_driver="${old_driver}_new"
    judge_driver_version ${driver_str}
	build_new_driver
	check_new_driver ${driver_str}
	move_ifcfg $bond_dev
	upgrade_nic_driver ${new_driver} ${bond_dev} ${nic1}
    nic_irq_bind ${nic1} 0
	upgrade_nic_driver ${new_driver} ${bond_dev} ${nic2}
    nic_irq_bind ${nic2} 1
	driver_str_1=`get_driver ${nic_string}`
	if echo "${driver_str_1}"|grep -q "fatal error";then
		echo "${driver_str_1}"
	    recover_ifcfg
		exit 13
	fi
	if ! echo "${driver_str_1}" |grep -q "_new#" ;then
		echo "fatal error:upgrade driver first time fail"
	    recover_ifcfg
		exit 31
	fi
	rmmod_driver $old_driver
	insmod_driver $old_driver
	upgrade_nic_driver ${old_driver} ${bond_dev} ${nic1}
    nic_irq_bind ${nic1} 0
	upgrade_nic_driver ${old_driver} ${bond_dev} ${nic2}
    nic_irq_bind ${nic2} 1
	recover_ifcfg $bond_dev
	rmmod_driver $new_driver
}
main
