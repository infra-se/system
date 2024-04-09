#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : Check Destination Port 

export LANG=C
export LC_ALL=C

LIST_FILE=$1

if [ "$#" -ne 1 -o ! -e "${LIST_FILE}" ]
then
	echo
	echo "Usage example) : $0 ./list"
	echo
	echo "[root@centos01 management_os]# vi list"
	echo "192.168.137.10 22"
	echo "192.168.137.10 25"
	echo "192.168.137.10 111"
	echo "[root@centos01 management_os]#" 
	echo
	exit 0
fi

FUNCT_CHECK_OS() {

	CHECK_OS=`uname -a | cut -d "/" -f 2 | tr '[A-Z]' '[a-z]'`

	if [ $CHECK_OS = "linux" ];
	then
		if [ `grep -i "ubuntu" /etc/*-release| wc -l` -gt 0 ]
		then
			echo "[ CHECK OS ] Debian Family"
			export OS_PLATFORM="UBUNTU"
		else
			echo "[ CHECK OS ] Redhat Family"
			export OS_PLATFORM="ROCKY"
		fi
	else
		echo "[Error] Can not execute. run script is only Linux OS"
		exit 1
	fi
}

FUNCT_CHECK_NC() {
	which nc 2>&- > /dev/null
	if [ $? -ne 0 ]
	then
		if [ ${OS_PLATFORM} == "UBUNTU" ]
		then
			echo "[ CHECK NC ] Need for Install"
			apt-get -y install nc
		else
			echo "[ CHECK NC ] Need for Install"
			yum -y install nc
		fi
	else
		echo "[ CHECK NC ] OK"
	fi
}

FUNCT_CHECK_LOGIC() {
	DST_IP=$1
	DST_PORT=$2

	nc -w 1 -zv ${DST_IP} ${DST_PORT}
}

FUNCT_CHECK_LIST() {
	LIST_FILE=$1
	while read LIST
	do
		FUNCT_CHECK_LOGIC ${LIST}
		sleep 1
	done < ${LIST_FILE}
}

FUNCT_CHECK_OS
FUNCT_CHECK_NC
FUNCT_CHECK_LIST ${LIST_FILE}
