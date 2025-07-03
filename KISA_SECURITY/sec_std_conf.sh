#!/bin/bash
#Script by helperchoi@gmail.com / Kwang Min Choi
#This script supports RHEL 7.x, Ubuntu 18.04 LTS and later systemd-based OS.
SCRIPT_DESCRIPTION="KISA Vulnerability Diagnosis Automation Script"
SCRIPT_VERSION=1.2.20250703

export LANG=C
export LC_ALL=C

WORK_TYPE=$1
readonly DATE_TIME=`date '+%Y%m%d_%H%M%S'`
LOG_DIR=/root/shell/KISA_SECURITY/logs
CVE_RESULT_LOG=/tmp/cve_result.log
BACKUP_ROOT_PATH=/root/shell/CONF_BACKUP
BACKUP_ROOT_DIR=${BACKUP_ROOT_PATH}/${DATE_TIME}
BACKUP_SERVICE_DIR=${BACKUP_ROOT_DIR}/service
BACKUP_PERMISSION_DIR=${BACKUP_ROOT_DIR}/permission

COMMON_VARS_DIR=/root/shell/KISA_SECURITY
COMMON_VARS=${COMMON_VARS_DIR}/common
mkdir -p ${LOG_DIR} ${COMMON_VARS_DIR} 

#############################
###### COMMON FUNCTION ######
#############################

FUNCT_CHECK_OS() {
	CHECK_OS=`uname -s | tr '[A-Z]' '[a-z]'`

	if [ $CHECK_OS = "linux" ];
	then
		source /etc/os-release
		case "$ID" in
			ubuntu) OS_PLATFORM="UBUNTU" ;;
			rocky) OS_PLATFORM="RHEL" ;;
			centos) OS_PLATFORM="RHEL" ;;
			rhel) OS_PLATFORM="RHEL" ;;
			amzn) OS_PLATFORM="RHEL" ;;
			*) echo "[ERROR] ${HOSTNAME} Unsupported Linux"; exit 1 ;;
		esac

		export OS_VERSION=${VERSION_ID}
	else
		echo "[ERROR] ${HOSTNAME} Can not execute. run script is only Linux OS"
		exit 1
	fi
}

FUNCT_CHECK_CMD() {
        TARGET_LIST=$1
	which ${TARGET_LIST} > /dev/null 2>&-

        if [ $? -eq 0 ]
        then
                export CHECK_CMD_RESULT=0
        else
                export CHECK_CMD_RESULT=1
        fi
}


FUNCT_CHECK_COMPARE() {
	USER_VAL=$1
	COMPARE_NUMBER=$2
	
	DIFF=`echo "${USER_VAL} >= ${COMPARE_NUMBER}" | bc`
	if [ "${DIFF}" -eq 1 ];
	then
		#### OK ####
		CHECK_COMPARE_RESULT=0
	else
		#### Not OK ####
		CHECK_COMPARE_RESULT=1
	fi
}

FUNCT_CHECK_BACKUP_DIR_LIST() {
	echo
	echo "########################################################"
	echo "[INFO] The Backup List for this System is as follows."
	echo "########################################################"
	echo
	
	BACKUP_DIR_LIST=`find ${BACKUP_ROOT_PATH} -regextype posix-extended -mindepth 1 -maxdepth 1 -type d -regex '.*/[0-9]{8}_[0-9]{6}'`

	for LIST in ${BACKUP_DIR_LIST}
	do
		basename ${LIST}
	done
	echo
	echo "########################################################"
	echo
	echo "[QUESTION] Please Select the Recovery Point."
	echo
	read ANSWER_R

	if [ -d "${BACKUP_ROOT_PATH}/${ANSWER_R}" ]
	then
		echo
		echo "[INFO] You selected Restore Point : ${ANSWER_R}"
		export BACKUP_ROOT_DIR=${BACKUP_ROOT_PATH}/${ANSWER_R}
		export BACKUP_SERVICE_DIR=${BACKUP_ROOT_DIR}/service
		export BACKUP_PERMISSION_DIR=${BACKUP_ROOT_DIR}/permission
		echo "[INFO] BACKUP DIR : ${BACKUP_ROOT_DIR}"
	else
		echo
		echo "[ERRROR] Please Select from the Backup List displayed and enter your information."
		echo
		exit 1
	fi
}

FUNCT_MANDATORY() {
	if [ "${USER}" != "root" ]
	then
		echo
		echo "[ERROR] ${HOSTNAME} This script must be used in a Only 'root' Account."
		echo
		exit 1
	else
		FUNCT_CHECK_CMD bc
		if [ ${CHECK_CMD_RESULT} -eq 1 ]
		then
			if [ ${OS_PLATFORM} == "RHEL" ]
		 	then
				echo "[INFO] ${HOSTNAME} This script requires the 'bc' Command Package."
				yum -y install bc
		   	elif [ ${OS_PLATFORM} == "UBUNTU" ]
		     	then
				echo "[INFO] ${HOSTNAME} This script requires the 'bc' Command Package."
				apt-get -y install bc
		  	else
				echo "[ERR] ${HOSTNAME} Not Support OS"
		   		exit 1
		  	fi
		fi
	fi

	if [ -z ${WORK_TYPE} ]
	then
		echo
		echo "[ERROR] ${HOSTNAME} WORK TYPE was not Input."
		echo
		echo "### 1. Input Work Type : Only PROC or RESTORE ###"
		echo
		echo "Usage ) : $0 PROC"
		echo
		exit 1

	elif [ $# -eq 1 ]
	then
		if [ ${WORK_TYPE} == "PROC" ]
		then
			export CHECK_WORK_TYPE=0

		elif [  ${WORK_TYPE} == "RESTORE" ]
		then
			export CHECK_WORK_TYPE=1
			FUNCT_CHECK_BACKUP_DIR_LIST
		else
			export CHECK_WORK_TYPE=2

			echo
			echo "### 1. Input Work Type : Only PROC or RESTORE ###"
			echo
			echo "Usage ) : $0 PROC"
			echo

			exit 1
		fi
	else
		echo
		echo "### 1. Input Work Type : Only PROC or RESTORE ###"
		echo
		echo "Usage ) : $0 PROC"
		echo
		exit 1
	fi


	if [ -e ${COMMON_VARS} ]
	then
		source ${COMMON_VARS}
	else
		echo "[ERROR] ${HOSTNAME} Need to Common Variable File : ${COMMON_VARS}"
		exit 1
	fi
}


FUNCT_CHECK_FILE() {
	TARGET_LIST=$1
	
	if [ -e ${TARGET_LIST} ]
	then
		export CHECK_RESULT=0
	else
		export CHECK_RESULT=1
	fi
}

FUNCT_CHECK_PERM() {
	TARGET_LIST=$1
	CHECK_FILE_PERM=`stat -c '%a' ${TARGET_LIST}`
	CHECK_FILE_OWNER=`ls -ld ${TARGET_LIST} | awk '{print $3}'`
	CHECK_FILE_GROUP=`ls -ld ${TARGET_LIST} | awk '{print $4}'`
	export CHECK_FILE_PERM_VAL=${CHECK_FILE_PERM}
	export CHECK_FILE_OWNER_VAL=${CHECK_FILE_OWNER}
	export CHECK_FILE_GROUP_VAL=${CHECK_FILE_GROUP}
	export CHECK_FILE_PERM_ALL="${CHECK_FILE_PERM}:${CHECK_FILE_OWNER}:${CHECK_FILE_GROUP}"
}

FUNCT_BACKUP_PERM() {
	TARGET_LIST=$1
	BASE_DIR=`dirname ${TARGET_LIST}`
	BACKUP_BASE_DIR=${BACKUP_PERMISSION_DIR}${BASE_DIR}
	BACKUP_FILE=${BACKUP_PERMISSION_DIR}${TARGET_LIST}.${DATE_TIME}
	mkdir -p ${BACKUP_BASE_DIR}

	FUNCT_CHECK_PERM ${TARGET_LIST}
	echo "[INFO] ${HOSTNAME} Permission Backup : ${BACKUP_FILE} [ ${CHECK_FILE_PERM_ALL} ]"
	echo "${CHECK_FILE_PERM_ALL}" > ${BACKUP_FILE}
}

FUNCT_CHECK_PERM_BACKUP() {
	TARGET_LIST=$1

	ls -1 ${BACKUP_PERMISSION_DIR}${TARGET_LIST}* 2>&- > /dev/null

	if [ $? -eq 0 ]	
	then
		export CHECK_PERM_BACKUP=0
		export LAST_PERM_BACKUP_FILE=`ls -1 ${BACKUP_PERMISSION_DIR}${TARGET_LIST}* | tail -1`
	else
		export CHECK_PERM_BACKUP=1
	fi
}

FUNCT_RESTORE_PERM() {
	TARGET_LIST=$1
	RESTORE_TYPE=$2

	FUNCT_CHECK_PERM_BACKUP ${TARGET_LIST}

	if [ ${CHECK_PERM_BACKUP} -eq 0 ]
	then
		CHECK_PERM_ALL=`cat ${LAST_PERM_BACKUP_FILE}`
		CHECK_PERM=`cat ${LAST_PERM_BACKUP_FILE} | cut -d ":" -f1`
		CHECK_OWNER=`cat ${LAST_PERM_BACKUP_FILE} | cut -d ":" -f2-`

		if [ ${RESTORE_TYPE} == "PERM" ]
		then
			echo "[INFO] ${HOSTNAME} Restore Permission : ${LAST_PERM_BACKUP_FILE} [ ${CHECK_PERM} ] -> ${TARGET_LIST}"
			chmod ${CHECK_PERM} ${TARGET_LIST}
		elif [ ${RESTORE_TYPE} == "ALL" ]
		then
			echo "[INFO] ${HOSTNAME} Restore Permission : ${LAST_PERM_BACKUP_FILE} [ ${CHECK_PERM_ALL} ] -> ${TARGET_LIST}"
			chmod ${CHECK_PERM} ${TARGET_LIST}
			chown ${CHECK_OWNER} ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Not Support RESTORE TYPE"
		fi
	else
		echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Permission backup) : ${TARGET_LIST}" 
	fi
}

FUNCT_CHECK_DIR() {
	TARGET_LIST=$1
        CHECK_STAT=`stat -c %F ${TARGET_LIST} | grep "directory" | wc -l`
        if [ ${CHECK_STAT} -eq 0 ]
        then
		### FILE TYPE ###
		export CHECK_DIR_STAT=1
	else
		### DIR TYPE ###
		export CHECK_DIR_STAT=0
	fi
}

FUNCT_CHECK_SYMBOLIC() {
	TARGET_LIST=$1
        CHECK_SYMBOLIC_LINK=`stat -c %F ${TARGET_LIST} | grep "symbolic" | wc -l`
        if [ ${CHECK_SYMBOLIC_LINK} -eq 0 ]
        then
		export CHECK_SYMBOLIC_STAT=0
	else
		export CHECK_SYMBOLIC_STAT=1
	fi
}

FUNCT_BACKUP_FILE() {
	TARGET_LIST=$1
	BASE_FILE=`basename ${TARGET_LIST}`
	BASE_DIR=`dirname ${TARGET_LIST}`
	BACKUP_BASE_DIR=${BACKUP_ROOT_DIR}${BASE_DIR}
	BACKUP_FILE=${BACKUP_BASE_DIR}/${BASE_FILE}.${DATE_TIME}
	mkdir -p ${BACKUP_BASE_DIR}

	FUNCT_CHECK_SYMBOLIC ${TARGET_LIST}
	if [ ${CHECK_SYMBOLIC_STAT} -eq 0 ]
	then
		cp -fpP ${TARGET_LIST} ${BACKUP_FILE}
		echo "[INFO] ${HOSTNAME} Backup Complete : ${BACKUP_FILE}"
	else
		ORIGIN_FILE=`readlink -f ${TARGET_LIST}`
		ORIGIN_BASE_FILE=`basename ${ORIGIN_FILE}`
		cp -fpP ${ORIGIN_FILE} ${BACKUP_BASE_DIR}/${ORIGIN_BASE_FILE}.${DATE_TIME}
		echo "[INFO] ${HOSTNAME} Backup Complete : ${BACKUP_BASE_DIR}/${ORIGIN_BASE_FILE}.${DATE_TIME}"
	fi

}

FUNCT_CHECK_BACKCUP_FILE() {
	TARGET_LIST=$1

	FUNCT_CHECK_SYMBOLIC ${TARGET_LIST}
	if [ ${CHECK_SYMBOLIC_STAT} -eq 0 ]
	then
		ls -1 ${BACKUP_ROOT_DIR}${TARGET_LIST}* 2>&- > /dev/null

		if [ $? -eq 0 ]
		then
			export CHECK_RESULT_BACKUP=0
			export LAST_BACKUP_FILE=`ls -1 ${BACKUP_ROOT_DIR}${TARGET_LIST}* | tail -1`
		else
			export CHECK_RESULT_BACKUP=1
		fi
	else
		ORIGIN_FILE=`readlink -f ${TARGET_LIST}`
		ORIGIN_BASE_FILE=`basename ${ORIGIN_FILE}`
		ls -1 ${BACKUP_ROOT_DIR}${ORIGIN_FILE}* 2>&- > /dev/null

		if [ $? -eq 0 ]
		then
			export CHECK_RESULT_BACKUP=0
			export LAST_BACKUP_FILE=`ls -1 ${BACKUP_ROOT_DIR}${ORIGIN_FILE}* | tail -1`
		else
			export CHECK_RESULT_BACKUP=1
		fi
	fi
}

FUNCT_RESTORE_FILE() {
	TARGET_LIST=$1
	FUNCT_CHECK_BACKCUP_FILE ${TARGET_LIST}

	if [ ${CHECK_RESULT_BACKUP} -eq 0 -a ${CHECK_SYMBOLIC_STAT} -eq 0 ]
	then
		echo "[INFO] ${HOSTNAME} Restore File : ${LAST_BACKUP_FILE} -> ${TARGET_LIST}"
		cp -fpP ${LAST_BACKUP_FILE} ${TARGET_LIST}

	elif [ ${CHECK_RESULT_BACKUP} -eq 0 -a ${CHECK_SYMBOLIC_STAT} -eq 1 ]
	then
		echo "[INFO] ${HOSTNAME} Restore File : ${LAST_BACKUP_FILE} -> ${ORIGIN_FILE}"
		cp -fpP ${LAST_BACKUP_FILE} ${ORIGIN_FILE}
	else
		echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}" 
	fi
}


FUNCT_CHECK_SERVICE() {
	TARGET_SERVICE=$1
	CHECK_SERVICE_STAT=`systemctl is-enabled ${TARGET_SERVICE} 2>&1`

	if [ "${CHECK_SERVICE_STAT}" == "enabled" ]
	then
		export CHECK_SERVICE_RESULT=0

	elif [ "${CHECK_SERVICE_STAT}" == "disabled" ]
	then
		export CHECK_SERVICE_RESULT=1
	else
		export CHECK_SERVICE_RESULT=2
	fi
}


FUNCT_BACKUP_SERVICE() {
	TARGET_SERVICE=$1

	if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
	then
		echo "enable" > ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE}
	elif [ ${CHECK_SERVICE_RESULT} -eq 1 ]
	then
		echo "disable" > ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE}
	else
		echo "[INFO] ${HOSTNAME} Package is Not Installed : ${TARGET_SERVICE}"
	fi
}

FUNCT_SERVICE_DISABLE_PROCESS() {
	TARGET_SERVICE=$1

	if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
	then
		FUNCT_BACKUP_SERVICE ${TARGET_SERVICE} 
		BACKUP_SERVICE_STAT=`cat ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE}`
		echo "[INFO] ${HOSTNAME} Service BACKUP : ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} [ ${BACKUP_SERVICE_STAT} ]" 
		echo "[INFO] ${HOSTNAME} Service Disable & Stop : ${TARGET_SERVICE}" 
		systemctl disable ${TARGET_SERVICE}
		systemctl stop ${TARGET_SERVICE}
	elif [ ${CHECK_SERVICE_RESULT} -eq 1 ]
	then
		FUNCT_BACKUP_SERVICE ${TARGET_SERVICE} 
		BACKUP_SERVICE_STAT=`cat ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE}`
		echo "[INFO] ${HOSTNAME} Service BACKUP : ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} [ ${BACKUP_SERVICE_STAT} ]" 
		echo "[INFO] ${HOSTNAME} Service Enable & Start : ${TARGET_SERVICE}" 
		systemctl enable ${TARGET_SERVICE}
		systemctl start ${TARGET_SERVICE}
	fi
}

FUNCT_CHECK_SERVICE_BACKUP() {
	TARGET_SERVICE=$1
	
	if [ -e ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} ]
	then
		export CHECK_SERVICE_BACKUP=0
	else
		export CHECK_SERVICE_BACKUP=1
	fi
}

FUNCT_RESTORE_SERVICE() {
	TARGET_SERVICE=$1

	if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
	then
		SERVICE_STATUS=`grep enable ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} | wc -l`
		BACKUP_SERVICE_STAT=`cat ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE}`

		if [ ${SERVICE_STATUS} -eq 1 ]
		then
			echo "[INFO] ${HOSTNAME} Restore Service : ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} [ ${BACKUP_SERVICE_STAT} ]" 
			echo "[INFO] ${HOSTNAME} Service Enable & Start : ${TARGET_SERVICE}" 
			systemctl enable ${TARGET_SERVICE}
			systemctl start ${TARGET_SERVICE}
		else
			echo "[INFO] ${HOSTNAME} Restore Service : ${BACKUP_SERVICE_DIR}/${TARGET_SERVICE} [ ${BACKUP_SERVICE_STAT} ]" 
			echo "[INFO] ${HOSTNAME} Service Disable & Stop : ${TARGET_SERVICE}" 
			systemctl disable ${TARGET_SERVICE}
			systemctl stop ${TARGET_SERVICE}
		fi
	else
		echo "[INFO] ${HOSTNAME} Service Status Backup is Not Found : ${TARGET_SERVICE}"
	fi
}

FUNCT_EXCEPTION() {
	EXT_MSG="$1"
	echo "[EXCP] ${HOSTNAME} Exception: ${EXT_MSG}"
}

FUNCT_CHECK_PORT() {
	TARGET_PROTO=$1
	TARGET_PORT=$2

	CHECK_PORT=`netstat -lnp | grep "^${TARGET_PROTO}" | awk '$4 ~ /:'"${TARGET_PORT}"'$/ {print $0}' | wc -l`
	CHECK_PROCESS_CMD=`netstat -lnp | grep "^${TARGET_PROTO}" | awk '$4 ~ /:'"${TARGET_PORT}"'$/ {print $0}' | awk '$4 !~ /^::/ {print $NF}' | cut -d "/" -f2 | sort -u`

	if [ ${CHECK_PORT} -eq 0 ]
	then
		export CHECK_PORT_RESULT=0
	else
		export CHECK_PORT_RESULT=1
		export CHECK_PROCESS=${CHECK_PROCESS_CMD}
	fi
}

FUNCT_CHECK_PORT_LOOP() {
	TARGET_SERVICE_PORT=$1
	CHECK_ALL_PORT=0
	declare -g -a ARRAY_CHECK_PORT			
	declare -g -a ARRAY_CHECK_PROCESS			

	for LIST in ${TARGET_SERVICE_PORT}
	do
		OBJ_PROTO=`echo ${LIST} | cut -d "/" -f1`
		OBJ_PORT=`echo ${LIST} | cut -d "/" -f2`

		FUNCT_CHECK_PORT ${OBJ_PROTO} ${OBJ_PORT}
		if [ ${CHECK_PORT_RESULT} -ne 0 ]
		then
			export CHECK_ALL_PORT=1
			ARRAY_CHECK_PORT+=("${LIST}")
			ARRAY_CHECK_PROCESS+=("${LIST}/${CHECK_PROCESS}")
		fi
	done
}

FUNCT_SHOW_PROGRESS() {
	PROGRESS_BAR="/-\|"
	while true;
	do
		for (( i=0; i<${#PROGRESS_BAR}; i++ ));
		do
			echo -ne "\r[${PROGRESS_BAR:$i:1}] Please wait. Progress ..." 
			sleep 0.1
		done
	done
}

FUNCT_SEARCH_CVE() {
	if [ ${OS_PLATFORM} == "RHEL" ]
	then
		PKG_LIST=`rpm -qa`	

	elif [ ${OS_PLATFORM} == "UBUNTU" ]
	then
		PKG_LIST=`find /usr/share/doc/ -type f -name \*.gz`
	fi

	for LIST in ${PKG_LIST}
	do
		if [ ${OS_PLATFORM} == "RHEL" ]
		then
			rpm -qi ${LIST} --changelog | grep -o "CVE-[0-9]\{4\}-[0-9]\{4,5\}"
		elif [ ${OS_PLATFORM} == "UBUNTU" ]
		then
			zgrep -i "cve-" ${LIST} | grep -o "CVE-[0-9]\{4\}-[0-9]\{4,5\}"
		fi
	done

}

###################################
###### MAIN PROCESS FUNCTION ######
###################################

FUNCT_U01() {
	echo
	#########################
	echo "### PROCESS U01 ###"
	#########################

	WORK_TYPE=$1
	TARGET_LIST=/etc/ssh/sshd_config

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_BACKUP_FILE ${TARGET_LIST}
			
			################ Independent Processing Logic [ BEGIN ] ################

			echo "[INFO] ${HOSTNAME} Processing PermitRootLogin no : ${TARGET_LIST}"
			CHECK_VALUE=`grep "PermitRootLogin" ${TARGET_LIST} | wc -l`
			if [ ${CHECK_VALUE} -eq 0 ]
			then
				echo "### Add Config PermitRootLogin ${DATE_TIME} : $0" >> ${TARGET_LIST}
				echo "PermitRootLogin no" >> ${TARGET_LIST}
				echo "### End Conifg PermitRootLogin ${DATE_TIME} : $0" >> ${TARGET_LIST}
			else
				sed -i '/Add Config PermitRootLogin/d' ${TARGET_LIST}	
				sed -i '/PermitRootLogin/d' ${TARGET_LIST}	
				sed -i '/Match Address/d' ${TARGET_LIST}	
				sed -i '/End Conifg PermitRootLogin/d' ${TARGET_LIST}	

				echo "### Add Config PermitRootLogin ${DATE_TIME} : $0" >> ${TARGET_LIST}
				echo "PermitRootLogin no" >> ${TARGET_LIST}
				echo "### End Conifg PermitRootLogin ${DATE_TIME} : $0" >> ${TARGET_LIST}
			fi

			################ Independent Processing Logic [ END ]################
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		fi

	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U02() {
	echo
	#########################
	echo "### PROCESS U02 ###"
	#########################

	WORK_TYPE=$1

	if [ ${OS_PLATFORM} == "RHEL" ]
	then
		#####################
		#### RHEL LINUX ####
		#####################

		TARGET_LIST=/etc/security/pwquality.conf

		if [ ${WORK_TYPE} == "PROC" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
			
				################ Independent Processing Logic [ BEGIN ] ################

				echo "[INFO] ${HOSTNAME} Processing Password Quality : ${TARGET_LIST}"
				CHECK_VALUE=`egrep "^lcredit|^ucredit|^dcredit|^ocredit|^minlen|^difok" ${TARGET_LIST} | wc -l`

				if [ ${CHECK_VALUE} -ne 6 ]
				then
					sed -i '/lcredit/d' ${TARGET_LIST}	
					sed -i '/ucredit/d' ${TARGET_LIST}	
					sed -i '/dcredit/d' ${TARGET_LIST}	
					sed -i '/ocredit/d' ${TARGET_LIST}	
					sed -i '/minlen/d' ${TARGET_LIST}	
					sed -i '/difok/d' ${TARGET_LIST}	
	
					echo >> ${TARGET_LIST}
					echo "### Add Config [ Password Quality ] ${DATE_TIME} : $0" >> ${TARGET_LIST}
					echo "lcredit = 1" >> ${TARGET_LIST}
					echo "ucredit = 1" >> ${TARGET_LIST}
					echo "dcredit = 1" >> ${TARGET_LIST}
					echo "ocredit = 1" >> ${TARGET_LIST}
					echo "minlen = 8" >> ${TARGET_LIST}
					echo "difok = 5" >> ${TARGET_LIST}
					echo "### End Conifg [ Password Quality ] ${DATE_TIME} : $0" >> ${TARGET_LIST}
					echo >> ${TARGET_LIST}
				fi

				################ Independent Processing Logic [ END ] ################
			fi

		elif [ ${WORK_TYPE} == "RESTORE" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${TARGET_LIST}
			fi

		else
			echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
			exit 1
		fi
	else
		######################
		#### UBUNTU LINUX ####
		######################

		TARGET_LIST=/etc/pam.d/common-password

		if [ ${WORK_TYPE} == "PROC" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
			
				################ Independent Processing Logic [ BEGIN ] ################

				echo "[INFO] ${HOSTNAME} Processing Password Quality : ${TARGET_LIST}"
				CHECK_VALUE=`grep "^password" ${TARGET_LIST} | grep "requisite" | wc -l`

				if [ ${CHECK_VALUE} -eq 1 ]
				then
					TARGET_LINE_NO=`cat ${TARGET_LIST} | grep -n "^password" | grep "requisite" | cut -d : -f1`
					sed -i "${TARGET_LINE_NO} s/\(.*\)/#\1/g" ${TARGET_LIST}
	
					echo >> ${TARGET_LIST}
					echo "### Add Config [ Password Quality ] ${DATE_TIME} : $0" >> ${TARGET_LIST}
					echo "password   requisite   pam_pwquality.so retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1" >> ${TARGET_LIST}
					echo "### End Conifg [ Password Quality ] ${DATE_TIME} : $0" >> ${TARGET_LIST}
					echo >> ${TARGET_LIST}
				fi

				################ Independent Processing Logic [ END ] ################
			fi

		elif [ ${WORK_TYPE} == "RESTORE" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${TARGET_LIST}
			fi

		else
			echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
			exit 1
		fi
	fi
}


FUNCT_U03() {
	echo
	#########################
	echo "### PROCESS U03 ###"
	#########################

	WORK_TYPE=$1

	if [ ${OS_PLATFORM} == "RHEL" ]
	then
		#####################
		#### RHEL LINUX ####
		#####################

		TARGET_LIST=/etc/pam.d/system-auth

		if [ ${WORK_TYPE} == "PROC" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
			
				################ Independent Processing Logic [ BEGIN ] ################

				echo "[INFO] ${HOSTNAME} Processing Password Lock : ${TARGET_LIST}"

				cat > ${TARGET_LIST} << EOF
				${ACCOUNT_AUTH_RHEL}
EOF

				################ Independent Processing Logic [ END ] ################
			fi

		elif [ ${WORK_TYPE} == "RESTORE" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${TARGET_LIST}
			fi

		else
			echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
			exit 1
		fi
	else
		######################
		#### UBUNTU LINUX ####
		######################

		TARGET_LIST=/etc/pam.d/common-auth

		if [ ${WORK_TYPE} == "PROC" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
			
				################ Independent Processing Logic [ BEGIN ] ################

				echo "[INFO] ${HOSTNAME} Processing Password Lock : ${TARGET_LIST}"

				cat > ${TARGET_LIST} << EOF
				${ACCOUNT_AUTH_UBUNTU}
EOF

				################ Independent Processing Logic [ END ] ################
			fi

		elif [ ${WORK_TYPE} == "RESTORE" ]
		then
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${TARGET_LIST}
			fi

		else
			echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
			exit 1
		fi
	fi
}


FUNCT_U04() {
	echo
	#########################
	echo "### PROCESS U04 ###"
	#########################

	WORK_TYPE=$1
	TARGET_LIST=/etc/shadow

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			################ Independent Processing Logic [ BEGIN ] ################
			echo "[INFO] ${HOSTNAME} Shadow encryption enabled OK : ${TARGET_LIST}"	
			################ Independent Processing Logic [ END ] ################
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U04."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U05() {
	echo
	#########################
	echo "### PROCESS U05 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		################ Independent Processing Logic [ BEGIN ] ################
		CHECK_RESULT=`echo $PATH | grep -E '(^|:)\.:' | wc -l`

		if [ ${CHECK_RESULT} -eq 0 ] 
		then
			echo "[INFO] ${HOSTNAME} There is no problem with the PATH environment variable : OK"	
		else
			echo "[WARR] ${HOSTNAME} You need to remove the .(dot) path from your PATH environment variable : Not OK"	
		fi
		################ Independent Processing Logic [ END ] ################

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U05."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U06() {
	echo
	#########################
	echo "### PROCESS U06 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_SHOW_PROGRESS &
		PROGRESS_PID=$!

		TARGET_LIST=${BACKUP_ROOT_DIR}/NONE_USER_LIST
		find / ! \( \( -path '/proc' -o -path '${BACKUP_ROOT_DIR}' -o -path '/var/lib' -o -path '/run' -o -path '/run/containerd' -o -path '/app/data/kubelet' \) -prune \) -type f -a -nouser -exec ls -a1Ld {} \; > ${TARGET_LIST}

		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		kill ${PROGRESS_PID}
		wait ${PROGRESS_PID} 2>/dev/null
		echo ""

		if [ "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_CHECK_FILE ${LIST}
				################ Independent Processing Logic [ BEGIN ] ################
	
				echo "[WARN] ${HOSTNAME} File is without owner and do not exist account : ${LIST}"
	
				################ Independent Processing Logic [ END ] ################
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-06 Check : OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/NONE_USER_LIST
		if [ -e ${TARGET_LIST} ]
		then
			export CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`
		else
			export CHECK_TARGET_OBJECT=0
		fi

		if [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_RESTORE_FILE ${LIST}
			done
		elif [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U08() {
	echo
	#########################
	echo "### PROCESS U08 ###"
	#########################

	WORK_TYPE=$1

	PERM_400_LIST="
	/etc/shadow
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${PERM_400_LIST}
		do
			###########################
			### FILE CHECK & BACKUP ###
			###########################
	
			FUNCT_CHECK_FILE ${LIST}
	
			##############################
			### Change File Permission ###
			##############################
	
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}
				echo "[INFO] ${HOSTNAME} Change File Permission 400 : ${LIST}"
				chmod 400 ${LIST}
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${PERM_400_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U09() {
	echo
	#########################
	echo "### PROCESS U07, U09, U10, U12, U55 ###"
	#########################

	WORK_TYPE=$1

	PERM_600_LIST="
	/etc/xinetd.conf
	/etc/xinetd.d/chargen-dgram
	/etc/xinetd.d/chargen-stream
	/etc/xinetd.d/daytime-dgram
	/etc/xinetd.d/daytime-stream
	/etc/xinetd.d/discard-dgram
	/etc/xinetd.d/discard-stream
	/etc/xinetd.d/echo-dgram
	/etc/xinetd.d/echo-stream
	/etc/xinetd.d/tcpmux-server
	/etc/xinetd.d/time-dgram
	/etc/xinetd.d/time-stream
	/etc/xinetd.d/tftp
	/etc/shadow
	/etc/hosts.lpd
	"

	PERM_644_LIST="
	/etc/passwd
	/etc/group
	/etc/services
	/etc/hosts
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${PERM_600_LIST}
		do
			###########################
			### FILE CHECK & BACKUP ###
			###########################
	
			FUNCT_CHECK_FILE ${LIST}
	
			##############################
			### Change File Permission ###
			##############################
	
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}

				echo "[INFO] ${HOSTNAME} Change File Permission 600 : ${LIST}"
				chmod 600 ${LIST}
			else
				echo "[INFO] ${HOSTNAME} ${LIST} Does not exist : OK"
			fi
		done

		for LIST in ${PERM_644_LIST}
		do
			###########################
			### FILE CHECK & BACKUP ###
			###########################
	
			FUNCT_CHECK_FILE ${LIST}
	
			##############################
			### Change File Permission ###
			##############################
	
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}

				echo "[INFO] ${HOSTNAME} Change File Permission 644 : ${LIST}"
				chmod 644 ${LIST}
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${PERM_600_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			fi
		done

		for LIST in ${PERM_644_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U11() {
	echo
	#########################
	echo "### PROCESS U11 ###"
	#########################

	WORK_TYPE=$1

	PERM_640_LIST="
	/etc/rsyslog.conf
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${PERM_640_LIST}
		do
			###########################
			### FILE CHECK & BACKUP ###
			###########################
	
			FUNCT_CHECK_FILE ${LIST}
	
			##############################
			### Change File Permission ###
			##############################
	
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}
				echo "[INFO] ${HOSTNAME} Change File Permission 640 : ${LIST}"
				chmod 640 ${LIST}
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${PERM_640_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U13() {
	echo
	#########################
	echo "### PROCESS U13 ###"
	#########################

	WORK_TYPE=$1

	WORK_LIST="
	/usr/sbin/unix_chkpwd
	/usr/bin/newgrp
	/sbin/dump
	/usr/bin/lpq-lpd
	/sbin/restore
	/usr/bin/lpr
	/usr/sbin/lpc
	/usr/bin/lpr-lpd
	/usr/sbin/lpc-lpd
	/usr/bin/at
	/usr/bin/lprm
	/usr/sbin/traceroute
	/usr/bin/lpq
	/usr/bin/lprm-lpd
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for TARGET_LIST in ${WORK_LIST}
		do
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM ${TARGET_LIST}
				FUNCT_BACKUP_PERM ${TARGET_LIST}
				echo "[INFO] ${HOSTNAME} Remove Set UID : ${TARGET_LIST}"
				chmod u-s ${TARGET_LIST}
			else
				echo "[INFO] ${HOSTNAME} ${TARGET_LIST} Does not exist : OK"
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for TARGET_LIST in ${WORK_LIST}
		do
			FUNCT_CHECK_PERM_BACKUP ${TARGET_LIST}
			FUNCT_RESTORE_PERM ${TARGET_LIST} ALL
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U14() {
	echo
	#########################
	echo "### PROCESS U14 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	SHELL_ENV_LIST="
	.bashrc
	.bash_profile
	.profile
	.kshrc
	.cshrc
	.login
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_HOME_DIR=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | awk -F : '$1 ~ /^'"${LIST}"'$/ {print $6}'`

			for SHELL_ENV_CONF in ${SHELL_ENV_LIST}
			do
				FUNCT_CHECK_FILE ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_CHECK_PERM ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
					OTHER_DIR_PERM=`echo "${CHECK_FILE_PERM_VAL}" | cut -c 3`

					if [ ${OTHER_DIR_PERM} -eq 0 -a ${CHECK_FILE_OWNER_VAL} == "${LIST}" ] 
					then
						echo "[INFO] ${HOSTNAME} ${LIST} : Shell ENV Permissions and Owner OK. (${CHECK_FILE_PERM_VAL} / ${CHECK_FILE_OWNER_VAL}) : ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}"

					elif [ ${CHECK_FILE_OWNER_VAL} != "${LIST}" ]
					then
						echo "[WARN] ${HOSTNAME} ${LIST} : Shell ENV Owner information of the account does not match. (${CHECK_FILE_OWNER_VAL})"
						FUNCT_BACKUP_FILE ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
						echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chown ${LIST} ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}"
						chown ${LIST} ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
						echo
					else
						echo "[WARN] ${HOSTNAME} ${LIST} : Shell ENV Permissions include Other user permissions (${CHECK_FILE_PERM_VAL})"
						FUNCT_BACKUP_FILE ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
						echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 640 ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}"
						chmod 640 ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
						echo
					fi
				fi
			done
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_HOME_DIR=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | awk -F : '$1 ~ /^'"${LIST}"'$/ {print $6}'`
			for SHELL_ENV_CONF in ${SHELL_ENV_LIST}
			do
				FUNCT_CHECK_FILE ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_RESTORE_FILE ${CHECK_HOME_DIR}/${SHELL_ENV_CONF}
				fi
			done
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U15() {
	echo
	#########################
	echo "### PROCESS U15 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_SHOW_PROGRESS &
		PROGRESS_PID=$!

		TARGET_LIST=${BACKUP_ROOT_DIR}/WORLD_WRITABLE_LIST
		find / ! \( \( -path '/proc' -o -path '${BACKUP_ROOT_DIR}' -o -path '/var/lib' -o -path '/run' -o -path '/run/containerd' -o -path '/sys' \) -prune \) -type f -perm -2 -exec ls -1 {} \; > ${TARGET_LIST}

		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		kill ${PROGRESS_PID}
		wait ${PROGRESS_PID} 2>/dev/null
		echo ""

		if [ "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_CHECK_FILE ${LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} File is World Writable Permission : ${LIST}"
					FUNCT_CHECK_PERM ${LIST}
					FUNCT_BACKUP_PERM ${LIST}
				else
					echo "[INFO] ${HOSTNAME} ${LIST} Does not exist : OK"
				fi
				
				################ Independent Processing Logic [ BEGIN ] ################
	
				echo "[INFO] ${HOSTNAME} Change File Permission (chmod o-w) : ${LIST}"
				chmod o-w ${LIST}
				echo
	
				################ Independent Processing Logic [ END ] ################
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-15 Check : OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/WORLD_WRITABLE_LIST
		if [ -e ${TARGET_LIST} ]
		then
			export CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`
		else
			export CHECK_TARGET_OBJECT=0
		fi

		if [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_CHECK_FILE ${LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_CHECK_PERM_BACKUP ${LIST}
					FUNCT_RESTORE_PERM ${LIST} ALL
				fi
			done

		elif [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U16() {
	echo
	#########################
	echo "### PROCESS U16 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		TARGET_LIST=${BACKUP_ROOT_DIR}/DEV_UNACCEPTABLE_LIST
		find /dev/ -type f -exec ls -1 {} \; > ${TARGET_LIST}

		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_CHECK_FILE ${LIST}
				if [ ${CHECK_RESULT} -eq 0 ]
				then
					################ Independent Processing Logic [ BEGIN ] ################

					echo "[WARN] ${HOSTNAME} Not allowed file in the /dev : ${LIST}"
					FUNCT_BACKUP_FILE ${LIST}
					echo "[INFO] ${HOSTNAME} Delete File : ${LIST}"
					rm -f ${LIST}
	
					################ Independent Processing Logic [ END ] ################
				else
					echo "[INFO] ${HOSTNAME} ${LIST} Does not exist : OK" 
				fi
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-16 Check : OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/DEV_UNACCEPTABLE_LIST
		if [ -e ${TARGET_LIST} ]
		then
			export CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`
		else
			export CHECK_TARGET_OBJECT=0
		fi

		if [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_RESTORE_FILE ${LIST}
			done
		elif [ -e ${TARGET_LIST} -a "${CHECK_TARGET_OBJECT}" -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup)"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U17() {
	echo
	#########################
	echo "### PROCESS U17 ###"
	#########################

	WORK_TYPE=$1

	############ U17 INDEPENDENT FUNCTION & LOGIC BEGIN ############

	declare -a ARRAY_TAGET_LIST
	ARRAY_TAGET_LIST=("/etc/hosts.equiv")
	ACCOUNT_HOME_DIR_LIST=$(egrep -v "nologin$|false$|shutdown$|halt$|sync$" /etc/passwd | cut -d ':' -f 1 | xargs -i getent passwd {} | cut -d : -f 6)

	while IFS= read -r LIST
	do
		OBJ_FILE=.rhosts
		FUNCT_CHECK_FILE ${LIST}/${OBJ_FILE}

		if [ ${CHECK_RESULT} -eq 0 ]
		then
			ARRAY_TAGET_LIST+=("${LIST}/${OBJ_FILE}")
		fi
	done < <(echo "${ACCOUNT_HOME_DIR_LIST}")


	INNER_FUNCT_BACKUP() {
		for LIST in "${ARRAY_TAGET_LIST[@]}"
		do
			FUNCT_CHECK_FILE ${LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}
				echo "[INFO] ${HOSTNAME} Change File Permission 600 : ${LIST}"
				chmod 600 ${LIST}


				if [ ${LIST} = "/etc/hosts.equiv" -a ${CHECK_FILE_OWNER} != "root" ]
				then
					echo "[INFO] ${HOSTNAME} Change File Owner 'root' : ${LIST}"
					chown root:root ${LIST}

				elif [ ${LIST} != "/etc/hosts.equiv" ]
				then
					BASE_DIR=`dirname ${LIST}`
					CHECK_ACCOUNT=`grep "${BASE_DIR}" /etc/passwd | cut -d : -f1`

					if [ ${CHECK_FILE_OWNER} != ${CHECK_ACCOUNT} ]
					then
						echo "[INFO] ${HOSTNAME} Change File Owner '${CHECK_ACCOUNT}' : ${LIST}"
						chown ${CHECK_ACCOUNT}:${CHECK_ACCOUNT} ${LIST}
					fi
				fi
			fi
		done
	}
	############ U17 INDEPENDENT FUNCTION & LOGIC END ############

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 22.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} This System is U-17 Check : OK"	
			else
				INNER_FUNCT_BACKUP ${ARRAY_TAGET_LIST}
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} This System is U-17 Check : OK"
			else
				INNER_FUNCT_BACKUP ${ARRAY_TAGET_LIST}
			fi
		fi
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in "${ARRAY_TAGET_LIST[@]}"
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			else
				echo "[INFO] ${HOSTNAME} This System is U-17 Check : OK"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U18() {
	echo
	#########################
	echo "### PROCESS U18 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" -o ${WORK_TYPE} == "RESTORE" ]
	then
		EXT_MSG="You need to check Physical Firewall."
		FUNCT_EXCEPTION "${EXT_MSG}"
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U19() {
	echo
	#########################
	echo "### PROCESS U19 ###"
	#########################

	WORK_TYPE=$1
	TARGET_LIST=/etc/inetd.conf
	TARGET_SEVICE=finger.socket

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		FUNCT_CHECK_SERVICE ${TARGET_SEVICE}

		if [ ${CHECK_RESULT} -eq 0 ]
		then
			
			################ Independent Processing Logic [ BEGIN ] ################

			CHECK_VALUE=`grep "^finger" ${TARGET_LIST} | wc -l`

			if [ ${CHECK_VALUE} -eq 1 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
				echo "[INFO] ${HOSTNAME} Disable finger service : ${TARGET_LIST}"
				sed -i "s/^finger/#finger/g" ${TARGET_LIST}
			else
				echo "[INFO] ${HOSTNAME} This System is U-19 Check : OK"
			fi

			################ Independent Processing Logic [ END ]################
		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 0 ]
		then
			FUNCT_SERVICE_DISABLE_PROCESS ${TARGET_SEVICE}

		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 1 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-19 Check : OK"

		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 2 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-19 Check : OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		FUNCT_CHECK_SERVICE_BACKUP ${TARGET_SEVICE}

		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_BACKUP} -eq 0 ]
		then
			FUNCT_RESTORE_SERVICE ${TARGET_SEVICE} 
		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_BACKUP} -eq 1 ]
		then
			echo "[INFO] ${HOSTNAME} File & Service Backup Not found."
		fi

	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U20() {
	echo
	#########################
	echo "### PROCESS U20 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	vsftpd.service
	proftpd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE ${LIST}	
			if [ ${CHECK_SERVICE_RESULT} -eq 0 -a ${LIST} == "vsftpd.service" ]
			then
				TARGET_LIST=/etc/vsftpd/vsftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					################ Independent Processing Logic [ BEGIN ] ################

					echo "[INFO] ${HOSTNAME} Processing (anonymous_enable=NO) : ${TARGET_LIST}"
					CHECK_VALUE=`grep "anonymous_enable" ${TARGET_LIST} | wc -l`

					if [ ${CHECK_VALUE} -eq 0 ]
					then
						echo "### Add Config Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "anonymous_enable=NO" >> ${TARGET_LIST}
						echo "### End Conifg Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
					else
						sed -i '/Add Config Anonymous/d' ${TARGET_LIST}	
						sed -i '/^anonymous_enable/d' ${TARGET_LIST}	
						sed -i '/End Conifg Anonymous/d' ${TARGET_LIST}	

						echo "### Add Config Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "anonymous_enable=NO" >> ${TARGET_LIST}
						echo "### End Conifg Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
					fi

					################ Independent Processing Logic [ END ]################
				fi

			elif [ ${CHECK_SERVICE_RESULT} -eq 0 -a ${LIST} == "proftpd.service" ]
			then
				TARGET_LIST=/etc/proftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					################ Independent Processing Logic [ BEGIN ] ################

					echo "[INFO] ${HOSTNAME} Processing (AllowAnonymous off) : ${TARGET_LIST}"
					CHECK_VALUE=`grep "AllowAnonymous" ${TARGET_LIST} | wc -l`

					if [ ${CHECK_VALUE} -eq 0 ]
					then
						echo "### Add Config Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "AllowAnonymous off" >> ${TARGET_LIST}
						echo "### End Conifg Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
					else
						sed -i '/Add Config Anonymous/d' ${TARGET_LIST}	
						sed -i '/^AllowAnonymous/d' ${TARGET_LIST}	
						sed -i '/End Conifg Anonymous/d' ${TARGET_LIST}	

						echo "### Add Config Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "AllowAnonymous off" >> ${TARGET_LIST}
						echo "### End Conifg Anonymous Disable ${DATE_TIME} : $0" >> ${TARGET_LIST}
						echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
					fi

					################ Independent Processing Logic [ END ]################
				fi
			else
				echo "[INFO] ${HOSTNAME} This System is U-20 Check : OK (${LIST})"	
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE ${LIST}
			if [ ${CHECK_SERVICE_RESULT} -eq 0 -a ${LIST} = "vsftpd.service" ]
			then
				TARGET_LIST=/etc/vsftpd/vsftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_RESTORE_FILE ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
				fi
			elif [ ${CHECK_SERVICE_RESULT} -eq 0 -a ${LIST} = "proftpd.service" ]
			then
				TARGET_LIST=/etc/proftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_RESTORE_FILE ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} You are need to run command : systemctl restart ${LIST}"
				fi
			elif [ ${CHECK_SERVICE_RESULT} -eq 1 -a ${LIST} = "vsftpd.service" ]
			then
				TARGET_LIST=/etc/vsftpd/vsftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_RESTORE_FILE ${TARGET_LIST}
				fi
			elif [ ${CHECK_SERVICE_RESULT} -eq 1 -a ${LIST} = "proftpd.service" ]
			then
				TARGET_LIST=/etc/proftpd.conf
				FUNCT_CHECK_FILE ${TARGET_LIST}

				if [ ${CHECK_RESULT} -eq 0 ]
				then
					FUNCT_RESTORE_FILE ${TARGET_LIST}
				fi
			fi
		done

	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U21() {
	echo
	#########################
	echo "### PROCESS U21 ###"
	#########################

	WORK_TYPE=$1
	TARGET_SERVICE_PORT="tcp/512 tcp/513 tcp/514"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04

			if [ ${CHECK_COMPARE_RESULT} -eq 0 -a ${CHECK_ALL_PORT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} This System is U-21 Check : OK"	
			elif [ ${CHECK_COMPARE_RESULT} -eq 0 -a ${CHECK_ALL_PORT} -eq 1 ] 
			then
				echo "[WARN] ${HOSTNAME} You need to Check Listen Port (${ARRAY_CHECK_PORT[@]}) : r-command enable and Not OK"
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."	
			fi

			unset ARRAY_CHECK_PORT

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7

			if [ ${CHECK_COMPARE_RESULT} -eq 0 -a ${CHECK_ALL_PORT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} This System is U-21 Check : OK"	
			elif [ ${CHECK_COMPARE_RESULT} -eq 0 -a ${CHECK_ALL_PORT} -eq 1 ] 
			then
				echo "[WARN] ${HOSTNAME} You need to Check Listen Port (${ARRAY_CHECK_PORT[@]}) : r-command enable and Not OK"
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."	
			fi

			unset ARRAY_CHECK_PORT
		fi
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U21."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U22() {
	echo
	#########################
	echo "### PROCESS U22 ###"
	#########################

	WORK_TYPE=$1

	PERM_640_LIST="
	/etc/cron.d/0hourly
	/etc/cron.d/e2scrub_all
	/etc/cron.d/raid-check
	/etc/cron.d/sysstat
	/etc/cron.daily/apport
	/etc/cron.daily/apt-compat
	/etc/cron.daily/dpkg
	/etc/cron.daily/logrotate
	/etc/cron.daily/man-db
	/etc/cron.daily/man-db.cron
	/etc/cron.daily/mlocate
	/etc/cron.daily/ntp
	/etc/cron.deny
	/etc/cron.hourly/.placeholder
	/etc/cron.hourly/0anacron
	/etc/cron.hourly/mcelog.cron
	/etc/cron.weekly/man-db
	/etc/crontab
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${PERM_640_LIST}
		do
			###########################
			### FILE CHECK & BACKUP ###
			###########################
	
			FUNCT_CHECK_FILE ${LIST}
	
			##############################
			### Change File Permission ###
			##############################
	
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${LIST}
				FUNCT_BACKUP_PERM ${LIST}
				echo "[INFO] ${HOSTNAME} Change File Permission 640 : ${LIST}"
				chmod 640 ${LIST}
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${PERM_640_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_PERM_BACKUP ${LIST}
				FUNCT_RESTORE_PERM ${LIST} ALL
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U23() {
	echo
	#########################
	echo "### PROCESS U23 ###"
	#########################

	WORK_TYPE=$1
	TARGET_SERVICE_PORT="tcp/7 udp/7 tcp/9 udp/9 tcp/13 udp/13 tcp/19 udp/19"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"

		if [ ${CHECK_ALL_PORT} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-23 Check : OK"	
		else
			echo "[WARN] ${HOSTNAME} You need to Check Listen Port (${ARRAY_CHECK_PORT[@]}) : discard, daytime, chargen service enable. Not OK"
		fi

		unset ARRAY_CHECK_PORT
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U23."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U24() {
	echo
	#########################
	echo "### PROCESS U24, U25 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	nfs.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################
						CHECK_EXPORT_CFG=`exportfs -v | wc -l`

						if [ ${CHECK_EXPORT_CFG} -eq 0 ]
						then
							FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
							echo "[INFO] ${HOSTNAME} Found ${LIST} that is not in use."
							systemctl disable ${LIST}
							systemctl stop ${LIST}
						else
							echo "[WARN] ${HOSTNAME} This system is ${LIST} is in use. You should decide whether to disable the ${LIST}."
							exportfs -v
						fi
						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-24 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################
						CHECK_EXPORT_CFG=`exportfs -v | wc -l`

						if [ ${CHECK_EXPORT_CFG} -eq 0 ]
						then
							FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
							echo "[INFO] ${HOSTNAME} Found ${LIST} that is not in use."
							systemctl disable ${LIST}
							systemctl stop ${LIST}
						else
							echo "[WARN] ${HOSTNAME} This system is ${LIST} is in use. You should decide whether to disable the ${LIST}."
							exportfs -v
						fi
						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-24 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U26() {
	echo
	#########################
	echo "### PROCESS U26 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	autofs.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
						systemctl disable ${LIST}
						systemctl stop ${LIST}

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-26 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
						systemctl disable ${LIST}
						systemctl stop ${LIST}

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-26 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U27() {
	echo
	#########################
	echo "### PROCESS U27 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	rpcbind.service
	rpcidmapd.service
	rpc-statd.service
	rpc-statd-notify.service
	rpc-gssd.service
	rpc-rquotad.service
	rpcgssd.service
	"

	################################################################################################################################################
	### [WARN] Required list in NFS Client environment. (rpcbind.service(NFS Client common), rpc-statd.service(NFSv3), rpcidmapd.service(NFSv4)) ###	
	################################################################################################################################################

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						if [ ${LIST} == "rpcbind.service" -o ${LIST} == "rpc-statd.service" -o ${LIST} == "rpcidmapd.service" ]
						then
							echo "[WARN] ${HOSTNAME} You need to check the NFS client required service and manually disable it. (${LIST})"
						else
							FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
							systemctl disable ${LIST}
							systemctl stop ${LIST}
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-27 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						if [ ${LIST} == "rpcbind.service" -o ${LIST} == "rpc-statd.service" -o ${LIST} == "rpcidmapd.service" ]
						then
							echo "[WARN] ${HOSTNAME} You need to check the NFS client required service and manually disable it. (${LIST})"
						else
							FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
							systemctl disable ${LIST}
							systemctl stop ${LIST}
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-27 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U28() {
	echo
	#########################
	echo "### PROCESS U28 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	ypbind.service
	ypserv.service
	yppasswdd.service
	ypxfrd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
						systemctl disable ${LIST}
						systemctl stop ${LIST}

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-28 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_SERVICE_DISABLE_PROCESS ${LIST}
						systemctl disable ${LIST}
						systemctl stop ${LIST}

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-28 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U29() {
	echo
	#########################
	echo "### PROCESS U29 ###"
	#########################

	WORK_TYPE=$1
	TARGET_SERVICE_PORT="udp/69 udp/517 udp/518"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"

		if [ ${CHECK_ALL_PORT} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-29 Check : OK"	
		else
			echo "[WARN] ${HOSTNAME} You need to Check Listen Port (${ARRAY_CHECK_PORT[@]}) : tftp, talk, ntalk service is enable. Not OK"
		fi

		unset ARRAY_CHECK_PORT
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U29."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U30() {
	echo
	#########################
	echo "### PROCESS U30 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	sendmail.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						echo "[WARN] ${HOSTNAME} Your system is using [ ${LIST} ]. You should consider disabling the service manually."

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-30 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						echo "[WARN] ${HOSTNAME} Your system is using [ ${LIST} ]. You should consider disabling the service manually."

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-30 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U30."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U31() {
	echo
	#########################
	echo "### PROCESS U31 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	sendmail.service
	"

	TARGET_LIST=/etc/mail/sendmail.cf

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							FUNCT_BACKUP_FILE ${TARGET_LIST}
							CHECK_SECURITY_PARAM=`grep "^R\$\*" ${TARGET_LIST} | grep "Relaying denied" | wc -l`
							ADD_CONFIG='R$*			$#error $@ 5.7.1 $: "550 Relaying denied"'

							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								echo "[WARN] ${HOSTNAME} You need to manually apply the Relay denied option. (${TARGET_LIST})"
								echo "[RECOMMEND] : ${ADD_CONFIG}"
							else
								echo "[INFO] ${HOSTNAME} This System is U-31 Check : OK (${TARGET_LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-31 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-31 Check : OK (${TARGET_LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################
						
						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							FUNCT_BACKUP_FILE ${TARGET_LIST}
							CHECK_SECURITY_PARAM=`grep "^R\$\*" ${TARGET_LIST} | grep "Relaying denied" | wc -l`
							ADD_CONFIG='R$*			$#error $@ 5.7.1 $: "550 Relaying denied"'

							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								echo "[WARN] ${HOSTNAME} You need to manually apply the Relay denied option. (${TARGET_LIST})"
								echo "[RECOMMEND] : ${ADD_CONFIG}"
							else
								echo "[INFO] ${HOSTNAME} This System is U-31 Check : OK (${TARGET_LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-31 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-31 Check : OK (${TARGET_LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U32() {
	echo
	#########################
	echo "### PROCESS U32, U70 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	sendmail.service
	"
	TARGET_LIST=/etc/mail/sendmail.cf

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_SECURITY_PARAM=`grep "^O PrivacyOptions" ${TARGET_LIST} | grep "restrictqrun" | wc -l`
							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								FUNCT_BACKUP_FILE ${TARGET_LIST}
								TARGET_LINE_NO=`grep -n "^O PrivacyOptions" ${TARGET_LIST} | cut -d : -f1`
								ADD_CONFIG="O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun"

								if [ -z ${TARGET_LINE_NO} ]
								then
									echo "[WARN] ${HOSTNAME} You need to manually apply the restrictqrun option. (${TARGET_LIST})"
									echo "[RECOMMEND] : ${ADD_CONFIG}"
								else
									echo "[WARN] ${HOSTNAME} Sendmail Restrictqrun Otion is not found. (${TARGET_LIST})"
									echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
									echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
									sed -i "${TARGET_LINE_NO}d" ${TARGET_LIST} && sed -i "${TARGET_LINE_NO}i ${ADD_CONFIG}" ${TARGET_LIST}
								fi
							else
								echo "[INFO] ${HOSTNAME} This System is U-32 Check : OK (${TARGET_LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-32 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-32 Check : OK (${TARGET_LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}	
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_SECURITY_PARAM=`grep "^O PrivacyOptions" ${TARGET_LIST} | grep "restrictqrun" | wc -l`
							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								FUNCT_BACKUP_FILE ${TARGET_LIST}
								TARGET_LINE_NO=`grep -n "^O PrivacyOptions" ${TARGET_LIST} | cut -d : -f1`
								ADD_CONFIG="O PrivacyOptions=authwarnings,novrfy,noexpn,restrictqrun"

								if [ -z ${TARGET_LINE_NO} ]
								then
									echo "[WARN] ${HOSTNAME} You need to manually apply the restrictqrun option. (${TARGET_LIST})"
									echo "[RECOMMEND] : ${ADD_CONFIG}"
								else
									echo "[WARN] ${HOSTNAME} Sendmail Restrictqrun Otion is not found. (${TARGET_LIST})"
									echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
									echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
									sed -i "${TARGET_LINE_NO}d" ${TARGET_LIST} && sed -i "${TARGET_LINE_NO}i ${ADD_CONFIG}" ${TARGET_LIST}
								fi
							else
								echo "[INFO] ${HOSTNAME} This System is U-32 Check : OK (${TARGET_LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-32 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-32 Check : OK (${TARGET_LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U33() {
	echo
	#########################
	echo "### PROCESS U33 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	named.service
	pdns.service
	pdns-recursor.service
	unbound.service
	dnsmasq.service
	knot.service
	coredns.service
	"
	
	TARGET_SERVICE_PORT="tcp/53 udp/53"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				CHECK_DNS=0
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						echo "[CHECK] ${HOSTNAME} DNS service found. (${LIST}) Manual check for latest updates is required."
						export CHECK_DNS=1

						################ Independent Processing Logic [ END ]################
					fi
				done

				FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"

				if [ ${CHECK_DNS} -eq 0 -a ${CHECK_ALL_PORT} -eq 0 ]
				then
					echo "[INFO] ${HOSTNAME} This System is U-33 Check : OK"
				elif [ ${CHECK_DNS} -eq 0 -a ${CHECK_ALL_PORT} -eq 1 ]
				then
					echo "[WARN] ${HOSTNAME} Other DNS service found. (${ARRAY_CHECK_PROCESS[@]}) Manual check for latest updates is required."
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				CHECK_DNS=0
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						echo "[CHECK] ${HOSTNAME} DNS service found. (${LIST}) Manual check for latest updates is required."
						export CHECK_DNS=1

						################ Independent Processing Logic [ END ]################
					fi
				done

				FUNCT_CHECK_PORT_LOOP "${TARGET_SERVICE_PORT}"

				if [ ${CHECK_DNS} -eq 0 -a ${CHECK_ALL_PORT} -eq 0 ]
				then
					echo "[INFO] ${HOSTNAME} This System is U-33 Check : OK"
				elif [ ${CHECK_DNS} -eq 0 -a ${CHECK_ALL_PORT} -eq 1 ]
				then
					echo "[WARN] ${HOSTNAME} Other DNS service found. (${ARRAY_CHECK_PROCESS[@]}) Manual check for latest updates is required."
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U33."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U34() {
	echo
	#########################
	echo "### PROCESS U34 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	named.service	
	"
	TARGET_LIST=/etc/named.conf

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_SECURITY_PARAM=`grep "^\s*allow-transfer" ${TARGET_LIST} | wc -l`
							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								FUNCT_BACKUP_FILE ${TARGET_LIST}
								TARGET_LINE_NO=`grep -n "^\s*directory" ${TARGET_LIST} | cut -d: -f1 | awk '{print $1 + 1}'`
								ADD_CONFIG=$(printf "\tallow-transfer\t { none; };")

								echo "[WARN] ${HOSTNAME} BIND Allow-transfer Otion is not found. (${TARGET_LIST})"
								echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
								echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
								sed -i "${TARGET_LINE_NO}i\\${ADD_CONFIG}" ${TARGET_LIST}
							else
								echo "[INFO] ${HOSTNAME} This System is U-34 Check : OK (${LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-34 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-34 Check : OK (${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						################ Independent Processing Logic [ BEGIN ] ################

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_SECURITY_PARAM=`grep "^\s*allow-transfer" ${TARGET_LIST} | wc -l`
							if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
							then
								FUNCT_BACKUP_FILE ${TARGET_LIST}
								TARGET_LINE_NO=`grep -n "^\s*directory" ${TARGET_LIST} | cut -d: -f1 | awk '{print $1 + 1}'`
								ADD_CONFIG=$(printf "\tallow-transfer\t { none; };")

								echo "[WARN] ${HOSTNAME} BIND Allow-transfer Otion is not found. (${TARGET_LIST})"
								echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
								echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
								sed -i "${TARGET_LINE_NO}i\\${ADD_CONFIG}" ${TARGET_LIST}
							else
								echo "[INFO] ${HOSTNAME} This System is U-34 Check : OK (${LIST})"	
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-34 Check."
						fi

						################ Independent Processing Logic [ END ]################
					else
						echo "[INFO] ${HOSTNAME} This System is U-34 Check : OK (${LIST})"	
					fi

				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U35() {
	echo
	#########################
	echo "### PROCESS U35, U36, U37, U38, U39, U40, U41, U71 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		EXT_MSG="This item is excluded because it requires MW Specific diagnostics."
		FUNCT_EXCEPTION "${EXT_MSG}"

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U35."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U42() {
	echo
	#########################
	echo "### PROCESS U42 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		FUNCT_SHOW_PROGRESS &
		PROGRESS_PID=$!

		FUNCT_SEARCH_CVE | sort -u > ${CVE_RESULT_LOG}
		
		kill ${PROGRESS_PID}
		wait ${PROGRESS_PID} 2>/dev/null
		echo ""

		for LIST in `cat ${CVE_RESULT_LOG}`
		do
			echo "[INFO] ${HOSTNAME} ${LIST} Patched : OK"
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U42."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U43() {
	echo
	#########################
	echo "### PROCESS U43 ###"
	#########################

	WORK_TYPE=$1

	if [ ${WORK_TYPE} == "PROC" ]
	then
		EXT_MSG="You must Manually check the log management policy."
		FUNCT_EXCEPTION "${EXT_MSG}"

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U43."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U44() {
	echo
	#########################
	echo "### PROCESS U44 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "^root|nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_ID=`id -u ${LIST}`

			if [ ${CHECK_ID} -eq 0 ] 
			then
				echo "[WARN] ${HOSTNAME} WARNING !!! You have been assigned UID 0. (${LIST} / UID ${CHECK_ID}) : Not OK"
			else
				echo "[INFO] ${HOSTNAME} No problem UID. (${LIST} / UID ${CHECK_ID}) : OK"
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U44."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U45() {
	echo
	#########################
	echo "### PROCESS U45 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/pam.d/su

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				################ Independent Processing Logic [ BEGIN ] ################

				FUNCT_CHECK_FILE ${TARGET_LIST}
				if [ ${CHECK_RESULT} -eq 0 ]
				then
					CHECK_SECURITY_PARAM=`grep "^auth\s*required\s*pam_wheel.so" ${TARGET_LIST} | wc -l`
					if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
					then
						ADD_CONFIG=$(printf "auth\t\trequired\tpam_wheel.so use_uid group=sudo")

						echo "[WARN] ${HOSTNAME} You need to manually configure wheel group permissions for the su command. (${TARGET_LIST})"
						echo "[RECOMMEND] : ${ADD_CONFIG}"
					else
						echo "[INFO] ${HOSTNAME} This System is U-45 Check : OK"	
					fi
				else
					echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-45 Check."
				fi

				################ Independent Processing Logic [ END ]################
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				################ Independent Processing Logic [ BEGIN ] ################

				FUNCT_CHECK_FILE ${TARGET_LIST}
				if [ ${CHECK_RESULT} -eq 0 ]
				then
					CHECK_SECURITY_PARAM=`grep "^auth\s*required\s*pam_wheel.so" ${TARGET_LIST} | wc -l`
					if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
					then
						ADD_CONFIG=$(printf "auth\t\trequired\tpam_wheel.so use_uid")

						echo "[WARN] ${HOSTNAME} You need to manually configure wheel group permissions for the su command. (${TARGET_LIST})"
						echo "[RECOMMEND] : ${ADD_CONFIG}"
					else
						echo "[INFO] ${HOSTNAME} This System is U-45 Check : OK"	
					fi
				else
					echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-45 Check."
				fi

				################ Independent Processing Logic [ END ]################
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U45."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U46() {
	echo
	#########################
	echo "### PROCESS U46 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/login.defs

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
				ADD_CONFIG=$(printf "PASS_MIN_LEN\t8")
				CHECK_SECURITY_PARAM=`grep "^PASS_MIN_LEN\s*" ${TARGET_LIST} | wc -l`

				if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Minimum password length configuration not found. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					echo "${ADD_CONFIG}" >> ${TARGET_LIST}
				else
					TARGET_LINE_NO=`grep -n "^PASS_MIN_LEN\s*" ${TARGET_LIST} | cut -d: -f1`
					echo "[INFO] ${HOSTNAME} Set Minimum password length configuration. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					sed -i "${TARGET_LINE_NO}d" ${TARGET_LIST} && sed -i "${TARGET_LINE_NO}i\\${ADD_CONFIG}" ${TARGET_LIST}
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-46 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U47() {
	echo
	#########################
	echo "### PROCESS U47 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/login.defs

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
				ADD_CONFIG=$(printf "PASS_MAX_DAYS\t90")
				CHECK_SECURITY_PARAM=`grep "^PASS_MAX_DAYS\s*" ${TARGET_LIST} | wc -l`

				if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Maximum password age configuration not found. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					echo "${ADD_CONFIG}" >> ${TARGET_LIST}
				else
					TARGET_LINE_NO=`grep -n "^PASS_MAX_DAYS\s*" ${TARGET_LIST} | cut -d: -f1`
					echo "[INFO] ${HOSTNAME} Set Maximum password configuration. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					sed -i "${TARGET_LINE_NO}d" ${TARGET_LIST} && sed -i "${TARGET_LINE_NO}i\\${ADD_CONFIG}" ${TARGET_LIST}
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-47 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U48() {
	echo
	#########################
	echo "### PROCESS U48 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/login.defs

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_BACKUP_FILE ${TARGET_LIST}
				ADD_CONFIG=$(printf "PASS_MIN_DAYS\t1")
				CHECK_SECURITY_PARAM=`grep "^PASS_MIN_DAYS\s*" ${TARGET_LIST} | wc -l`

				if [ ${CHECK_SECURITY_PARAM} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Minimum password age configuration not found. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					echo "${ADD_CONFIG}" >> ${TARGET_LIST}
				else
					TARGET_LINE_NO=`grep -n "^PASS_MIN_DAYS\s*" ${TARGET_LIST} | cut -d: -f1`
					echo "[INFO] ${HOSTNAME} Set Minimum password configuration. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					sed -i "${TARGET_LINE_NO}d" ${TARGET_LIST} && sed -i "${TARGET_LINE_NO}i\\${ADD_CONFIG}" ${TARGET_LIST}
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-48 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U49() {
	echo
	#########################
	echo "### PROCESS U49 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "^root|nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ -z "${TARGET_LIST}" ]
		then
			echo "[INFO] ${HOSTNAME} There are no accounts other than the system default account. : OK"
		else
			for LIST in ${TARGET_LIST}
			do
				echo "[CHECK] ${HOSTNAME} Please check if you need an account. (${LIST})"
			done
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U49."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U50() {
	echo
	#########################
	echo "### PROCESS U50 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/group

	if [ ${WORK_TYPE} == "PROC" ]
	then
		RECOMMEND_VARS="root:x:0:"
		CHECK_VARS=`grep "^root" ${TARGET_LIST}`

		if [ "${CHECK_VARS}" == "${RECOMMEND_VARS}" ]  
		then
			echo "[INFO] ${HOSTNAME} This system administrator group setting is normal. : OK"
		else
			CHECK_OTHER_ADM_GROUPS=`grep "^root" /etc/group | cut -d : -f4`
			echo "[WARN] ${HOSTNAME} WARNING!!! Non-root user found in group GID 0. (${CHECK_OTHER_ADM_GROUPS}) : Not OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U50."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U51() {
	echo
	#########################
	echo "### PROCESS U51 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`awk -F":" '$3 >= 1000 {print $1}' /etc/group`

	if [ ${WORK_TYPE} == "PROC" ]
	then

		if [ -z "${TARGET_LIST}" ]
		then
			echo "[INO] ${HOSTNAME} This system is U-51 Check : OK"
		else
			for LIST in ${TARGET_LIST}
			do
				CHECK_USER=`id ${LIST} 2>&1 | grep "no such user" | wc -l`
				if [ ${CHECK_USER} -eq 0 ]
				then
					echo "[INFO] ${HOSTNAME} This is a group in which the account exists. (${LIST}) : OK"	
				else
					echo "[WARN] ${HOSTNAME} WARNING!!! This group does not have an account. (${LIST}) : Not OK" 
				fi
			done
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U51."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U52() {
	echo
	#########################
	echo "### PROCESS U52 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`getent passwd | cut -d : -f3 | sort | uniq -d`

	if [ ${WORK_TYPE} == "PROC" ]
	then

		if [ -z "${TARGET_LIST}" ]
		then
			echo "[INFO] ${HOSTNAME} There are no accounts with duplicate UIDs. : OK"
		else
			for LIST in ${TARGET_LIST}
			do
				CHECK_DUP_USER=`awk -F: '$3 == "1000" {print "ID : "$1" / UID : "$3}' /etc/passwd`

				while IFS= read -r LIST
				do
					echo "[WARN] ${HOSTNAME} WARNING!!! An account with a duplicate UID was found. (${LIST}) : Not OK"
				done < <(echo "${CHECK_DUP_USER}") 
			done
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U52."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U53() {
	echo
	#########################
	echo "### PROCESS U53 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "^root|nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ -z "${TARGET_LIST}" ]
		then
			echo "[INFO] ${HOSTNAME} There are no accounts other than the system default account. : OK"
		else
			for LIST in ${TARGET_LIST}
			do
				CHECK_SHELL=`getent passwd ${LIST} | awk -F: '{print $NF}'`
				echo "[CHECK] ${HOSTNAME} You need to check user shell privileges. (${LIST} : ${CHECK_SHELL})"
			done
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U53."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_U54() {
	echo
	#########################
	echo "### PROCESS U54 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/profile

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				CHECK_ENV_TMOUT=`echo ${TMOUT}`
				ADD_CONFIG=$(printf "export TMOUT=600")

				if [ -z "${CHECK_ENV_TMOUT}" ] 
				then
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					echo "[WARN] ${HOSTNAME} You need to set Shell TMOUT. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					sed -i '/TMOUT/d' ${TARGET_LIST} 
					echo "${ADD_CONFIG}" >> ${TARGET_LIST}
				
				elif [ ${CHECK_ENV_TMOUT} -gt 0 -a ${CHECK_ENV_TMOUT} -le 600 ]
				then
					echo "[INFO] ${HOSTNAME} This system is U-54 Check : OK (TimeOut : ${CHECK_ENV_TMOUT})" 	
				else
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} You need to change config Shell TMOUT. (${TARGET_LIST})"
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG}"
					sed -i '/TMOUT/d' ${TARGET_LIST} 
					echo "${ADD_CONFIG}" >> ${TARGET_LIST}
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-54 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U56() {
	echo
	#########################
	echo "### PROCESS U56 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/profile

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				CHECK_ENV_UMASK=`umask`
				ADD_CONFIG1=$(printf "umask 022 ### Add set umask ${DATE_TIME} : $0 ###")
				ADD_CONFIG2=$(printf "export umask ### Add set umask ${DATE_TIME} : $0 ###")

				if [ "${CHECK_ENV_UMASK}" != "0022" ] 
				then
					echo "[WARN] ${HOSTNAME} You need to set UMASK. (${TARGET_LIST})"
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG1}"
					echo "[INFO] ${HOSTNAME} ${TARGET_LIST} : ${ADD_CONFIG2}"
					sed -i '/Add set umask/d' ${TARGET_LIST} 
					echo "${ADD_CONFIG1}" >> ${TARGET_LIST}
					echo "${ADD_CONFIG2}" >> ${TARGET_LIST}
				else
					echo "[INFO] ${HOSTNAME} This system is U-56 Check : OK (UMASK : ${CHECK_ENV_UMASK})" 	
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-56 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U57() {
	echo
	#########################
	echo "### PROCESS U57 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_HOME_DIR=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | awk -F : '$1 ~ /^'"${LIST}"'$/ {print $6}'`
			FUNCT_CHECK_PERM ${CHECK_HOME_DIR}
			OTHER_DIR_PERM=`echo "${CHECK_FILE_PERM_VAL}" | cut -c 3`

			if [ ${OTHER_DIR_PERM} -eq 0 -a ${CHECK_FILE_OWNER_VAL} == "${LIST}" ] 
			then
				echo "[INFO] ${HOSTNAME} ${LIST} : Home DIR permissions and Owner Check OK. (${CHECK_FILE_PERM_VAL} / ${CHECK_FILE_OWNER_VAL}) : ${CHECK_HOME_DIR}"

			elif [ ${CHECK_FILE_OWNER_VAL} != "${LIST}" ]
			then
				echo "[WARN] ${HOSTNAME} ${LIST} : Home DIR Owner information of the account does not match. (${CHECK_FILE_OWNER_VAL}) : ${CHECK_HOME_DIR}"
			else
				echo "[WARN] ${HOSTNAME} ${LIST} : HOME DIR permissions include other user permissions (${CHECK_FILE_PERM_VAL}) : ${CHECK_HOME_DIR}"
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U57."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U58() {
	echo
	#########################
	echo "### PROCESS U58 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | cut -d : -f1`

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_HOME_DIR=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | awk -F : '$1 ~ /^'"${LIST}"'$/ {print $6}'`
			FUNCT_CHECK_FILE ${CHECK_HOME_DIR}

			if [ ${CHECK_RESULT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} ${LIST} : Home DIR exists OK. : ${CHECK_HOME_DIR}"
			else
				echo "[WARN] ${HOSTNAME} ${LIST} : Home DIR does not exists. : ${CHECK_HOME_DIR}"
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U58."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U59() {
	echo
	#########################
	echo "### PROCESS U59 ###"
	#########################

	WORK_TYPE=$1

EX_LIST="
.bash_logout
.bash_profile
.bashrc
.cshrc
.tcshrc
.cache
.config
.bash_history
.pki
.ansible
.ansible.cfg
.ssh
.vim
.viminfo
.aws
.rhosts
.pwd.lock
.updated
.*.swp
.minio
.minio.sys
"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		echo "[EXCEPTION] ${HOSTNAME} : /proc, /usr, /boot, /var/lib, /run, /etc/skel, /tmp, /sys"
		FIND_CMD_OPT=(/ ! \( \( -path '/proc' -o -path '/usr' -o -path '/boot' -o -path '/var/lib' -o -path '/run' -o -path '/etc/skel' -o -path '/tmp' -o -path '/sys' \) -prune \) -name ".*")

		IFS=$'\n'
		for OPT_LIST in ${EX_LIST}
		do
			FIND_CMD_OPT+=( ! -name "$OPT_LIST" )
		done

		TARGET_LIST=`find "${FIND_CMD_OPT[@]}" 2>/dev/null`

		for LIST in ${TARGET_LIST}
		do
			FUNCT_CHECK_DIR ${LIST}

			if [ ${CHECK_DIR_STAT} -eq 0 ]
			then
				echo "[WARN] ${HOSTNAME} : You need to Check Hidden directorys. : ${LIST}"
			else
				echo "[WARN] ${HOSTNAME} : You need to Check Hidden files. : ${LIST}"
			fi
		done

		unset IFS

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U59."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U60() {
	echo
	#########################
	echo "### PROCESS U60 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	sshd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[INFO] ${HOSTNAME} This System is U-60 Check : OK (Enable : ${LIST})"	
					else
						echo "[WARN] ${HOSTNAME} SSH Service is not enabled. : Not OK"	
						echo "[INFO] ${HOSTNAME} Enable and Start : ${LIST}"	
						FUNCT_BACKUP_SERVICE ${LIST}
						systemctl enable ${LIST}
						systemctl start ${LIST}
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[INFO] ${HOSTNAME} This System is U-60 Check : OK (Enable : ${LIST})"	
					else
						echo "[WARN] ${HOSTNAME} SSH Service is not enabled. : Not OK"	
						echo "[INFO] ${HOSTNAME} Enable and Start : ${LIST}"	
						FUNCT_BACKUP_SERVICE ${LIST}
						systemctl enable ${LIST}
						systemctl start ${LIST}
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U61() {
	echo
	#########################
	echo "### PROCESS U61 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	vsftpd.service
	proftpd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	
					else
						echo "[INFO] ${HOSTNAME} This System is U-61 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	
					else
						echo "[INFO] ${HOSTNAME} This System is U-61 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U61."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U62() {
	echo
	#########################
	echo "### PROCESS U62 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/passwd

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" -o ${OS_PLATFORM} = "RHEL" ]
		then
			################ Independent Processing Logic [ BEGIN ] ################

			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				CHECK_SHELL=`getent passwd ftp | awk -F: '{print $NF}'`
				if [ "${CHECK_SHELL}" == "/sbin/nologin" ]
				then
					echo "[INFO] ${HOSTNAME} Shell permission for ftp account is ok."
				else
					echo "[WARN] ${HOSTNAME} You need to change the permissions of the ftp account: /sbin/nologin"
					FUNCT_BACKUP_FILE ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : ${TARGET_LIST}"
					usermod -s /sbin/nologin ftp
				fi
			else
				echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-62 Check."
			fi

			################ Independent Processing Logic [ END ]################
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_FILE ${TARGET_LIST}
		if [ ${CHECK_RESULT} -eq 0 ]
		then
			FUNCT_RESTORE_FILE ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${TARGET_LIST}"
		fi
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U63() {
	echo
	#########################
	echo "### PROCESS U63 ###"
	#########################

	WORK_TYPE=$1

	PERM_640_LIST="
	/etc/ftpusers
	/etc/vsftpd/ftpusers
	/etc/vsftpd/user_list
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for TARGET_LIST in ${PERM_640_LIST}
		do
			FUNCT_CHECK_FILE ${TARGET_LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_CHECK_PERM ${TARGET_LIST}

				if [ "${CHECK_FILE_OWNER_VAL}" == "root" -a "${CHECK_FILE_PERM_VAL}" == "640" ]
				then
					echo "[INFO] ${HOSTNAME} This System is U-63 Check : OK (${TARGET_LIST})"
				else
					echo "[WARN] ${HOSTNAME} You need to change Permission 640 and Owner info root : ${TARGET_LIST}"
					FUNCT_BACKUP_PERM ${TARGET_LIST}
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 640 ${TARGET_LIST} && chown root ${TARGET_LIST}"
					chown root ${TARGET_LIST} 
					chmod 640 ${TARGET_LIST} 
				fi
			else
				echo "[INFO] ${HOSTNAME} This System is U-63 Check : OK (${TARGET_LIST})"
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for TARGET_LIST in ${PERM_640_LIST}
		do
			FUNCT_CHECK_PERM_BACKUP ${TARGET_LIST}
			FUNCT_RESTORE_PERM ${TARGET_LIST} ALL
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U64() {
	echo
	#########################
	echo "### PROCESS U64 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST="
	/etc/ftpusers
	/etc/vsftpd/ftpusers
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				CHECK_LIMIT_ROOT=`grep "root" ${LIST} | wc -l`
				if [ "${CHECK_LIMIT_ROOT}" -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} You need to FTP access restriction root. : ${LIST}"
					FUNCT_BACKUP_FILE ${LIST}
					echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : Add 'root' ${LIST}"
					echo "root" >> ${LIST}
				else
					echo "[INFO] ${HOSTNAME} This System is U-64 Check : OK (FTP access restriction root. ${LIST})"
				fi
			else
				echo "[INFO] ${HOSTNAME} This System is U-64 Check : OK (${LIST})"
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${LIST}"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U65() {
	echo
	#########################
	echo "### PROCESS U65 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="atd.service"

	PERM_640_LIST="
	/etc/at.allow
	/etc/at.deny
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_SERVICE ${TARGET_SERVICE_LIST}
				if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Please check if you need this service. (${TARGET_SERVICE_LIST})"
					for TARGET_LIST in ${PERM_640_LIST}
					do
						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then 
							FUNCT_CHECK_PERM ${TARGET_LIST}		
							if [ "${CHECK_FILE_OWNER_VAL}" == "root" -a "${CHECK_FILE_PERM_VAL}" == "640" ]
							then
								echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (${TARGET_LIST})"
							else
								echo "[WARN] ${HOSTNAME} You need to change Permission 640 and Owner info root : ${TARGET_LIST}"
								FUNCT_BACKUP_PERM ${TARGET_LIST}
								echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 640 ${TARGET_LIST} && chown root ${TARGET_LIST}"
								chown root ${TARGET_LIST} 
								chmod 640 ${TARGET_LIST} 
							fi
						else
							echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (${TARGET_LIST})"
						fi
					done
				else
					echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (Disable : ${TARGET_SERVICE_LIST})"	
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_SERVICE ${TARGET_SERVICE_LIST}
				if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Please check if you need this service. (${TARGET_SERVICE_LIST})"
					for TARGET_LIST in ${PERM_640_LIST}
					do
						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then 
							FUNCT_CHECK_PERM ${TARGET_LIST}		
							if [ "${CHECK_FILE_OWNER_VAL}" == "root" -a "${CHECK_FILE_PERM_VAL}" == "640" ]
							then
								echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (${TARGET_LIST})"
							else
								echo "[WARN] ${HOSTNAME} You need to change Permission 640 and Owner info root : ${TARGET_LIST}"
								FUNCT_BACKUP_PERM ${TARGET_LIST}
								echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 640 ${TARGET_LIST} && chown root ${TARGET_LIST}"
								chown root ${TARGET_LIST} 
								chmod 640 ${TARGET_LIST} 
							fi
						else
							echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (${TARGET_LIST})"
						fi
					done
				else
					echo "[INFO] ${HOSTNAME} This System is U-65 Check : OK (Disable : ${TARGET_SERVICE_LIST})"	
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for TARGET_LIST in ${PERM_640_LIST}
		do
			FUNCT_CHECK_PERM_BACKUP ${TARGET_LIST}
			FUNCT_RESTORE_PERM ${TARGET_LIST} ALL
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U66() {
	echo
	#########################
	echo "### PROCESS U66 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	snmpd.service
	snmptrapd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	
					else
						echo "[INFO] ${HOSTNAME} This System is U-66 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	
					else
						echo "[INFO] ${HOSTNAME} This System is U-66 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U66."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U67() {
	echo
	#########################
	echo "### PROCESS U67 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST=/etc/snmp/snmpd.conf

	TARGET_SERVICE_LIST="
	snmpd.service
	snmptrapd.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_COMMUNITY=`grep "^com2sec" ${TARGET_LIST} | awk '{print $NF}'`

							if [ "${CHECK_COMMUNITY}" == "public" -o "${CHECK_COMMUNITY}" == "private" ]
							then
								echo "[WARN] ${HOSTNAME} You need to change SNMP Community name. (${TARGET_LIST} : ${CHECK_COMMUNITY})"
							else
								echo "[INFO] ${HOSTNAME} This System is U-67 Check : OK (${TARGET_LIST})"
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-67 Check."
						fi
					else
						echo "[INFO] ${HOSTNAME} This System is U-67 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[WARN] ${HOSTNAME} Please check if you need this service. (${LIST})"	

						FUNCT_CHECK_FILE ${TARGET_LIST}
						if [ ${CHECK_RESULT} -eq 0 ]
						then
							CHECK_COMMUNITY=`grep "^com2sec" ${TARGET_LIST} | awk '{print $NF}'`

							if [ "${CHECK_COMMUNITY}" == "public" -o "${CHECK_COMMUNITY}" == "private" ]
							then
								echo "[WARN] ${HOSTNAME} You need to change SNMP Community name. (${TARGET_LIST} : ${CHECK_COMMUNITY})"
							else
								echo "[INFO] ${HOSTNAME} This System is U-67 Check : OK (${TARGET_LIST})"
							fi
						else
							echo "[CHECK] ${HOSTNAME} Not Found Target Config file (${TARGET_LIST}) & U-67 Check."
						fi
					else
						echo "[INFO] ${HOSTNAME} This System is U-67 Check : OK (Disable : ${LIST})"	
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} Not support recovery option for Function U67."
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U68() {
	echo
	#########################
	echo "### PROCESS U68 ###"
	#########################

	WORK_TYPE=$1

	TARGET_LIST="
	/etc/motd
	/etc/issue
	/etc/issue.net
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then 
				FUNCT_BACKUP_FILE ${LIST}
				echo "[INFO] ${HOSTNAME} Change the Banner message file. : ${LIST}"
				cat > ${LIST} << EOF
				${MOTD_MESSAGE}
EOF
			else
				echo "[INFO] ${HOSTNAME} Create Banner message file : ${LIST}"
				cat > ${LIST} << EOF
				${MOTD_MESSAGE}
EOF
			fi
		done
	
	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_LIST}
		do
			FUNCT_CHECK_FILE ${LIST}
			if [ ${CHECK_RESULT} -eq 0 ]
			then
				FUNCT_RESTORE_FILE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : File backup) : ${LIST}"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U69() {
	echo
	#########################
	echo "### PROCESS U69 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="nfs.service"

	TARGET_LIST=/etc/exports

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_SERVICE ${TARGET_SERVICE_LIST}
				if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Please check if you need this service. (${TARGET_SERVICE_LIST})"

					FUNCT_CHECK_FILE ${TARGET_LIST}
					if [ ${CHECK_RESULT} -eq 0 ]
					then 
						FUNCT_CHECK_PERM ${TARGET_LIST}		
						if [ "${CHECK_FILE_OWNER_VAL}" == "root" -a "${CHECK_FILE_PERM_VAL}" == "644" ]
						then
							echo "[INFO] ${HOSTNAME} This System is U-69 Check : OK (${TARGET_LIST})"
						else
							echo "[WARN] ${HOSTNAME} You need to change Permission 644 and Owner info root : ${TARGET_LIST}"
							FUNCT_BACKUP_PERM ${TARGET_LIST}
							echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 644 ${TARGET_LIST} && chown root ${TARGET_LIST}"
							chown root ${TARGET_LIST} 
							chmod 644 ${TARGET_LIST} 
						fi
					else
						echo "[CHECK] ${HOSTNAME} Not Found Target Config file. (${TARGET_LIST})"
					fi
				else
					echo "[INFO] ${HOSTNAME} This System is U-69 Check : OK (Disable : ${TARGET_SERVICE_LIST})"	
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				FUNCT_CHECK_SERVICE ${TARGET_SERVICE_LIST}
				if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
				then
					echo "[WARN] ${HOSTNAME} Please check if you need this service. (${TARGET_SERVICE_LIST})"

					FUNCT_CHECK_FILE ${TARGET_LIST}
					if [ ${CHECK_RESULT} -eq 0 ]
					then 
						FUNCT_CHECK_PERM ${TARGET_LIST}		
						if [ "${CHECK_FILE_OWNER_VAL}" == "root" -a "${CHECK_FILE_PERM_VAL}" == "644" ]
						then
							echo "[INFO] ${HOSTNAME} This System is U-69 Check : OK (${TARGET_LIST})"
						else
							echo "[WARN] ${HOSTNAME} You need to change Permission 644 and Owner info root : ${TARGET_LIST}"
							FUNCT_BACKUP_PERM ${TARGET_LIST}
							echo "[INFO] ${HOSTNAME} Processing RECOMMEND Option : chmod 644 ${TARGET_LIST} && chown root ${TARGET_LIST}"
							chown root ${TARGET_LIST} 
							chmod 644 ${TARGET_LIST} 
						fi
					else
						echo "[CHECK] ${HOSTNAME} Not Found Target Config file. (${TARGET_LIST})"
					fi
				else
					echo "[INFO] ${HOSTNAME} This System is U-69 Check : OK (Disable : ${TARGET_SERVICE_LIST})"	
				fi
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		FUNCT_CHECK_PERM_BACKUP ${TARGET_LIST}
		FUNCT_RESTORE_PERM ${TARGET_LIST} ALL
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}

FUNCT_U72() {
	echo
	#########################
	echo "### PROCESS U72 ###"
	#########################

	WORK_TYPE=$1

	TARGET_SERVICE_LIST="
	rsyslog.service
	"

	if [ ${WORK_TYPE} == "PROC" ]
	then
		if [ ${OS_PLATFORM} = "UBUNTU" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 18.04
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[INFO] ${HOSTNAME} This System is U-72 Check : OK (Enable : ${LIST})"	
					else
						echo "[WARN] ${HOSTNAME} Syslog Service is not enabled. : Not OK"	
						echo "[INFO] ${HOSTNAME} Enable and Start : ${LIST}"	
						FUNCT_BACKUP_SERVICE ${LIST}
						systemctl enable ${LIST}
						systemctl start ${LIST}
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				for LIST in ${TARGET_SERVICE_LIST}
				do
					FUNCT_CHECK_SERVICE ${LIST}
					if [ ${CHECK_SERVICE_RESULT} -eq 0 ]
					then
						echo "[INFO] ${HOSTNAME} This System is U-72 Check : OK (Enable : ${LIST})"	
					else
						echo "[WARN] ${HOSTNAME} Syslog Service is not enabled. : Not OK"	
						echo "[INFO] ${HOSTNAME} Enable and Start : ${LIST}"	
						FUNCT_BACKUP_SERVICE ${LIST}
						systemctl enable ${LIST}
						systemctl start ${LIST}
					fi
				done
			else
				echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
			fi
		else
			echo "[CHECK] ${HOSTNAME} This script supports RHEL 7.x, Ubuntu 18.04 and later systemd-based OS."
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		for LIST in ${TARGET_SERVICE_LIST}
		do
			FUNCT_CHECK_SERVICE_BACKUP ${LIST}	
			if [ ${CHECK_SERVICE_BACKUP} -eq 0 ]
			then
				FUNCT_RESTORE_SERVICE ${LIST}
			else
				echo "[INFO] ${HOSTNAME} Can not be recovered. (Not found : Service backup)"
			fi
		done
	else
		echo "[ERROR] ${HOSTNAME} Input Work type is Only PROC or RESTORE"
		exit 1
	fi
}


FUNCT_MAIN_PROCESS() {
	WORK_TYPE=$1

	###########################
	#### Main Process Flow ####
	###########################
	
	FUNCT_U01 ${WORK_TYPE}
	FUNCT_U02 ${WORK_TYPE}
	FUNCT_U03 ${WORK_TYPE}
	FUNCT_U04 ${WORK_TYPE}
	FUNCT_U05 ${WORK_TYPE}
	FUNCT_U06 ${WORK_TYPE}
	FUNCT_U08 ${WORK_TYPE}
	FUNCT_U09 ${WORK_TYPE} ### with U07, U10, U12, U55 ###
	FUNCT_U11 ${WORK_TYPE}
	FUNCT_U13 ${WORK_TYPE}
	FUNCT_U14 ${WORK_TYPE}
	FUNCT_U15 ${WORK_TYPE}
	FUNCT_U16 ${WORK_TYPE}
	FUNCT_U17 ${WORK_TYPE}
	FUNCT_U18 ${WORK_TYPE} ### Exception : Not need FUNCT_U18 ###
	FUNCT_U19 ${WORK_TYPE}
	FUNCT_U20 ${WORK_TYPE}
	FUNCT_U21 ${WORK_TYPE}
	FUNCT_U22 ${WORK_TYPE}
	FUNCT_U23 ${WORK_TYPE}
	FUNCT_U24 ${WORK_TYPE} ### with U25 ###
	FUNCT_U26 ${WORK_TYPE}
	FUNCT_U27 ${WORK_TYPE}
	FUNCT_U28 ${WORK_TYPE}
	FUNCT_U29 ${WORK_TYPE}
	FUNCT_U30 ${WORK_TYPE}
	FUNCT_U31 ${WORK_TYPE}
	FUNCT_U32 ${WORK_TYPE} ### with U70 ###
	FUNCT_U33 ${WORK_TYPE}
	FUNCT_U34 ${WORK_TYPE}
	FUNCT_U35 ${WORK_TYPE} ### Exception : MW (Middleware) diagnostic items. & with U36, U37, U38, U39, U40, U41, U71
	FUNCT_U42 ${WORK_TYPE}
	FUNCT_U43 ${WORK_TYPE} ### Exception : You must manually check the log management policy.
	FUNCT_U44 ${WORK_TYPE}
	FUNCT_U45 ${WORK_TYPE}
	FUNCT_U46 ${WORK_TYPE}
	FUNCT_U47 ${WORK_TYPE}
	FUNCT_U48 ${WORK_TYPE}
	FUNCT_U49 ${WORK_TYPE}
	FUNCT_U50 ${WORK_TYPE}
	FUNCT_U51 ${WORK_TYPE}
	FUNCT_U52 ${WORK_TYPE}
	FUNCT_U53 ${WORK_TYPE}
	FUNCT_U54 ${WORK_TYPE}
	FUNCT_U56 ${WORK_TYPE}
	FUNCT_U57 ${WORK_TYPE}
	FUNCT_U58 ${WORK_TYPE}
	FUNCT_U59 ${WORK_TYPE}
	FUNCT_U60 ${WORK_TYPE}
	FUNCT_U61 ${WORK_TYPE}
	FUNCT_U62 ${WORK_TYPE}
	FUNCT_U63 ${WORK_TYPE}
	FUNCT_U64 ${WORK_TYPE}
	FUNCT_U65 ${WORK_TYPE}
	FUNCT_U66 ${WORK_TYPE}
	FUNCT_U67 ${WORK_TYPE}
	FUNCT_U68 ${WORK_TYPE}
	FUNCT_U69 ${WORK_TYPE}
	FUNCT_U72 ${WORK_TYPE}
}

##############################################################################

FUNCT_CHECK_OS
FUNCT_MANDATORY ${WORK_TYPE}

echo
echo "[RECOMMEND] Be sure to read the guide document before running."
echo "https://github.com/infra-se/system/blob/main/KISA_SECURITY/README.md"
echo
echo "[QUESTION] Do you want run Script ? : y or n"
echo
read ANSWER

if [ "${ANSWER}" == "y" -o "${ANSWER}" == "Y" ]
then
	if [ ${CHECK_WORK_TYPE} -eq 0 ]
	then
		mkdir -p ${BACKUP_ROOT_DIR} ${BACKUP_SERVICE_DIR} ${BACKUP_PERMISSION_DIR}
	fi

	FUNCT_MAIN_PROCESS ${WORK_TYPE} | tee ${LOG_DIR}/${DATE_TIME}_sec_std_conf.log
	echo
else
	echo "[INFO] Stop Script Now."
	echo
	exit 0
fi

##############################################################################
