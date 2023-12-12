#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.1.20231005
ANSIBLE_ACCOUNT=labic2
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=C
export LC_ALL=C

if [ $# -ne 1 ]
then
	echo
	echo "### 1. Edit Inventory File  : vi /home/${ANSIBLE_ACCOUNT}/shell/INVENTORY/work.hosts or prod.hosts ###"
	echo "### 2. Select Group Name : WORK_LIST, PROD_LIST ###"
	echo
	echo "Usage ex) : $0 WORK_LIST or PROD_LIST"
	echo
	exit 0
fi

#####################
#### COMMON VARS ####
#####################

ANSIBLE_INVENTORY_DIR=/home/${ANSIBLE_ACCOUNT}/shell/INVENTORY
ANSIBLE_SUB_SHELL_DIR=/home/${ANSIBLE_ACCOUNT}/shell/SUB_SCRIPT
ANSIBLE_YAML_DIR=/home/${ANSIBLE_ACCOUNT}/shell/YAML
ANSIBLE_SCRIPT_NAME=resource_collect

FINAL_RESULT_PATH=/tmp/ci_collect
ANSIBLE_RAW_LOG=${FINAL_RESULT_PATH}/ansible_raw.log
TMP_RESULT_LOG=${FINAL_RESULT_PATH}/resource_collect_raw.log
FINAL_RESULT_LOG=/home/${ANSIBLE_ACCOUNT}/shell/CI_RESULT/resource.log

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

FUNCT_COLLECT() {
	ansible-playbook -i ${ANSIBLE_INVENTORY_FILE} --extra-vars "excute_group=${ANSIBLE_TARGET_GROUP} vars_ansible_account=${ANSIBLE_ACCOUNT}" ${ANSIBLE_YAML_DIR}/${ANSIBLE_SCRIPT_NAME}.yml | tee ${ANSIBLE_RAW_LOG}
	egrep "CHECK_RESULT|^fatal:" ${ANSIBLE_RAW_LOG} | sed 's#\[CHECK_RESULT\]\ ##g' | sed 's#"##g' | sed 's#,##g'  | sed 's#^ *##g' > ${TMP_RESULT_LOG}
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

FUNCT_CREATE_RESOURCE_DATA() {
	sed -i "1i\[HOSTNAME]|[CPU_MAX]|[CPU_AVG]|[MEM_MAX]|[MEM_AVG]|[DISK_MAX]|[DISK_AVG]" ${TMP_RESULT_LOG}
}

FUNCT_PRINT_RESULT() {
	echo
	FUNCT_CREATE_RESOURCE_DATA 
	cat ${TMP_RESULT_LOG} | tee ${FINAL_RESULT_LOG} | column -t -s "|"
	echo

}

######################
#### RUN FUNCTION ####
######################

FUNCT_WORK_TARGET $1
echo
echo "### Run Resource Collect Script ###"

FUNCT_COLLECT
FUNCT_PRINT_RESULT
FUNCT_CHECK_ERROR
