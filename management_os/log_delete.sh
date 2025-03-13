#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : log delete script
SCRIPT_VER=0.3.20250313

export LANG=C
export LC_ALL=C

LOG_DIR=/root/shell/logs
LOG_DATE=`date +%Y%m%d_%H%M%S`
LOG_NAME=${LOG_DATE}_log_delete.log
mkdir -p ${LOG_DIR}

LOG_DIR_LIST="/logs/syslog /logs/iptables"
LOG_LIMIT_DAY=30

FUNCT_LOG_DELETE() {
	LOG_DIR=$1
	DELETE_LIST=/tmp/delete_backup.list

	find ${LOG_DIR} -type f -mtime +${LOG_LIMIT_DAY} > ${DELETE_LIST}
	
	CHECK_DELETE_LIST=`cat ${DELETE_LIST} | wc -l`
	
	if [ ${CHECK_DELETE_LIST} -gt 0 ]
	then
		echo  "[INFO] ${LOG_DATE} Delete Log List : ${LOG_DIR}"
		cat ${DELETE_LIST}

		for D_LIST in `cat ${DELETE_LIST}`
		do
			echo "Delete : ${D_LIST}"
			rm -f ${D_LIST}
		done
	else
		echo  "[INFO] ${LOG_DATE} There is no file to delete : ${LOG_DIR}"
	fi
}

FUNCT_MAIN() {
	echo "### Run Delete Log Script ###"

	for LIST in ${LOG_DIR_LIST}
	do
		FUNCT_LOG_DELETE ${LIST}
	done
}

FUNCT_MAIN | tee -a ${LOG_DIR}/${LOG_NAME}
