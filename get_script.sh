#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Get System Managed Script"
SCRIPT_VER=0.3.20250318

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
	echo "[INFO] Script Path Initialize : ${WORK_PATH}"
	rm -rf ${WORK_PATH}/management_os
	rm -rf ${WORK_PATH}/management_git

	
	git clone https://github.com/infra-se/system.git

	mv system/management_os /root/shell/management_os
	mv system/management_git /root/shell/management_git
	rm -rf system
 	chmod -R 750 /root/shell/management_os /root/shell/management_git

	echo
	echo "[INFO] Script Download Path : ${WORK_PATH}"
 	rm -f ${WORK_PATH}/get_script.sh
	find ${WORK_PATH} -type f
	echo
else
	echo
	echo "[ERROR] This script must be used in a root account environment for Script. (Can not excute 'User Account')"
	echo
	exit 1
fi
