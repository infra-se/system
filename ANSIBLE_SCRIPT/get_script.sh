#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Ansible Script Initialize"
SCRIPT_VER=0.2.20231218
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
 	echo
  	echo "[INFO] Ansible Script Download Path : ${WORK_PATH}"
  	echo
	find ${WORK_PATH} -type f
fi
