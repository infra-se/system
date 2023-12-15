#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.3.20231212
ANSIBLE_ACCOUNT=helperchoi
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=C
export LC_ALL=C

if [ $# -ne 1 ]
then
	echo
	echo "### 1. Edit Inventory File  : vi /home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/INVENTORY/work.hosts or prod.hosts ###"
	echo "### 2. Select Group Name : WORK_LIST, PROD_LIST ###"
	echo
	echo "Usage ex) : $0 WORK_LIST or PROD_LIST"
	echo
	exit 0
fi

#####################
#### COMMON VARS ####
#####################

ANSIBLE_INVENTORY_DIR=/home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/INVENTORY
ANSIBLE_SUB_ANSIBLE_SCRIPT_DIR=/home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/SUB_SCRIPT
ANSIBLE_YAML_DIR=/home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/YAML
ANSIBLE_SCRIPT_NAME=ci_collect

FINAL_RESULT_PATH=/home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/CI_RESULT
ANSIBLE_RAW_LOG=${FINAL_RESULT_PATH}/ansible_raw.log
TMP_RESULT_LOG=${FINAL_RESULT_PATH}/ci_collect_raw.log
CI_LOG_01=${FINAL_RESULT_PATH}/ci_01.log
CI_LOG_02=${FINAL_RESULT_PATH}/ci_02.log
CI_LOG_03=${FINAL_RESULT_PATH}/ci_03.log
CI_LOG_04=${FINAL_RESULT_PATH}/ci_04.log
CI_LOG_05=${FINAL_RESULT_PATH}/ci_05.log
CI_LOG_06=${FINAL_RESULT_PATH}/ci_06.log
CI_LOG_07=${FINAL_RESULT_PATH}/ci_07.log

mkdir -p ${FINAL_RESULT_PATH}


#########################
#### COMMON FUNCTION ####
#########################

FUNCT_WORK_TARGET() {
	if [ $1 = "WORK_LIST" ]
	then
		export ANSIBLE_INVENTORY_FILE=${ANSIBLE_INVENTORY_DIR}/work.hosts

	elif [ $1 = "PROD_LIST" ]
	then
		export ANSIBLE_INVENTORY_FILE=${ANSIBLE_INVENTORY_DIR}/prod.hosts
	else
		echo
		echo "[ERROR] INPUT Only Select Group : WORK_LIST, PROD_LIST ###"
		echo
		exit 1
	fi
}

FUNCT_CI_COLLETC() {
	ansible-playbook -i ${ANSIBLE_INVENTORY_FILE} --extra-vars "excute_group=${ANSIBLE_TARGET_GROUP} vars_ansible_account=${ANSIBLE_ACCOUNT}" ${ANSIBLE_YAML_DIR}/${ANSIBLE_SCRIPT_NAME}.yml | tee ${ANSIBLE_RAW_LOG}
	egrep "CHECK_RESULT|^fatal:" ${ANSIBLE_RAW_LOG} | sed 's#\[CHECK_RESULT\]\ ##g' | sed 's#"##g' | sed 's#,##g' > ${TMP_RESULT_LOG}
}

FUNCT_CHECK_ERROR() {
	CHECK_ERROR=`grep "fatal:" ${TMP_RESULT_LOG} | wc -l`

	if [ ${CHECK_ERROR} -gt 0 ]
	then
		echo
		echo "### [ERROR] Ansible Fatal List ###"
		grep "fatal:" ${TMP_RESULT_LOG}
	fi
}

FUNCT_CREATE_SHEET_FILE_01() {
	grep "CI_SHEET_01" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_01|##g' 
}

FUNCT_CREATE_SHEET_FILE_02() {
	grep "CI_SHEET_02" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_02|##g' 
}

FUNCT_CREATE_SHEET_FILE_03() {
	grep "CI_SHEET_03" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_03|##g' 
}

FUNCT_CREATE_SHEET_FILE_04() {
	grep "CI_SHEET_04" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_04|##g' 
}

FUNCT_CREATE_SHEET_FILE_05() {
	grep "CI_SHEET_05" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_05|##g' 
}

FUNCT_CREATE_SHEET_FILE_06() {
	grep "CI_SHEET_06" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_06|##g' 
}

FUNCT_CREATE_SHEET_FILE_07() {
	grep "CI_SHEET_07" ${TMP_RESULT_LOG} | sed 's#^ *##g' | sed 's#CI_SHEET_07|##g' 
}


FUNCT_PRINT_RESULT() {
	echo
	echo "### CREATE CI SHEET 01 - ${CI_LOG_01} ###"
	echo "[HOSTNAME] [INSTALL_DATE] [VENDOR] [PLATFORM] [OS_FAMILY] [OS_VER] [KER_VER] [CPU_MODEL] [CORE_COUNT] [MEM_SIZE_GB] [DISK_SUM_GB]" | column -t
	FUNCT_CREATE_SHEET_FILE_01 | tee ${CI_LOG_01} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 02 - ${CI_LOG_02} ###"
	echo "[HOSTNAME] [PLATFORM] [MOUNT_POINT] [MOUNT_PERM] [DISK_DEVCIE] [FS_TYPE] [DISK_SIZE_GB] [DISK_TYPE] [USED_SIZE_MB] [CUMULATION_DATE] [DAILY_CUMULATION]" | column -t
	FUNCT_CREATE_SHEET_FILE_02 | tee ${CI_LOG_02} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 03 - ${CI_LOG_03} ###"
	echo "[HOSTNAME] [ACCOUNT] [UID] [GID] [GIDs] [Home DIR] [ANSIBLE_SCRIPT]" | column -t
	FUNCT_CREATE_SHEET_FILE_03 | tee ${CI_LOG_03} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 04 - ${CI_LOG_04} ###"
	echo "[HOSTNAME] [PROCESS_OWNER] [PROCESS_CMD]" | column -t
	FUNCT_CREATE_SHEET_FILE_04 | tee ${CI_LOG_04} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 05 - ${CI_LOG_05} ###"
	echo "[HOSTNAME] [PLATFORM] [ETH_NAME] [MAC_ADDR] [NW_INFO] [ETH_TYPE] [LINK_STAT]" | column -t
	FUNCT_CREATE_SHEET_FILE_05 | tee ${CI_LOG_05} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 06 - ${CI_LOG_06} ###"
	echo "[HOSTNAME] [PROTOCAL] [SOURCE] [DESTINATION] [SESSION_STAT] [PROCESS_INFO]" | column -t
	FUNCT_CREATE_SHEET_FILE_06 | tee ${CI_LOG_06} | column -t -s "|"
	echo

	echo
	echo "### CREATE CI SHEET 07 - ${CI_LOG_07} ###"
	echo "[HOSTNAME] [PLATFORM] [OS_FAMILY] [OS_VER] [ENABLE_JDK] [GCC_VER] [GLIBC_VER] [OPENSSL_VER]" | column -t
	FUNCT_CREATE_SHEET_FILE_07 | tee ${CI_LOG_07} | column -t -s "|"
	echo

}

######################
#### RUN FUNCTION ####
######################

FUNCT_WORK_TARGET $1
echo
echo "### Run CI Collect Script ###"

FUNCT_CI_COLLETC 
FUNCT_PRINT_RESULT
FUNCT_CHECK_ERROR
