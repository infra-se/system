#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Ansible Script Initialize"
SCRIPT_VER=0.5.20240125
WORK_PATH=/home/${USER}/ANSIBLE_SCRIPT

export LANG=C
export LC_ALL=C

if [ "${USER}" == "root" ]
then
	echo
	echo "[ERROR] This script must be used in a user account environment for Ansible. (Can not excute 'root')"
	echo
	exit 1
else
	echo
	echo "[INFO] Download the Ansible script to the top path under the user account."
	echo "(${WORK_PATH})"
 	echo

	echo "[INFO] Script Path Initialize : ${WORK_PATH}"
	cd ~
 	rm -rf ./ANSIBLE_SCRIPT
        git clone https://github.com/infra-se/system.git
        mv system/ANSIBLE_SCRIPT ./
        rm -rf system
        chmod -R 750 ./ANSIBLE_SCRIPT
	sed -i "s#/home/ANSIBLE_ACCOUNT#/home/${USER}#g" ${WORK_PATH}/ansible.cfg
	sed -i "s#ANSIBLE_ACCOUNT=helperchoi#ANSIBLE_ACCOUNT=${USER}#g" ${WORK_PATH}/check_ansible_env.sh
	sed -i "s#ANSIBLE_ACCOUNT=helperchoi#ANSIBLE_ACCOUNT=${USER}#g" ${WORK_PATH}/ci_collect.sh
	sed -i "s#ANSIBLE_ACCOUNT=helperchoi#ANSIBLE_ACCOUNT=${USER}#g" ${WORK_PATH}/resource_collect.sh
	sed -i "s#ANSIBLE_ACCOUNT=helperchoi#ANSIBLE_ACCOUNT=${USER}#g" ${WORK_PATH}/user_define_script.sh
 	echo
  	echo "[INFO] Ansible Script Download Path : ${WORK_PATH}"
   	rm -f rm -f ${WORK_PATH}/get_script.sh
  	echo
	find ${WORK_PATH} -type f
fi
