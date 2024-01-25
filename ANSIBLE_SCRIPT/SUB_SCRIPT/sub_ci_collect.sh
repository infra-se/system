#!/bin/bash
#Script made by  helperchoi@gmail.com
SCRIPT_DESCRIPTION="CI Collect Script"
SCRIPT_VERSION=0.4.20240125

export LANG=C
export LC_ALL=C

#########################
#### COMMON FUNCTION ####
#########################

FUNCT_CHECK_OS() {
	export OS_FAMILY=`awk '{print $1, $2}' /etc/system-release | sed 's#Linux##' | sed 's#release##' | sed 's# $##'`
	export OS_VER=`grep -o "release [0-9]\{1\}.[0-9]*" /etc/system-release | awk '{print $2}'`
	export KER_VER=`uname -r`
}

FUNCT_CHECK_PLATFORM() {
	export CHECK_VENDOR=`dmidecode -t system | grep -i "Manufacturer" | cut -d : -f 2 | sed 's#^ *##g'`
	export CHECK_PLATFORM=`dmidecode -t system | grep -i "Product Name" | cut -d : -f 2 | sed 's#^ *##g'`
}

FUNCT_CHECK_PERM() {
	TARGET_LIST=$1
	CHECK_PERM=`stat -c '%a' ${TARGET_LIST}`
	CHECK_OWNER=`stat -c '%U' ${TARGET_LIST}`
	CHECK_GROUP=`stat -c '%G' ${TARGET_LIST}`
	export CHECK_PERM_VAL=${CHECK_FILE_PERM}
	export CHECK_OWNER_VAL=${CHECK_OWNER}
	export CHECK_GROUP_VAL=${CHECK_GROUP}
	export CHECK_PERM_ALL="${CHECK_PERM}:${CHECK_OWNER}:${CHECK_GROUP}"
}

FUNCT_CHECK_PACKAGE() {
	TARGET_LIST=$1
	CHECK_PACKAGE=`rpm -qi ${TARGET_LIST} | grep -i "not install" | wc -l`
	if [ ${CHECK_PACKAGE} -eq 1 ]
	then
		export CHECK_RESULT=1	
	else
		export CHECK_RESULT=0	
	fi
}

FUNCT_NATIVE_DATE() {
	date -d "@$1" "+%Y%m%d"
}

FUNCT_UNIX_DATE() {
	date -d "$1" +%s
}

INSTALL_DATE_UNIXTIME=`rpm -qa --qf '%{installtime}\n' coreutils`
INSTALL_DATE_NATIVE=`FUNCT_NATIVE_DATE ${INSTALL_DATE_UNIXTIME}`
CAL_INSTALL_DATE=`FUNCT_UNIX_DATE ${INSTALL_DATE_NATIVE}`
TODAY_UNIXTIME=`date -d "now" +%s`
TODAY_NATIVE=`date -d "now" +%Y%m%d`
CAL_TODAY=`FUNCT_UNIX_DATE ${TODAY_NATIVE}`
CUMULATION_DATE=`echo "${CAL_INSTALL_DATE} ${CAL_TODAY}" | awk '{print ($2 - $1) / 86400}'`

FUNCT_CHECK_OS
FUNCT_CHECK_PLATFORM


##################################
#### CI COLLECT MAIN FUNCTION ####
##################################

FUNCT_CI_COLLECT_01() {
FUNCT_CATEGORY=CI_SHEET_01

	CPU_MODEL=`grep "model name" /proc/cpuinfo | head -1 | cut -d ":" -f2 | sed 's#^ ##'` 
	CPU_COUNT=`grep -c "processor" /proc/cpuinfo`
	MEM_SIZE=`grep "MemTotal" /proc/meminfo | awk '{print $2 / 1024 / 1024}'`
	
	DISK_SUM_MB=0
	LOCAL_IP_LIST=`ip a | grep -w inet | awk '{print $2}' | cut -d "/" -f1 | xargs -i echo -n "^{}:|"`
	for LIST in `df -mP | egrep -vi "${LOCAL_IP_LIST}^filesystem|devtmpfs|tmpfs|/dev/sr0|/dev/loop*|overlay|^shm" | awk '{print $2}'`
	do
		#export DISK_SUM_MB=`echo "${DISK_SUM_MB} + ${LIST}" | bc`
		export DISK_SUM_MB=`echo "${DISK_SUM_MB} ${LIST}" | awk '{print $1 + $2}'`
	done

	#DISK_SUM=`echo "${DISK_SUM_MB} / 1024" | bc`
	DISK_SUM=`echo "${DISK_SUM_MB} 1024" | awk '{print $1 / $2}'`

	echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${INSTALL_DATE_NATIVE}|${CHECK_VENDOR}|${CHECK_PLATFORM}|${OS_FAMILY}|${OS_VER}|${KER_VER}|${CPU_MODEL}|${CPU_COUNT}|${MEM_SIZE}|${DISK_SUM}"
}


FUNCT_CI_COLLECT_02() {
FUNCT_CATEGORY=CI_SHEET_02

	M_POINT_LIST=`df -mTP | egrep -vi '^filesystem|devtmpfs|tmpfs|/dev/sr0|/dev/loop*' | awk '{print $NF}'`

	for MOUNT_POINT in ${M_POINT_LIST}
	do
		DISK_DEVICE=`df -mTP | grep "${MOUNT_POINT}$" | awk '{print $1}'`
		FS_TYPE=`df -mTP | grep "${MOUNT_POINT}$" | awk '{print $2}'`
		DISK_SIZE_GB=`df -mTP | grep "${MOUNT_POINT}$" | awk '{print $3 / 1024}'`

		if [ ${FS_TYPE} == "nfs" -o ${FS_TYPE} == "nfs4" ]
		then
			export DISK_TYPE="nas"

		elif [ ${FS_TYPE} == "overlay" ]
		then
			export DISK_TYPE="overlayFS"

		elif [ ${FS_TYPE} == "fuse.mfs" ]
		then
			export DISK_TYPE="fuse.mfs"

		else
			export DISK_TYPE=`lsblk -o MOUNTPOINT,TYPE | grep "^${MOUNT_POINT}" | uniq | awk '{print $2}' | head -1`
		fi

		if [ ${DISK_TYPE} == "part" -o ${DISK_TYPE} == "disk" ]
		then
			DEVICE_BASENAME=`basename ${DISK_DEVICE}`
			CHECK_SAN=`ls -l /dev/disk/by-path/ | awk '$NF ~ /'"${DEVICE_BASENAME}"'$/ {print $9}' | egrep '\-fc\-|iscsi' | wc -l`

			if [ ${CHECK_SAN} -eq 1 ]
			then
				export SCSI_PATH=`ls -l /dev/disk/by-path/ | awk '$NF ~ /'"${DEVICE_BASENAME}"'$/ {print $9}'`
			else
				export SCSI_PATH="INTERNAL"
			fi
		elif [ ${DISK_TYPE} == "nas" ]
		then
			export SCSI_PATH="${DISK_DEVICE}"	
		else
			export SCSI_PATH="N/A"
		fi

		USED_SIZE_MB=`df -mTP | grep "${MOUNT_POINT}$" | awk '{print $4}'`
		DAILY_CUMULATION=`echo "${USED_SIZE_MB} ${CUMULATION_DATE}" | awk  '{print $1 / $2}'`

		FUNCT_CHECK_PERM ${MOUNT_POINT}
		echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${CHECK_PLATFORM}|${MOUNT_POINT}|${CHECK_PERM_ALL}|${DISK_DEVICE}|${FS_TYPE}|${DISK_SIZE_GB}|${DISK_TYPE}|${USED_SIZE_MB}|${CUMULATION_DATE}|${DAILY_CUMULATION}"

	done
}


FUNCT_CI_COLLECT_03() {
FUNCT_CATEGORY=CI_SHEET_03

	ACCOUNT_LIST=`egrep -v "^root|nologin$|false$|shutdown$|halt$|sync$" /etc/passwd | cut -d ":" -f 1`

	for A_LIST in ${ACCOUNT_LIST}
	do
		ACCOUNT=${A_LIST}
		ACCOUNT_UID=`id -u ${A_LIST}`
		ACCOUNT_GID=`id -g ${A_LIST}`
		ACCOUNT_GIDS=`id -G ${A_LIST}`
		HOME_DIR=`awk -F ":" '$1 ~ /^'"${A_LIST}"'$/ {print $6}' /etc/passwd`
		SHELL_PATH=`awk -F ":" '$1 ~ /^'"${A_LIST}"'$/ {print $7}' /etc/passwd`

		echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${ACCOUNT}|${ACCOUNT_UID}|${ACCOUNT_GID}|${ACCOUNT_GIDS}|${HOME_DIR}|${SHELL_PATH}"
	done
}


FUNCT_CI_COLLECT_04() {
FUNCT_CATEGORY=CI_SHEET_04

	declare -a ARRAY_PROCESS_INFO
	TMP_PROC_LIST=/tmp/proc.list
	
	#### CREATE PROCESS INFO ####
	ps -eo pid,user:20,cmd | egrep -v 'CMD|grep|awk|ps|-bash|ansible' | awk '{print $1, $2, $3, $4, $5, $6, $7, $8}' > ${TMP_PROC_LIST}
	
	while read LIST
	do
		PROCESS_PID=`echo "${LIST}" | awk '{print $1}'`
		PROCESS_OWN=`echo "${LIST}" | awk '{print $2}'`
		PROCESS_CMD=`echo "${LIST}" | awk '{ for(i=3;i<=NF;i++) printf("%s ", $i); printf("\n") }'`

		ARRAY_PROCESS_INFO=("${ARRAY_PROCESS_INFO[@]}" "`echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${PROCESS_OWN}|${PROCESS_CMD}"`")	
	done < ${TMP_PROC_LIST}

	printf "%s\n" "${ARRAY_PROCESS_INFO[@]}"
	unset ARRAY_PROCESS_INFO
}


FUNCT_CI_COLLECT_05() {
FUNCT_CATEGORY=CI_SHEET_05

	IP_CMD_PATH=`which ip`
	LINK_UP_INTERFACE=`ifconfig | grep "^[a-z]" | egrep -v "lo|docker_gwbridge|docker0|br-|virbr|cali|veth|tunl0|cilium_|lxc|dummy|nodelocal" | awk '{print $1}'`

	for LIST in ${LINK_UP_INTERFACE}
	do
		CHECK_ETH_NAME=`echo ${LIST} | grep ":$" | wc -l`
	
		if [ ${CHECK_ETH_NAME} -gt 0 ] 
		then
			DELETE_COLON=`echo ${LIST} | sed 's#.$##'`
			export LIST=${DELETE_COLON}
		fi
	
		### CHECK ETHERNET TYPE ###
		CHECK_ETHERNET=`echo ${LIST} | grep "bond" | wc -l`
		CHECK_ALIASNET=`echo ${LIST} | grep ":" | wc -l`
	
		if [ ${CHECK_ETHERNET} -eq 1 ]
		then
			export ETH_TYPE_NO=1
			export ETH_TYPE=MASTER
		elif [ ${CHECK_ALIASNET} -eq 1 ]
		then
			export ETH_TYPE_NO=3
			export ETH_TYPE=ALIAS
		else
			CHECK_SLAVE_ETH=`${IP_CMD_PATH} a show ${LIST} | grep "^[0-9]" | awk '{print $8,$9}' | grep "master" | wc -l`
	
			if [ ${CHECK_SLAVE_ETH} -eq 1 ]
			then
				export ETH_TYPE_NO=2
			else
				export ETH_TYPE_NO=0
				export ETH_TYPE=SINGLE
			fi
		fi
	
		### CHECK MAC ADDRESS ###	
		if [ ${ETH_TYPE_NO} -eq 0 -o ${ETH_TYPE_NO} -eq 1 -o ${ETH_TYPE_NO} -eq 3 ]
		then
			export MAC_ADDRESS=`${IP_CMD_PATH} a show ${LIST} | grep -w "link/ether" | awk '{print $2}'`	
	
		elif [ ${ETH_TYPE_NO} -eq 2 ]
		then
			BOND_NAME=`${IP_CMD_PATH} a show ${LIST} | grep -w "${LIST}" | awk '{print $9}'`
			export MAC_ADDRESS=`cat /proc/net/bonding/${BOND_NAME} | grep -A5 "Slave Interface: ${LIST}" | grep "Permanent HW addr" | cut -d : -f 2- | tr -d ' '`
			ETH_MASTER=`${IP_CMD_PATH} a show ${LIST} | awk '$2 ~ /'"${LIST}"'/ {print $9}'`
			export ETH_TYPE="SLAVE:${ETH_MASTER}"
		fi
	

		### CHECK IP ADDRESS ###
		CHECK_IP_ADDRESS=`${IP_CMD_PATH} a show ${LIST} | grep -w "inet" | awk '{print $2}' | wc -l`

		if [ ${CHECK_IP_ADDRESS} -gt 0 ]
		then
			export IP_ADDRESS=`${IP_CMD_PATH} a show ${LIST} | grep -w "inet" | grep -w "${LIST}" | awk '{print $2}' | head -1`
		else
			export IP_ADDRESS=N/A
		fi

		CHECK_LINK_STAT=`${IP_CMD_PATH} a show ${LIST} | awk '{print $9, $11}' | head -1 | awk '{print $1}'`

		echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${CHECK_PLATFORM}|${LIST}|${MAC_ADDRESS}|${IP_ADDRESS}|${ETH_TYPE}|${CHECK_LINK_STAT}"
	done
}


FUNCT_CI_COLLECT_06() {
FUNCT_CATEGORY=CI_SHEET_06

	declare -a ARRAY_SESSION_INFO
	TMP_PROC_LIST=/tmp/session.list
	
	#### CREATE SESSION INFO ####
	netstat -nap | egrep '^tcp' | awk '{print $1"\t"$5"\t"$4"\t"$6"\t"$7}' > ${TMP_PROC_LIST}
	
	while read LIST
	do
		PROTOCAL=`echo "${LIST}" | awk '{print $1}'`
		SOURCE=`echo "${LIST}" | awk '{print $2}'`
		DESTINATION=`echo "${LIST}" | awk '{print $3}'`
		SESSION_STAT=`echo "${LIST}" | awk '{print $4}'`
		PROCESS_INFO=`echo "${LIST}" | awk '{print $5}'`

		ARRAY_SESSION_INFO=("${ARRAY_SESSION_INFO[@]}" "`echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${PROTOCAL}|${SOURCE}|${DESTINATION}|${SESSION_STAT}|${PROCESS_INFO}"`")	
	done < ${TMP_PROC_LIST}

	printf "%s\n" "${ARRAY_SESSION_INFO[@]}"
	unset ARRAY_SESSION_INFO
}


FUNCT_CI_COLLECT_07() {
FUNCT_CATEGORY=CI_SHEET_07

	FUNCT_CHECK_PACKAGE gcc
	if [ ${CHECK_RESULT} -eq 1 ]
	then
		GCC_VER="N/A"
	else
		GCC_VER=`rpm -qi gcc | grep "Version" | awk '{print $3}' | head -1`
	fi

	CHECK_ACTIVE_JAVA=`ps -ef | grep -v grep | grep java | wc -l`
	GLIBC_VER=`rpm -qi glibc | grep "Version" | awk '{print $3}' | head -1`
	OPENSSL_VER=`rpm -qi openssl | grep "Version" | awk '{print $3}' | head -1`

	if [ ${CHECK_ACTIVE_JAVA} -eq 0 ]
	then
		CHECK_DEF_JDK=`rpm -qa | grep openjdk | wc -l`
		if [ ${CHECK_DEF_JDK} -eq 0 ]
		then
			ENABLE_JDK="N/A"
		else
			DEFAULT_JDK_LIST=`rpm -qa | grep openjdk | cut -d "-" -f1-3 | sort -u | sort -nrk 1 | head -1`
			ENABLE_JDK=`rpm -qi ${DEFAULT_JDK_LIST} | grep "Version" | awk '{print $3}'`
		fi

		echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${CHECK_PLATFORM}|${OS_FAMILY}|${OS_VER}|${ENABLE_JDK}|${GCC_VER}|${GLIBC_VER}|${OPENSSL_VER}"
	else
		declare -a ARRAY_JDK_LIST

		ACTIVE_JDK_PID=`ps -ef | grep -v grep | awk '$8 ~ /java/ {print $2}'`
		for LIST in ${ACTIVE_JDK_PID} 
		do
			JDK_PATH=`ls -l /proc/${LIST}/exe | awk '{print $NF}'`
			ENABLE_JDK=`${JDK_PATH} -version 2>&1 | grep version | cut -d '"' -f2`

			if [ -z ${ENABLE_JDK} ]
			then
				export ENABLE_JDK="N/A"
			fi
		
			export ARRAY_JDK_LIST=("${ARRAY_JDK_LIST[@]}" "${ENABLE_JDK}")
		done

		SORT_UNIQ_JDK=`printf "%s\n" "${ARRAY_JDK_LIST[@]}" | sort -u | uniq`
		for ENABLE_JDK in ${SORT_UNIQ_JDK}
		do
			echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${CHECK_PLATFORM}|${OS_FAMILY}|${OS_VER}|${ENABLE_JDK}|${GCC_VER}|${GLIBC_VER}|${OPENSSL_VER}"
		done
	fi
}

FUNCT_CI_COLLECT_08() {
FUNCT_CATEGORY=CI_SHEET_08

	DIREC_LIST=`find / -maxdepth 1 -type d | egrep -iv "^/$|^/boot$|^/proc$|^/dev$|^/run$|^/sys$|^/etc$|^/bin$|^/sbin$|^/lib$|^/lib64$|^/root$|^/var$|^/tmp$|^/usr$|^/media$|^/mnt$|^/srv$|^/opt$|^/lost\+found$"`

	for LIST in ${DIREC_LIST}
	do
		FILE_COUNT=`ls -AlR ${LIST} | egrep -v ':$|^total|^$|^d' | wc -l`
	        USED_SIZE=`du -sh ${LIST} | awk '{print $1}'`
	        MOUNT_CHECK=`df -hTP | grep "${LIST}$" | wc -l`

		if [ ${MOUNT_CHECK} -eq 0 ]
	        then
	                export M_POINT_SIZE=`df -hTP / | grep -vi "filesystem" | awk '{print $3}'`
	                export M_USED_SIZE=`df -hTP / | grep -vi "filesystem" | awk '{print $4}'`
	                export M_POINT="/"
	        else
	                export M_POINT_SIZE=`df -hTP ${LIST} | grep -vi "filesystem" | awk '{print $3}'`
	                export M_USED_SIZE=`df -hTP ${LIST} | grep -vi "filesystem" | awk '{print $4}'`
	                export M_POINT="${LIST}"
	        fi

	        echo "[CHECK_RESULT] ${FUNCT_CATEGORY}|${HOSTNAME}|${M_POINT}|${M_POINT_SIZE}|${M_USED_SIZE}|${LIST}|${USED_SIZE}|${FILE_COUNT}"
	done
}


######################
#### RUN FUNCTION ####
######################

FUNCT_CI_COLLECT_01
FUNCT_CI_COLLECT_02
FUNCT_CI_COLLECT_03
FUNCT_CI_COLLECT_04
FUNCT_CI_COLLECT_05
FUNCT_CI_COLLECT_06
FUNCT_CI_COLLECT_07
FUNCT_CI_COLLECT_08
