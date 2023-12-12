#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.2.20231212

export LANG=C
export LC_ALL=C

FUNCT_CHECK_SESSION() {
	ANSIBLE_SESSION_LIST=`ps -ef | awk '$9 ~ /.ansible/ && $10 ~ /mux/ {print $0}'`
	ANSIBLE_PID_LIST=`echo "${ANSIBLE_SESSION_LIST}" | awk '{print $2}'`

	for LIST in ${ANSIBLE_PID_LIST}
	do
		SESSION_INFO=`sudo netstat -nap | grep "^tcp" | grep "${LIST}/ssh" | awk '{print $5}' | cut -d ":" -f1`
		START_TIME=`ps -ef | awk '$2 ~ /'"${LIST}"'/ {print $5}'`
		echo "Ansible Session : ${SESSION_INFO} / PID : ${LIST} / START_TIME : ${START_TIME}"	
	done
}

FUNCT_CHECK_SESSION
