#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.3.20260226
ANSIBLE_ACCOUNT=ansadm
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

declare -a ARRAY_VERIFI_RESULT
declare -a ARRAY_RESULT

ANSIBLE_INVENTORY_DIR=/root/shell/ANSIBLE_SCRIPT/INVENTORY
ANSIBLE_YAML_DIR=/root/shell/ANSIBLE_SCRIPT/YAML
SUB_SCRIPT_NAME=user_define_script
USER_DEFINE_SCRIPT_PATH=/root/shell/ANSIBLE_SCRIPT/USER_DEFINE_SCRIPT
ANSIBLE_RAW_LOG=/tmp/user_define_script.log
LOG_DIR=/root/shell/ANSIBLE_SCRIPT/logs
LOG_DATE=`date +%Y%m%d_%H%M%S`
LOG_NAME=${LOG_DATE}_user_define_script.log
ANSIBLE_RESULT=/root/shell/ANSIBLE_SCRIPT/logs/${LOG_DATE}_user_define_script_result.log
RUN_SCRIPT=$1

if [ ! -e ${USER_DEFINE_SCRIPT_PATH}/${RUN_SCRIPT} ]
then
	echo
	echo "[ERROR] Can Not find USER Scipt : ${USER_DEFINE_SCRIPT_PATH}/${RUN_SCRIPT}"	
	echo
	exit 1
fi

if [ $# -ne 2 ]
then
        echo
        echo "### Input User Define Script & WORK_LIST ###"
        echo
	echo "[INFO] WORK_LIST : /root/shell/ANSIBLE_SCRIPT/INVENTORY/work.hosts"
	echo
        echo "Usage ) : $0 set_auditbeat.sh WORK_LIST"
	echo 
        exit 0
fi


if [ $2 = "WORK_LIST" ]
then
        export ANSIBLE_INVENTORY_FILE=${ANSIBLE_INVENTORY_DIR}/work.hosts
else
        echo
        echo "[ERROR] INPUT Only Select Group : WORK_LIST"
        echo
        exit 1
fi

FUNCT_MAIN() {
	ansible-playbook -i ${ANSIBLE_INVENTORY_FILE} --extra-vars "excute_group=${ANSIBLE_TARGET_GROUP} vars_ansible_account=${ANSIBLE_ACCOUNT} vars_run_script=${RUN_SCRIPT}" ${ANSIBLE_YAML_DIR}/${SUB_SCRIPT_NAME}.yml | tee ${ANSIBLE_RAW_LOG} 
	egrep "CHECK_RESULT|^fatal:" ${ANSIBLE_RAW_LOG} | sed 's#\[CHECK_RESULT\]\ ##g' | sed 's#"##g' | sed 's#,##g' | sed 's/^ *//g' > ${ANSIBLE_RESULT}

	echo
	echo "[INFO] User define Script Result : ${ANSIBLE_RESULT}"
	echo
}

FUNCT_MAIN | tee ${LOG_DIR}/${LOG_NAME}
