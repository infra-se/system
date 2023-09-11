#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : System All User FD Count

export LANG=C
export LC_ALL=C

ALL_USER_LIST=`ps -eo user:20,pid | awk '{print $1}' | grep -v "USER" | sort -u | uniq`

for USER_NAME in ${ALL_USER_LIST} 
do
	USER_PID_LIST=`ps -o pid -u ${USER_NAME} | grep -v "PID" | sort -n`

	NUM=0

	for PID in ${USER_PID_LIST}
	do
		COUNT=`ls -l /proc/${PID}/fd/* 2> /dev/null | wc -l`

		NUM=`expr ${NUM} + ${COUNT}`
	done

	echo "USER (${USER_NAME}) Total FD : ${NUM}"
done | sort -nrk 7
