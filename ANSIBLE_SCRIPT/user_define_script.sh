#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.2.20231212
ANSIBLE_ACCOUNT=labic2
ANSIBLE_TARGET_GROUP=TARGET_LIST

export LANG=C
export LC_ALL=C

declare -a ARRAY_VERIFI_RESULT
declare -a ARRAY_RESULT

ANSIBLE_INVENTORY_DIR=/home/${ANSIBLE_ACCOUNT}/shell/INVENTORY
ANSIBLE_YAML_DIR=/home/${ANSIBLE_ACCOUNT}/shell/YAML
SUB_SCRIPT_NAME=user_define_script
USER_DEFINE_SCRIPT_PATH=/home/${ANSIBLE_ACCOUNT}/shell/USER_DEFINE_SCRIPT
ANSIBLE_RAW_LOG=/tmp/user_define_script.log
ANSIBLE_RESULT=/home/${ANSIBLE_ACCOUNT}/shell/logs/user_define_script.log
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
        echo "### 1. Input User Define Script ###"
        echo "### 2. Select Group Name : WORK_LIST, PROD_LIST ###"
        echo
        echo "Usage ) : $0 scan_dir.sh WORK_LIST"
        echo
        exit 0
fi


if [ $2 = "WORK_LIST" ]
then
        export ANSIBLE_INVENTORY_FILE=${ANSIBLE_INVENTORY_DIR}/work.hosts

elif [ $2 = "PROD_LIST" ]
then
        export ANSIBLE_INVENTORY_FILE=${ANSIBLE_INVENTORY_DIR}/prod.hosts

else
        echo
        echo "[ERROR] INPUT Only Select Group : WORK_LIST, PROD_LIST"
        echo
        exit 1
fi


ansible-playbook -f 8 -i ${ANSIBLE_INVENTORY_FILE} --extra-vars "excute_group=${ANSIBLE_TARGET_GROUP} vars_ansible_account=${ANSIBLE_ACCOUNT} vars_run_script=${RUN_SCRIPT}" ${ANSIBLE_YAML_DIR}/${SUB_SCRIPT_NAME}.yml | tee ${ANSIBLE_RAW_LOG} 
egrep "CHECK_RESULT|^fatal:" ${ANSIBLE_RAW_LOG} | sed 's#\[CHECK_RESULT\]\ ##g' | sed 's#"##g' | sed 's#,##g' | sed 's/^ *//g' > ${ANSIBLE_RESULT}

echo
echo "[INFO] User define Script Result : ${ANSIBLE_RESULT}"
echo
