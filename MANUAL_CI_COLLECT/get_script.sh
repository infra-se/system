#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Get Manual CI Collect Script"
SCRIPT_VER=0.1.20240125

export LANG=C
export LC_ALL=C

if [ "${USER}" == "root" ]
then
	WORK_PATH=/root/shell
	mkdir -p ${WORK_PATH}
	cd ${WORK_PATH}

	echo
	echo "[INFO] Script Path Initialize : ${WORK_PATH}"
	rm -rf ${WORK_PATH}/MANUAL_CI_COLLECT

	git clone https://github.com/infra-se/system.git

	mv system/MANUAL_CI_COLLECT ${WORK_PATH}/MANUAL_CI_COLLECT
	rm -rf system
 	chmod -R 750 ${WORK_PATH}/MANUAL_CI_COLLECT
	mkdir -p ${WORK_PATH}/MANUAL_CI_COLLECT/logs

	echo
	echo "[INFO] Script Download Path : ${WORK_PATH}/MANUAL_CI_COLLECT"
	find ${WORK_PATH} -type f
	echo
else
	echo
	echo "[ERROR] This script must be used in a root account environment for Script. (Can not excute 'User Account')"
	echo
	exit 1
fi
