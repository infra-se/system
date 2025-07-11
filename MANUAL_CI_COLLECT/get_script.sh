#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Get Manual CI Collect Script"
SCRIPT_VER=0.6.20250703

export LANG=C
export LC_ALL=C

FUNCT_CHECK_OS() {
	CHECK_OS=`uname -s | tr '[A-Z]' '[a-z]'`

	if [ $CHECK_OS = "linux" ];
	then
		source /etc/os-release
		case "$ID" in
			ubuntu) OS_PLATFORM="UBUNTU" ;;
			rocky) OS_PLATFORM="RHEL" ;;
			centos) OS_PLATFORM="RHEL" ;;
			rhel) OS_PLATFORM="RHEL" ;;
			amzn) OS_PLATFORM="RHEL" ;;
			*) echo "[ERROR] ${HOSTNAME} Unsupported Linux"; exit 1 ;;
		esac

		export OS_VERSION=${VERSION_ID}
	else
		echo "[ERROR] ${HOSTNAME} Can not execute. run script is only Linux OS"
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
		if [ ${OS_PLATFORM} == "RHEL" ]
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
	rm -rf ${WORK_PATH}/MANUAL_CI_COLLECT

	git clone https://github.com/infra-se/system.git

	mv system/MANUAL_CI_COLLECT ${WORK_PATH}/MANUAL_CI_COLLECT
	rm -rf system
 	chmod -R 750 ${WORK_PATH}/MANUAL_CI_COLLECT
	mkdir -p ${WORK_PATH}/MANUAL_CI_COLLECT/logs

	echo
	echo "[INFO] Script Download Path : ${WORK_PATH}/MANUAL_CI_COLLECT "
 	rm -f ${WORK_PATH}/MANUAL_CI_COLLECT/get_script.sh
	find ${WORK_PATH} -type f
	echo
else
	echo
	echo "[ERROR] This script should only be used in the root account environment. (Can not excute 'User Account')"
	echo
	exit 1
fi
