#!/bin/bash
#Script made by  helperchoi@gmail.com

export LANG=C
export LC_ALL=C

SCRIPT_VERSION=1.1.20220607
WARNING_DAYS=10
FS_LIMIT=85
CPU_LIMIT=60
MEM_LIMIT=95
INODE_LIMIT=85
SYS_LOG=/var/log/messages
LOG_DATE=`date '+%b %d %H:%M:%S'`

source /root/.bashrc

### User & Dependency Package Check ###

FUNCT_CHECK_USER() {

	CHECK_USER=`id | awk '{print $1}' | cut -d "(" -f1 | cut -d "=" -f2`

	if [ ${CHECK_USER} -eq 0 ]
	then
		CHECK_UTIL1=`which ip 2>&1 | grep ":" | wc -l`

		if [ ${CHECK_UTIL1} -ne 0 ]
		then
			echo "[INFO] Needs to be Installed : ip tool"
			#yum -y install iproute
			echo
		fi

		CHECK_UTIL2=`which multipath 2>&1 | grep ":" | wc -l`

		if [ ${CHECK_UTIL2} -ne 0 ]
		then
			echo "[INFO] Needs to be Installed : multipath tool"
			#yum -y install device-mapper-multipath
			echo
		fi

		CHECK_UTIL3=`which dstat 2>&1 | grep ":" | wc -l`

		if [ ${CHECK_UTIL3} -ne 0 ]
		then
			echo "[INFO] Needs to be Installed : dstat tool"
			#yum -y install dstat
			echo
		fi
	else
		echo
		echo "[INFO] You are not Root User, so Can not Execute some Command."
	fi
}

FUNCT_CHECK_OS_VERSION() {

#################################
### 1. Check Linux OS Version ###
#################################


CHECK_OS=`uname -a | cut -d "/" -f 2 | tr '[A-Z]' '[a-z]'`

if [ $CHECK_OS = "linux" ];
then
	if [ -e "/etc/oracle-release" -o -e "/etc/enterprise-release" ]
	then
		if [ -e "/etc/oracle-release" ]
		then
			export OS_VERSION=`cat /etc/oracle-release`
		else
			export OS_VERSION=`cat /etc/enterprise-release`
		fi

	elif [ -e "/etc/SuSE-release" ]
	then
		OS_VERSION1=`cat /etc/SuSE-release | grep -i "^suse"`
		OS_VERSION2=`cat /etc/SuSE-release | grep -i "^PATCHLEVEL" | cut -d "=" -f2`
		export OS_VERSION=`echo "OS_VER||${OS_VERSION1} SP${OS_VERSION2}"`

	elif [ `grep -i "ubuntu" /etc/*-release| wc -l` -gt 0 ]
	then
		export OS_VERSION=`cat /etc/os-release | grep "PRETTY_NAME" | cut -d "=" -f2`
	else
		export OS_VERSION=`cat /etc/redhat-release`
	fi
else
	echo "### Can not execute~!!! It is not not Standard Linux family !!! ###"
	exit 1
fi

echo "[ Hostname ] : $HOSTNAME / ${OS_VERSION} / `uname -r`"

}


FUNCT_CHECK_SYS_RESOURCE() {

####################################
### 2. Check System Resouce Info ###
####################################

declare -a ARRAY_TIME
declare -a ARRAY_MEMLIST
ARRAY_TIME=("${ARRAY_TIME[@]}" "`date`")

for MEM_LIST in `cat /proc/meminfo | awk '{print $2}'`
do
 ARRAY_MEMLIST=("${ARRAY_MEMLIST[@]}" "`echo ${MEM_LIST}`")
done

CPU_CORE=`cat /proc/cpuinfo | grep -i process | wc -l`
LOAD_AVERAGE=`cat /proc/loadavg | awk '{print $1}'`
LOAD_AVERAGE_LIMIT=`echo "${CPU_CORE} * 2" | bc`
export LOAD_DIFF=`echo "${LOAD_AVERAGE} >= ${LOAD_AVERAGE_LIMIT}" | bc`
CPU_IDLE=`sar -p 1 1 | grep Aver | awk '{print $8}'`
CPU_USAGE=`echo "100 - ${CPU_IDLE}" | bc`

MEM_TSIZE=${ARRAY_MEMLIST[0]}
MEM_AVAILSIZE=${ARRAY_MEMLIST[2]}
MEM_USIZE=`echo "100 - ((100 * ${MEM_AVAILSIZE}) / ${MEM_TSIZE})" | bc`


##############################################
### CHECK USER CUSMTOM RESOURCE LIMIT VARS ###
##############################################
if [ -z ${OS_CUSTOM_CPU_LIMIT} ]
then
	export CPU_DIFF=`echo "${CPU_USAGE} >= ${CPU_LIMIT}" | bc`
else
	export CPU_DIFF=`echo "${CPU_USAGE} >= ${OS_CUSTOM_CPU_LIMIT}" | bc`
fi

if [ -z ${OS_CUSTOM_MEM_LIMIT} ]
then
	export MEM_DIFF=`echo "${MEM_USIZE} >= ${MEM_LIMIT}" | bc`
else
	export MEM_DIFF=`echo "${MEM_USIZE} >= ${OS_CUSTOM_MEM_LIMIT}" | bc`
fi

if [ ! -z ${OS_CUSTOM_DISK_LIMIT} ]
then
	export FS_LIMIT=`echo "${OS_CUSTOM_DISK_LIMIT}"`
fi


if [ ${LOAD_DIFF} -eq 1 ]
then
        echo "[ STAT_FAIL ] Hi Loadaverage, Latency time of all process increased !!! : LOAD ${LOAD_AVERAGE} (${CPU_CORE} Core System)"
        echo "${LOG_DATE} [ STAT_FAIL ] Hi Loadaverage Latency time of all process increased !!! : LOAD ${LOAD_AVERAGE} (${CPU_CORE} Core System)" >> ${SYS_LOG}
elif [ ${CPU_DIFF} -eq 1 ]
then
	echo "[ STAT_FAIL ] CPU Busy !!! [ CPU ] : ${CPU_USAGE} % [ MEM ] : ${MEM_USIZE} % [ System Load ] : ${LOAD_AVERAGE} (${CPU_CORE} Core System)"
	echo "${LOG_DATE} [ STAT_FAIL ] CPU Busy !!! [ CPU ] : ${CPU_USAGE} % [ MEM ] : ${MEM_USIZE} % [ System Load ] : ${LOAD_AVERAGE} (${CPU_CORE} Core System)" >> ${SYS_LOG}
elif [ ${MEM_DIFF} -eq 1 ]
then
	echo "[ STAT_FAIL ] MEM Busy !!! [ MEM ] : ${MEM_USIZE} % [ CPU ] : ${CPU_USAGE} % [ System Load ] : ${LOAD_AVERAGE} (${CPU_CORE} Core System)"
	echo "${LOG_DATE} [ STAT_FAIL ] MEM Busy !!! [ MEM ] : ${MEM_USIZE} % [ CPU ] : ${CPU_USAGE} % [ System Load ] : ${LOAD_AVERAGE} (${CPU_CORE} Core System)" >> ${SYS_LOG}
else
        echo "[ OK ] System Resouce OK. [ CPU ] : ${CPU_USAGE} % [ MEM ] : ${MEM_USIZE} % [ System Load ] : ${LOAD_AVERAGE} (${CPU_CORE} Core System)"
fi

}


FUNCT_CHECK_PW_EXPRIE() {

################################
### 3. Check Password Exprie ###
################################

PW_EXPIRES_CHECK=0

declare -a ARRAY_LIMIT_USER
USER_LIST=`cat /etc/passwd | grep -v "operator" | cut -d ":" -f 1`

for LIST in ${USER_LIST};
do
	CHECK_LIMIT_USER=`chage -l ${LIST} | grep -i "password expires" | grep -i never | wc -l`
	if [ ${CHECK_LIMIT_USER} -eq 0 ];
	then
		ARRAY_LIMIT_USER=("${ARRAY_LIMIT_USER[@]}" "${LIST}")
	fi
done

DIFF_DATE() {
    TDAY=$(date -d "$1" +%s)
    CDAY=$(date -d "$2" +%s)
    DIFF_RESULT=`echo "(${TDAY} - ${CDAY}) / 86400" | bc`
}

LOOP_COUNT=0
LOOP_LIMIT=${#ARRAY_LIMIT_USER[@]}
while [ "${LOOP_COUNT}" -lt "${LOOP_LIMIT}" ]
do
	LIMIT_USER=${ARRAY_LIMIT_USER[${LOOP_COUNT}]}
	LAST_CHANGE_DAY=`chage -l ${LIMIT_USER} | grep "Last password change" | awk -F: '{print $2}' | sed 's#,##g' | awk '{print $2}'`
	LAST_CHANGE_MOON=`chage -l ${LIMIT_USER} | grep "Last password change" | awk -F: '{print $2}' | sed 's#,##g' | awk '{print $1}'`
	LAST_CHANGE_YEAR=`chage -l ${LIMIT_USER} | grep "Last password change" | awk -F: '{print $2}' | sed 's#,##g' | awk '{print $3}'`
	CHANGE_LIMIT_DAY=`chage -l ${LIMIT_USER}  | grep "Maximum number" | cut -d ":" -f 2 | sed 's# ##g'`
	INFO_DAYS=`echo "${CHANGE_LIMIT_DAY} - ${WARNING_DAYS}" | bc` 
	TO_DAYS=`date | awk '{print $2, $3, $6}'`

	DIFF_DATE "${TO_DAYS}" "${LAST_CHANGE_MOON} ${LAST_CHANGE_DAY} ${LAST_CHANGE_YEAR}"

	if [ ${DIFF_RESULT} -ge ${INFO_DAYS} ]
	then
		WDAY=`echo "${CHANGE_LIMIT_DAY} - ${DIFF_RESULT}" | bc`
		echo "[ STAT_FAIL ] Account Password Expires : ${LIMIT_USER} / ${WDAY} days left"
		echo "${LOG_DATE} [ STAT_FAIL ] Account Password Expires : ${LIMIT_USER} / ${WDAY} days left" >> ${SYS_LOG}
		export PW_EXPIRES_CHECK=1;
	fi 

	LOOP_COUNT=`echo "${LOOP_COUNT} + 1" | bc`
done

if [ ${PW_EXPIRES_CHECK} -eq 0 ];
then
	echo "[ OK ] All Account Password Not Expires."
fi

}


FUNCT_CHECK_NFS_MOUNT() {

##########################
### 4. Check NFS Mount ###
##########################

NFS_MOUNT_CHECK=0
NFS_LIST=`cat /etc/fstab | grep -v "#" | awk '$3 ~ /^nfs$/ {print $1}'`

for LIST in ${NFS_LIST}
do
        NFS_TARGET_DIR=`cat /etc/fstab | grep "^${LIST}" | awk '{print $2}'`
        CHECK_NFS_MOUNT=`cat /proc/mounts | grep -w "^${LIST}" | wc -l`
	CHECK_BOOSTFS=`cat /proc/mounts | grep "${NFS_TARGET_DIR}" | awk '$1 ~ /boostfs/ {print $0}' | wc -l`

	if [ ${CHECK_NFS_MOUNT} -eq 0 ]
	then
		if [ ${CHECK_BOOSTFS} -eq 0 ]
		then
			### NFS status is umounted
			echo "[ STAT_FAIL ] NFS Filesystem is Not Mount : NFS [ ${LIST} ] / Mount Dir [ ${NFS_TARGET_DIR} ]"
			echo "${LOG_DATE} [ STAT_FAIL ] NFS Filesystem is Not Mount : NFS [ ${LIST} ] / Mount Dir [ ${NFS_TARGET_DIR} ]" >> ${SYS_LOG}
			export NFS_MOUNT_CHECK=1;
		fi
	fi
done

if [ ${NFS_MOUNT_CHECK} -eq 0 ];
then
	echo "[ OK ] NAS or NFS Mount is OK."
fi;

}


FUNCT_CHECK_FS_READ_ONLY() {

#####################################
### 5. Check Filesystem Read-Only ###
#####################################

READ_ONLY_CHECK=0

for LIST in `df -hP | egrep -v "^tmpfs|^/dev/loop*" | awk '{print $NF}' | egrep -v '^/dev|on$|.snapshot|docker/overlay|kubelet/plugins'`; 
do
	CHECK=`touch ${LIST}/file_test 2>&1 | wc -l`; 
	
	if [ ${CHECK} -ge 1 ]; 
	then
		echo "[ STAT_FAIL ] Filesystem Read-Only Mount : ${LIST}"
		echo "${LOG_DATE} [ STAT_FAIL ] Filesystem Read-Only Mount : ${LIST}" >> ${SYS_LOG}
		export READ_ONLY_CHECK=1;
	fi; 
done; 

if [ ${READ_ONLY_CHECK} -eq 0 ]; 
then
	echo "[ OK ] All Filesystem Not Read-only."
fi;

}


FUNCT_CHECK_FS_USAGE() {

#################################
### 6. Check Filesystem Usage ###
#################################

CHECK_FS_USAGE_STATUS=0
FILESYS_LIST=`df -hP | egrep -v "^tmpfs|^/dev/loop*" | awk '{print $NF}' | egrep -v '^/dev|on$|/backup/|/boot/efi|docker/overlay'`

for LIST in ${FILESYS_LIST}
do
	CEHCK_FS_USAGE=`df -hP | grep -w "${LIST}$" | awk '{print $5}' | sed 's#%##g'`

	if [ ${CEHCK_FS_USAGE} -ge ${FS_LIMIT} ]
	then
		echo "[ STAT_FAIL ] Check Filesystem Usage : Mount Point [ ${LIST} ] / Usage [ ${CEHCK_FS_USAGE}% ]"
		echo "${LOG_DATE} [ STAT_FAIL ] Check Filesystem Usage : Mount Point [ ${LIST} ] / Usage [ ${CEHCK_FS_USAGE}% ]" >> ${SYS_LOG}
		export CHECK_FS_USAGE_STATUS=1
	fi
done

if [ ${CHECK_FS_USAGE_STATUS} -eq 0 ]
then
	echo "[ OK ] Filesystem Usage is OK."
fi

}


FUNCT_CHECK_INODE_USAGE() {

#######################################
### 7. Check inode Usage ###
#######################################

CHECK_INODE_USAGE_STATUS=0
FILESYS_LIST=`df -iP | egrep -v "^tmpfs|^/dev/loop*" | awk '{print $NF}' | egrep -v '^/dev|on$'`

for LIST in ${FILESYS_LIST}
do
	CEHCK_FS_USAGE=`df -iP | grep -w "${LIST}$" | awk '{print $5}' | sed 's#%##g'`

	if [ ${CEHCK_FS_USAGE} -ge ${INODE_LIMIT} ]
	then
		echo "[ STAT_FAIL ] Check inode Usage : Mount Point [ ${LIST} ] / Usage [ ${CEHCK_FS_USAGE}% ]"
		echo "${LOG_DATE} [ STAT_FAIL ] Check inode Usage : Mount Point [ ${LIST} ] / Usage [ ${CEHCK_FS_USAGE}% ]" >> ${SYS_LOG}
		export CHECK_INODE_USAGE_STATUS=1
	fi
done

if [ ${CHECK_INODE_USAGE_STATUS} -eq 0 ]
then
	echo "[ OK ] Inode Usage is OK."
fi

}


FUNCT_CHECK_FS_MOUNT_STAT() {

#############################
### 8. Check Mount Status ###
#############################

FILESYS_LIST=`cat /etc/fstab | egrep -v '^#' | awk '{print $2}' | egrep -xv '/dev/shm|/dev/pts|/sys|/proc|swap|none' | grep -v '^$'`

FILESYS_MOUNT_STATUS=0

for LIST in ${FILESYS_LIST}
do
	CHECK_SWAP=`cat /etc/fstab | grep "${LIST}" | awk '{print $3}' | grep -x swap | wc -l`

	if [ ${CHECK_SWAP} -eq 1 ]
	then
		CHECK_SWAP_STATUS=`swapon -s | wc -l`

		if [ ${CHECK_SWAP_STATUS} -eq 0 ]
		then
			FILESYS_MOUNT_STATUS=1
			echo "[ STAT_FAIL ] SWAP PARTITON not mounted."
		fi
	else
		CHECK_FILESYS_MOUNT=`mount | awk '{print $3}' | grep -x "${LIST}" | wc -l`

		if [ ${CHECK_FILESYS_MOUNT} -ne 1 ]
		then
			FILESYS_MOUNT_STATUS=1
			DEVICE_NAME=`grep -w "${LIST}" /etc/fstab  | awk '{print $1}'`
			echo "[ STAT_FAIL ] Filesystem ${LIST} (${DEVICE_NAME}) not mounted."
		fi
	fi
done

if [ ${FILESYS_MOUNT_STATUS} -eq 0 ]
then
        echo "[ OK ] Filesystem Mount Status OK."
fi

}


FUNCT_CHECK_LVM_STAT() {

###########################
### 9. Check LVM Status ###
###########################

CHECK_LVM_STATUS=0

CHECK_LV_IO_ERROR=`lvscan 2>&1 | grep -i "Input/output error" | wc -l`

if [ ${CHECK_LV_IO_ERROR} -ne 0 ]
then
	echo "[ STAT_FAIL ] LVM IO Error"
	lvscan 2>&1 | grep -i "Input/output error"
	echo "${LOG_DATE} `lvscan 2>&1 | grep -i "Input/output error"`" >> ${SYS_LOG}
	export CHECK_LVM_STATUS=1
else
	LV_LIST=`lvscan 2>&- | awk '{print $2}' | sed "s#'##g"`

	for LIST in ${LV_LIST}
	do
		CEHCK_LVM=`lvscan | grep "${LIST}" | grep -i "inactive" | wc -l`
	
		if [ ${CEHCK_LVM} -ne 0 ]
		then
			echo "[ STAT_FAIL ] Need to Check : Volume [ ${LIST} ] / Status : inactive ]"
			echo "${LOG_DATE} [ STAT_FAIL ] Need to Check : Volume [ ${LIST} ] / State : inactive ]" >> ${SYS_LOG}
			export CHECK_LVM_STATUS=1
		fi
	done
fi

if [ ${CHECK_LVM_STATUS} -eq 0 ]
then
	echo "[ OK ] LVM Status OK."
fi

}


FUNCT_CHECK_MULTIPATH_STAT() {

##################################################################
### 10. Check Native Multipathd Status ###
##################################################################

CHECK_MULTIPATHD=`systemctl -t service --state=active | grep multipathd | wc -l`

if [ ${CHECK_MULTIPATHD} -eq 0 ]
then
	echo "[ OK ] Not Used Multipathd"
else
	STAT_MULTIPATH=`multipath -v3 | sed -n '/paths list/,$p' | grep "transport-offline" | wc -l`
	
	if [ ${STAT_MULTIPATH} -eq 0 ];
	then
		echo "[ OK ] Multipath Status OK"
	else
		echo "[ STAT_FAIL ] Need to Check Multipath"
		multipath -v3 | sed -n '/paths list/,$p' | grep "transport-offline"
	fi
fi

}


FUNCT_CHECK_USED_ETH() {

##################################################################
### 11. Check Used Network Interface ###
##################################################################

OS_USED_ETH=`/usr/sbin/ip a | grep -w inet | egrep -v "lo$|docker_gwbridge|docker0|br-|virbr|cali|veth|tunl0|cilium_|lxc|dummy|nodelocal" | awk '{print $NF}'`
ETH_STAT_CODE=0

for LIST in ${OS_USED_ETH}
do
	CHECK_ETH_STAT=`/usr/sbin/ip a | awk '$2 ~ /'"${LIST}"'/ {print $9}' | grep -i down | wc -l`

	if [ ${CHECK_ETH_STAT} -gt 0 ]
	then
		echo "[ STAT_FAIL ] Used Ethernet Link Down : ${LIST}"
		export ETH_STAT_CODE=1	
	fi
done

if [ ${ETH_STAT_CODE} ]
then
	echo "[ OK ] Used Ethernet All OK"
fi

}


FUNCT_CHECK_BOND_ETH() {

##################################################################
### 12. Check Bonding Network Interface ###
##################################################################

BONDING_USED_CHECK=`ls -1 /proc/net/ | grep "bonding" | wc -l`

if [ ${BONDING_USED_CHECK} -gt 0 ]
then
	BONDING_LIST=`ls -1 /proc/net/bonding/`
	BONDING_STAT_CODE=0
	
	for LIST in ${BONDING_LIST}
	do
		BOND_INT_CHECK=`/usr/sbin/ip a | awk '$9 ~ /^'"${LIST}"'/ {print $2"\t"$11}' | grep DOWN | wc -l`

		if [ ${BOND_INT_CHECK} -ne 0 ]
		then
			DOWN_INTERFACE=`/usr/sbin/ip a | awk '$9 ~ /^'"${LIST}"'/ {print $2 $11}' | grep DOWN`
			echo "[ STAT_FAIL ] Bonding Interface ${DOWN_INTERFACE} [${LIST}]"

			export BONDING_STAT_CODE=1
		fi
	done

	if [ ${BONDING_STAT_CODE} -eq 0 ]
	then
		echo "[ OK ] Network Bonding Interface OK."
	fi
else
	echo "[ OK ] Network Bonding Not Used."
fi

}


FUNCT_CHECK_ALL_ETH() {

##################################################################
### 13. Check All Network Interface Link & Packet Error Status ###
##################################################################

INTERFACE_LIST=`/usr/sbin/ip a | grep -w mtu | cut -d ":" -f 2 | egrep -v 'lo$|docker_gwbridge|docker0|br-|virbr|cali|veth|tunl0|cilium_|lxc|dummy|nodelocal'`

echo "[ Ethernet ] All Network Interface Status"
echo

for LIST in ${INTERFACE_LIST}
do
	echo "${LIST} : `ethtool ${LIST} | egrep -i 'speed|link detected'`" && echo
done

}


FUNCT_CHECK_DISK_IO() {

##################################################################
### 14. Disk IO Status ###
##################################################################

dstat --time -l --disk-util -r --top-io --top-cputime --nfs3 1 5
echo

}


### FUNCTION CALL ###

FUNCT_CHECK_USER

	echo
	echo "[  OS Check Result ]"
	echo "[ Script Version ] : ${SCRIPT_VERSION}"

	CHECK_PLATFORM=`dmidecode -t system | grep -i product | cut -d : -f 2 | sed 's#^ *##g'`
	echo "[ Platform ] : ${CHECK_PLATFORM}"

FUNCT_CHECK_OS_VERSION
FUNCT_CHECK_SYS_RESOURCE
FUNCT_CHECK_PW_EXPRIE
FUNCT_CHECK_NFS_MOUNT
FUNCT_CHECK_FS_READ_ONLY
FUNCT_CHECK_FS_USAGE
FUNCT_CHECK_INODE_USAGE
FUNCT_CHECK_FS_MOUNT_STAT
FUNCT_CHECK_LVM_STAT
FUNCT_CHECK_MULTIPATH_STAT
FUNCT_CHECK_USED_ETH
FUNCT_CHECK_BOND_ETH
FUNCT_CHECK_ALL_ETH
FUNCT_CHECK_DISK_IO
