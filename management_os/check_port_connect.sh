#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : Check Destination Port 
SCRIPT_VER=0.4.20240411

export LANG=C
export LC_ALL=C

#######################
### VERIFY FUNCTION ###
#######################

LIST_FILE=$1

FUNCT_LIST_SYNTAX() {
	echo
	echo "[root@centos01 management_os]# vi list"
	echo "192.168.137.10 22"
	echo "192.168.137.10 25"
	echo "192.168.137.10 111"
 	echo "google.com 443"
	echo "naver.com 443"
	echo "[root@centos01 management_os]#" 
	echo
}

FUNCT_CHECK_FIELD() {
	CHECK_FIELD=$1
	FIELD_VALUE=`echo "${CHECK_FIELD}" | tr ' ' '\n' | wc -l`

	if [ ${FIELD_VALUE} -ne 2 ]
	then
		export CHECK_RESULT=1
		export ERROR_LINE="${CHECK_FIELD}"
	else
		export CHECK_RESULT=0
	fi
}

FUNCT_CHECK_SYNTAX() {

	LIST_FILE=$1
	CHECK_SYNTAX_RESULT=0
	LINE_NUM=1

	
	while read LIST
	do
		FUNCT_CHECK_FIELD "${LIST}"
		if [ ${CHECK_RESULT} -eq 1 ]		
		then
			echo "[ERROR] Syntax Error : Line Nunber ${LINE_NUM}, >>> ${ERROR_LINE} <<<"
			export CHECK_SYNTAX_RESULT=1
		fi

		LINE_NUM=`echo "${LINE_NUM} + 1" | bc`		
	done < ${LIST_FILE}

	if [ ${CHECK_SYNTAX_RESULT} -eq 1 ]
	then
		FUNCT_LIST_SYNTAX
		exit 1
	fi
}


if [ "$#" -ne 1 -o ! -e "${LIST_FILE}" ]
then
	echo
	echo "Usage example) : $0 ./list"
	FUNCT_LIST_SYNTAX
	exit 1
else
	echo
	FUNCT_CHECK_SYNTAX ${LIST_FILE}
fi

#####################
### MAIN FUNCTION ###
#####################

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
	fi
}

FUNCT_CHECK_LOGIC() {
	DST_IP=$1
	DST_PORT=$2

	nc -w 1 -zv ${DST_IP} ${DST_PORT} 2>&- > /dev/null

	if [ $? -eq 0 ]
	then
		echo "[ OK ] ${DST_IP} ${DST_PORT}" 
	else
		echo "[ FAIL ] ${DST_IP} ${DST_PORT}" 
	fi
}

FUNCT_CHECK_LIST() {
	LIST_FILE=$1
	while read LIST
	do
		FUNCT_CHECK_LOGIC ${LIST}
		sleep 1
	done < ${LIST_FILE}
	echo
}

FUNCT_CHECK_HOST() {
	BASE_IP=`hostname -I | awk '{print $1}'`
	echo "[CEHCK HOST] : ${HOSTNAME} / ${BASE_IP}"
	echo
}

FUNCT_CHECK_OS
FUNCT_CHECK_NC
FUNCT_CHECK_HOST
FUNCT_CHECK_LIST ${LIST_FILE}
