#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Get System Managed Script"
SCRIPT_VER=0.1.20231215

export LANG=C
export LC_ALL=C

if [ "${USER}" == "root" ]
then
	WORK_PATH=/root/shell
	mkdir -p ${WORK_PATH}
	cd ${WORK_PATH}

	echo
	echo "[INFO] Script Path Initialize : ${WORK_PATH}"
	rm -rf ${WORK_PATH}/management_os
	rm -rf ${WORK_PATH}/management_git

	git clone https://github.com/infra-se/system.git

	mv system/management_os /root/shell/management_os
	mv system/management_git /root/shell/management_git
	rm -rf system

	echo
	echo "[INFO] Script Download Path : ${WORK_PATH}"
	find ${WORK_PATH} -type f
	echo
else
	echo
	echo "[ERROR] This script must be used in a root account environment for Script. (Can not excute 'User Account')"
	echo
	exit 1
fi
