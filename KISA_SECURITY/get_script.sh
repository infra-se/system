#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Get KISA Vulnerability Diagnosis Automation Script"
SCRIPT_VER=0.4.20250318

export LANG=C
export LC_ALL=C

FUNCT_CHECK_OS() {
	CHECK_OS=`uname -a | cut -d "/" -f 2 | tr '[A-Z]' '[a-z]'`

	if [ $CHECK_OS = "linux" ];
	then
		if [ `grep -i "ubuntu" /etc/*-release| wc -l` -gt 0 ]
		then
			export OS_PLATFORM="UBUNTU"
		else
			export OS_PLATFORM="ROCKY"
		fi
	else
		echo "[Error] Can not execute. run script is only Linux OS"
		exit 1
	fi
}

FUNCT_CHECK_CMD() {
        TARGET_LIST=git
	${TARGET_LIST} > /dev/null 2>&-

        if [ $? -eq 1 ]
        then
                export CHECK_RESULT=0
        else
                export CHECK_RESULT=1
        fi
}

if [ "${USER}" == "root" ]
then
	FUNCT_CHECK_OS
	FUNCT_CHECK_CMD

	if [ ${CHECK_RESULT} -eq 1 ]
 	then
		if [ ${OS_PLATFORM} == "ROCKY" ]
  		then
			yum -y install git
    		elif [ ${OS_PLATFORM} == "UBUNTU" ]
      		then
			apt-get -y install git
   		else
			echo "[ERR] Not Support OS"
   			exit 1
      		fi
  	fi

	WORK_PATH=/root/shell
	mkdir -p ${WORK_PATH}
	cd ${WORK_PATH}

	echo
	echo "[INFO] Script Path Initialize : ${WORK_PATH}/MANUAL_CI_COLLECT "
	rm -rf ${WORK_PATH}/KISA_SECURITY

	git clone https://github.com/infra-se/system.git

	mv system/KISA_SECURITY ${WORK_PATH}/KISA_SECURITY
	rm -rf system
 	chmod -R 750 ${WORK_PATH}/KISA_SECURITY
	mkdir -p ${WORK_PATH}/KISA_SECURITY/logs

	echo
	echo "[INFO] Script Download Path : ${WORK_PATH}/MANUAL_CI_COLLECT "
 	rm -f ${WORK_PATH}/KISA_SECURITY/get_script.sh
	find ${WORK_PATH}/KISA_SECURITY -type f
	echo
else
	echo
	echo "[ERROR] This script should only be used in the root account environment. (Can not excute 'User Account')"
	echo
	exit 1
fi
