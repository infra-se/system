#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Ansible Script Initialize"
SCRIPT_VER=0.6.20250318
WORK_PATH=/home/${USER}/ANSIBLE_SCRIPT

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
	echo
	echo "[ERROR] This script must be used in a user account environment for Ansible. (Can not excute 'root')"
	echo
	exit 1
else
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
