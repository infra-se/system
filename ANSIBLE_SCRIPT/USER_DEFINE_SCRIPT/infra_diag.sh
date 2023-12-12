#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.1.20231120

export LANG=C
export LC_ALL=C

FUNCT_CHECK_SWAP() {
	CHECK_SWAP=`swapon -s`

	if [ -z "${CHECK_SWAP}" ]
	then
		export CHECK_RESULT=1
	else
		export CHECK_RESULT=0
	fi

	if [ ${CHECK_RESULT} -eq 0 ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|Availability|SWAP_USED|OK|"
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|Availability|SWAP_USED|NOT_OK|"
	fi
}


FUNCT_CHECK_OOM_SCORE() {
	TARGET_PROCESS="altibase oracle mysqld postgres cub"
	OOM_SCORE_STAT=0

	for LIST in ${TARGET_PROCESS}
	do
		MAINTENANCE_PID_LIST=`ps -eL | awk '$5 ~ /'"${LIST}"'/ {print $2}' | sort -u | uniq`
		CHECK_TARGET=`ps -eL | awk '$5 ~ /'"${LIST}"'/ {print $2}' | sort -u | uniq | wc -l`

 		if [ ${CHECK_TARGET} -gt 0 ]
 		then
			for PID_LIST in ${MAINTENANCE_PID_LIST}
			do
      	                	### OOM Score Except ###
				CHECK_OOM_SCORE=`cat /proc/${PID_LIST}/oom_score_adj`

				if [ ${CHECK_OOM_SCORE} != "-1000" ]
				then
					export OOM_SCORE_STAT=1
					echo "[CHECK_RESULT] ${HOSTNAME}|Availability|OOM_SCORE|NOT_OK|${LIST}(PID:${PID_LIST})"
				else
					echo "[CHECK_RESULT] ${HOSTNAME}|Availability|OOM_SCORE|OK|${LIST}(PID:${PID_LIST})"
				fi
			done
		fi
	done

	if [ ${OOM_SCORE_STAT} -eq 0 ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|Availability|OOM_SCORE|OK|"
	fi
}

FUNCT_CHECK_MOUNT_POINT() {
	DIREC_LIST=`find / -maxdepth 1 -type d | egrep -iv "^/$|^/boot$|^/proc$|^/dev$|^/run$|^/sys$|^/etc$|^/root$|^/var$|^/tmp$|^/usr$|^/media$|^/mnt$|^/srv$|^/opt$|^/lost\+found$|^/.python-eggs$|^/home$"`

	for LIST in ${DIREC_LIST}
	do
     	 	MOUNT_CHECK=`df -hTP | grep "${LIST}$" | wc -l`
     	 	if [ ${MOUNT_CHECK} -eq 0 ]
      		then
	                export M_POINT="/"
	        else
		        export M_POINT="${LIST}"
  		fi

		if [ ${M_POINT} == ${LIST} ]
		then
			echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|DEDI_VOLUME|OK|${LIST}"
		else
			echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|DEDI_VOLUME|NOT_OK|${LIST}"
		fi
	done
}

FUNCT_CHECK_SYSSTAT() {
	CHECK_SYSSTAT_PKG=`rpm -qi sysstat | grep -i "not install" | wc -l`

	if [ ${CHECK_SYSSTAT_PKG} -eq 0 ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|INSTALL_SYSSTAT|OK|"
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|INSTALL_SYSSTAT|NOT_OK|"
	fi
}

FUNCT_CHECK_SAR_SCHEDULE() {
	CHECK_SAR_SCHD=`cat /etc/cron.d/sysstat | grep -v "^#" | grep "sa/sa1" | awk '{print $1}'`

	if [ "${CHECK_SAR_SCHD}" == "*/10" ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|SAR_COLLECT|NOT_OK|"
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|ManagementStandard|SAR_COLLECT|OK|"
	fi
}


FUNCT_CHECK_MYSQL_VOL() {
	CHECK_MYSQLD=`ps -ef | grep -v grep | grep mysql | grep "datadir" | wc -l`

	if [ ${CHECK_MYSQLD} -eq 0 ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|Scalability|INDEPENDENT_MYSQL_DATA_VOL|N/A|"
	else
		MYSQL_DATA_DIR=`ps -ef | grep -v grep | grep mysql | grep "datadir" | awk  -F "--datadir=" '{print $2}' | awk '{print $1}' | sort -u | uniq`
		DATA_PATH_COUNT=`ps -ef | grep -v grep | grep mysql | grep "datadir" | awk  -F "--datadir=" '{print $2}' | awk '{print $1}' | sort -u | uniq | grep -o "/" | wc -w`
		STOP_NO=`echo "${DATA_PATH_COUNT}" | awk '{print $1 + 1}'`
		CHECK_STAT=0

		for(( START_NO=2; START_NO <= STOP_NO; START_NO++ )) 
		do
			VOLUME_PATH=`echo "${MYSQL_DATA_DIR}" | cut -d "/" -f1-${START_NO}`
			CHECK_VOL_MOUNT=`df -hTP | grep "${VOLUME_PATH}$" | wc -l`
			
			if [ ${CHECK_VOL_MOUNT} -gt 0 ]
			then
				export CHECK_STAT=1
			fi
		done

		if [ ${CHECK_STAT} -eq 0 ]
		then
			echo "[CHECK_RESULT] ${HOSTNAME}|Scalability|INDEPENDENT_MYSQL_DATA_VOL|NOT_OK|${MYSQL_DATA_DIR}"		
		else
			echo "[CHECK_RESULT] ${HOSTNAME}|Scalability|INDEPENDENT_MYSQL_DATA_VOL|OK|${MYSQL_DATA_DIR}"		
		fi
	fi
}

FUNCT_CHECK_TCP_PARAM() {
	CHECK_VIRT_PLATFORM=`dmidecode -s system-product-name 2>&- | egrep -i 'virt|kvm|xen|VMware Virtual Platform' | wc -l`

	if [ ${CHECK_VIRT_PLATFORM} -eq 0 ]
	then
		ETHERNET_LIST=`ip a | grep -w inet | grep -v "lo$" | awk '{print $NF}'`

		for LIST in ${ETHERNET_LIST}
		do
			CHECK_TSO_STAT=`ethtool --show-offload ${LIST} | grep "tcp-segmentation-offload:" | awk '{print $2}'`

			if [ ${CHECK_TSO_STAT} == "on" ]
			then
				echo "[CHECK_RESULT] ${HOSTNAME}|Performance|TCP_SEG_OFFLOAD|NOT_OK|DEDI|${LIST}"
			else
				echo "[CHECK_RESULT] ${HOSTNAME}|Performance|TCP_SEG_OFFLOAD|OK|DEDI|${LIST}"
			fi
		done
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|Performance|TCP_SEG_OFFLOAD|N/A|VM"
	fi
}

FUNCT_CHECK_TCP_REASSEMBLY_MEM() {
	PARAM_VALUES1=`cat /proc/sys/net/ipv4/ipfrag_high_thresh`
	PARAM_VALUES2=`cat /proc/sys/net/ipv4/ipfrag_low_thresh`
	RECOMMEND="16777216"

	if [ ${PARAM_VALUES1} -eq ${RECOMMEND} ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|Performance|PACKET_REASSEMBLY_HIGH_MEM|OK|${PARAM_VALUES1}"
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|Performance|PACKET_REASSEMBLY_HIGH_MEM|NOT_OK|${PARAM_VALUES1}/RECOMMEND:${RECOMMEND}(byte)"
		#echo "[ Need ] sysctl -w net.ipv4.ipfrag_high_thresh=${RECOMMEND}" 
	fi

	if [ ${PARAM_VALUES2} -eq ${RECOMMEND} ]
	then
		echo "[CHECK_RESULT] ${HOSTNAME}|Performance|PACKET_REASSEMBLY_LOW_MEM|OK|${PARAM_VALUES2}"
	else
		echo "[CHECK_RESULT] ${HOSTNAME}|Performance|PACKET_REASSEMBLY_LOW_MEM|NOT_OK|${PARAM_VALUES2}/RECOMMEND:${RECOMMEND}(byte)"
		#echo "[ Need ] sysctl -w net.ipv4.ipfrag_low_thresh=${RECOMMEND}" 
	fi
}

FUNCT_CHECK_SWAP
FUNCT_CHECK_OOM_SCORE
FUNCT_CHECK_MOUNT_POINT
FUNCT_CHECK_SYSSTAT
FUNCT_CHECK_SAR_SCHEDULE
FUNCT_CHECK_MYSQL_VOL
FUNCT_CHECK_TCP_PARAM
FUNCT_CHECK_TCP_REASSEMBLY_MEM

