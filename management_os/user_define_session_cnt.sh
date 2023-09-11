#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : User Define Port Session Count

export LANG=C
export LC_ALL=C

if [ $# -ne 1 ]
then
	echo
	echo "### 1. Please Input : TCP Port Number ###"
	echo
	echo "Usage ex) : $0 443"
	echo
	exit 0
fi

LISTEN_PORT=$1

echo
echo "[ HOSTNAME : $HOSTNAME / Listen Port : ${LISTEN_PORT} ]"
echo

SESSION_LIST=`netstat -na | awk '$4 ~ /:'"${LISTEN_PORT}"'$/ && $6 ~ /ESTABLISHED/ {print $5}' | cut -d : -f 1 | sort -u`

for LIST in ${SESSION_LIST}
do 
	SESSION_CNT=`netstat -na | awk '$4 ~ /:'"${LISTEN_PORT}"'$/ && $6 ~ /ESTABLISHED/ {print $5}' | grep ${LIST} | wc -l`; echo "${LIST} : ${SESSION_CNT}";
done
echo
