#!/bin/bash
#Script by helperchoi@gmail.com
SCRIPT_DESCRIPTION="KISA Vulnerability Diagnosis Automation Script"
SCRIPT_VERSION=0.9.20250328

export LANG=C
export LC_ALL=C

WORK_TYPE=$1
readonly DATE_TIME=`date '+%Y%m%d_%H%M%S'`
LOG_DIR=/root/shell/KISA_SECURITY/logs
COMMON_VARS_DIR=/root/shell/KISA_SECURITY
COMMON_VARS=${COMMON_VARS_DIR}/common
BACKUP_ROOT_DIR=/root/shell/CONF_BACKUP
BACKUP_SERVICE_DIR=/root/shell/CONF_BACKUP/service
BACKUP_PERMISSION_DIR=/root/shell/CONF_BACKUP/permission
mkdir -p ${LOG_DIR} ${COMMON_VARS_DIR} ${BACKUP_ROOT_DIR} ${BACKUP_SERVICE_DIR} ${BACKUP_PERMISSION_DIR}

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
		if [ ${WORK_TYPE} == "PROC" -o ${WORK_TYPE} == "RESTORE" ]
		then
			export CHECK_WORK_TYPE=0
		else
			export CHECK_WORK_TYPE=1

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
	CHECK_FILE_OWNER=`ls -l ${TARGET_LIST} | awk '{print $3}'`
	CHECK_FILE_GROUP=`ls -l ${TARGET_LIST} | awk '{print $4}'`
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
		echo "[INFO] ${HOSTNAME} Permission Backup file not found and No Restore : ${TARGET_LIST}" 
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
	CHECK_BACKUP_FILE_NONE_CONFIG=`grep "^NONE$" ${LAST_BACKUP_FILE} | wc -l`

	if [ ${CHECK_RESULT_BACKUP} -eq 0 -a ${CHECK_SYMBOLIC_STAT} -eq 0 ]
	then
		if [ ${CHECK_BACKUP_FILE_NONE_CONFIG} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Restore File : ${LAST_BACKUP_FILE} -> ${TARGET_LIST}"
			cp -fpP ${LAST_BACKUP_FILE} ${TARGET_LIST}
		else
			echo "[INFO] ${HOSTNAME} AS-IS Config is None : ${LAST_BACKUP_FILE}"
			echo "[INFO] ${HOSTNAME} Restore Type is Config Delete : ${TARGET_LIST}"
			rm -f ${TARGET_LIST}
		fi

	elif [ ${CHECK_RESULT_BACKUP} -eq 0 -a ${CHECK_SYMBOLIC_STAT} -eq 1 ]
	then
		if [ ${CHECK_BACKUP_FILE_NONE_CONFIG} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Restore File : ${LAST_BACKUP_FILE} -> ${ORIGIN_FILE}"
			cp -fpP ${LAST_BACKUP_FILE} ${ORIGIN_FILE}
		else
			echo "[INFO] ${HOSTNAME} AS-IS Config is None : ${LAST_BACKUP_FILE}"
			echo "[INFO] ${HOSTNAME} Restore Type is Config Delete : ${ORIGIN_FILE}"
			rm -f ${ORIGIN_FILE}
		fi
	else
		echo "[INFO] ${HOSTNAME} Backup file not found and No Restore : ${TARGET_LIST}" 
	fi
}


FUNCT_CHECK_SERVICE() {
	TARGET_SERVICE=$1
	CHECK_SERVICE_STAT=`systemctl is-enabled ${TARGET_SERVICE} 2>&1`

	if [ ${CHECK_SERVICE_STAT} = "enabled" ]
	then
		export CHECK_SERVICE_RESULT=0

	elif [ ${CHECK_SERVICE_STAT} = "disabled" ]
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

FUNCT_SERVICE_PROCESS() {
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
	echo "[INFO] ${HOSTNAME} Exception: ${EXT_MSG} : OK"
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
		echo "[INFO] ${HOSTNAME} There is no recovery option for Function U04."
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
		echo "[INFO] ${HOSTNAME} There is no recovery option for Function U05."
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
		TARGET_LIST=${BACKUP_ROOT_DIR}/NONE_USER_LIST
		find / ! \( \( -path '/proc' -o -path '/root/shell/CONF_BACKUP' -o -path '/var/lib' -o -path '/run' -o -path '/run/containerd' -o -path '/app/data/kubelet' \) -prune \) -type f -a -nouser -exec ls -a1Ld {} \; > ${TARGET_LIST}

		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ ${CHECK_TARGET_OBJECT} -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_CHECK_FILE ${LIST}
				################ Independent Processing Logic [ BEGIN ] ################
	
				echo "[WARN] ${HOSTNAME} File is without owner and do not exist account : ${LIST}"
	
				################ Independent Processing Logic [ END ] ################
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-06 Check OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/NONE_USER_LIST
		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_RESTORE_FILE ${LIST}
			done
		elif [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Backup File Not found."
		else
			echo "[INFO] ${HOSTNAME} Backup File Not found."
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
	echo "### PROCESS U07, U09, U10, U12 ###"
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
				echo "[INFO] ${HOSTNAME} ${TARGET_LIST} file does not exist : OK"
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

	if [ ${WORK_TYPE} == "PROC" ]
	then
		for LIST in ${TARGET_LIST}
		do
			CHECK_HOME_DIR=`egrep -v "nologin$|false$|sync$|shutdown$|halt$" /etc/passwd | awk -F : '$1 ~ /^'"${LIST}"'$/ {print $6}'`
			FULL_DIR_PERM=`stat -c '%a' ${CHECK_HOME_DIR}`
			OTHER_DIR_PERM=`stat -c '%a' ${CHECK_HOME_DIR} | cut -c 3`

			if [ ${OTHER_DIR_PERM} -eq 0 ] 
			then
				echo "[INFO] ${HOSTNAME} ${LIST} : No problem with Home DIR permissions (${FULL_DIR_PERM}) : ${CHECK_HOME_DIR}"
			else
				echo "[WARN] ${HOSTNAME} ${LIST} : HOME DIR permissions include other user permissions (${FULL_DIR_PERM}) : ${CHECK_HOME_DIR}"
			fi
		done

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then
		echo "[INFO] ${HOSTNAME} There is no recovery option for Function U14."
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
		TARGET_LIST=${BACKUP_ROOT_DIR}/WORLD_WRITABLE_LIST
		find / ! \( \( -path '/proc' -o -path '/root/shell/CONF_BACKUP' -o -path '/var/lib' -o -path '/run' -o -path '/run/containerd' -o -path '/sys' \) -prune \) -type f -perm -2 -exec ls -1 {} \; > ${TARGET_LIST}

		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ ${CHECK_TARGET_OBJECT} -gt 0 ]
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
					echo "[INFO] ${HOSTNAME} ${LIST} file does not exist : OK"
				fi
				
				################ Independent Processing Logic [ BEGIN ] ################
	
				echo "[INFO] ${HOSTNAME} Change File Permission (chmod o-w) : ${LIST}"
				chmod o-w ${LIST}
				echo
	
				################ Independent Processing Logic [ END ] ################
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-15 Check OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/WORLD_WRITABLE_LIST
		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -gt 0 ]
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

		elif [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Backup File Not found."
		else
			echo "[INFO] ${HOSTNAME} Backup File Not found."
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

		if [ ${CHECK_TARGET_OBJECT} -gt 0 ]
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
					echo "[OK] ${HOSTNAME} Does not exist : ${LIST}" 
				fi
			done
		else
			echo "[INFO] ${HOSTNAME} This System is U-16 Check OK"
		fi

	elif [ ${WORK_TYPE} == "RESTORE" ]
	then	
		TARGET_LIST=${BACKUP_ROOT_DIR}/DEV_UNACCEPTABLE_LIST
		CHECK_TARGET_OBJECT=`wc -l ${TARGET_LIST} | awk '{print $1}'`

		if [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -gt 0 ]
		then
			for LIST in `cat ${TARGET_LIST}`
			do
				FUNCT_RESTORE_FILE ${LIST}
			done
		elif [ -e ${TARGET_LIST} -a ${CHECK_TARGET_OBJECT} -eq 0 ]
		then
			echo "[INFO] ${HOSTNAME} Backup File Not found."
		else
			echo "[INFO] ${HOSTNAME} Backup File Not found."
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
				echo "[INFO] ${HOSTNAME} This System is U-17 Check OK"	
			else
				INNER_FUNCT_BACKUP ${ARRAY_TAGET_LIST}
			fi

		elif [ ${OS_PLATFORM} = "RHEL" ]
		then
			FUNCT_CHECK_COMPARE ${OS_VERSION} 7
			if [ ${CHECK_COMPARE_RESULT} -eq 0 ]
			then
				echo "[INFO] ${HOSTNAME} This System is U-17 Check OK"
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
				echo "[INFO] ${HOSTNAME} This System is U-17 Check OK"
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
				echo "[INFO] ${HOSTNAME} This System is U-19 Check OK"
			fi

			################ Independent Processing Logic [ END ]################
		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 0 ]
		then
			FUNCT_SERVICE_PROCESS ${TARGET_SEVICE}

		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 1 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-19 Check OK"

		elif [ ${CHECK_RESULT} -eq 1 -a ${CHECK_SERVICE_RESULT} -eq 2 ]
		then
			echo "[INFO] ${HOSTNAME} This System is U-19 Check OK"
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
				echo "[INFO] ${HOSTNAME} This System is U-20 Check OK : ${LIST}"	
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
	FUNCT_U09 ${WORK_TYPE} ### with U07, U10, U12 ###
	FUNCT_U11 ${WORK_TYPE}
	FUNCT_U13 ${WORK_TYPE}
	FUNCT_U14 ${WORK_TYPE}
	FUNCT_U15 ${WORK_TYPE}
	FUNCT_U16 ${WORK_TYPE}
	FUNCT_U17 ${WORK_TYPE}
	FUNCT_U18 ${WORK_TYPE} ### Exception : Not need FUNCT_U18 ###
	FUNCT_U19 ${WORK_TYPE}
	FUNCT_U20 ${WORK_TYPE}
	FUNCT_U22 ${WORK_TYPE}
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
	FUNCT_MAIN_PROCESS ${WORK_TYPE} | tee ${LOG_DIR}/${DATE_TIME}_sec_std_conf.log
	echo
else
	echo "[INFO] Stop Script Now."
	echo
	exit 0
fi

##############################################################################
