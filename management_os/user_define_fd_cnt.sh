#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : User define FD Count

export LANG=C
export LC_ALL=C

if [ $# -ne 1 ]
then
	echo
	echo "### 1. Please Input : System Account Name ###"
	echo
	echo "Usage ex) : $0 root"
	echo
	exit 0
fi

USER_NAME=$1

USER_PID_LIST=`ps -o pid -u ${USER_NAME} | grep -v "PID" | sort -n`

NUM=0

for PID in ${USER_PID_LIST}
do
	COUNT=`ls -l /proc/${PID}/fd/* 2> /dev/null | wc -l`

	if [ ${COUNT} -ne 0 ]
	then
		echo "PID(${PID}) FD Count : ${COUNT}"
	fi

	NUM=`expr ${NUM} + ${COUNT}`
done

echo "### USER (${USER_NAME}) Total FD : ${NUM} ###"
