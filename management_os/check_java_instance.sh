#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : Java Process Listen Check

export LANG=C
export LC_ALL=C

declare -a ARRAY_LISTEN
declare -a ARRAY_NOT_LISTEN

JAVA_PID_LIST=`ps -ef | grep -v grep | grep java | awk '{print $2}'`

for LIST in ${JAVA_PID_LIST}
do
	CHECK_LISTEN=`netstat -lnp | awk '$6 ~ /LISTEN/ {print $NF}' | grep "java$" | sort -u | uniq | grep "${LIST}" | wc -l`

	if [ ${CHECK_LISTEN} -eq 1 ]
	then
		ARRAY_LISTEN=("${ARRAY_LISTEN[@]}" "`echo "JAVA PID : ${LIST} - LISTEN"`")
	else
		ARRAY_NOT_LISTEN=("${ARRAY_NOT_LISTEN[@]}" "`echo "JAVA PID : ${LIST} - Not LISTEN"`")
	fi
done	

echo
if [ ${#ARRAY_LISTEN[@]} -ne 0 ]
then
	echo "[ LISTEN ]" 
	printf "%s\n" "${ARRAY_LISTEN[@]}"
fi

echo
if [ ${#ARRAY_NOT_LISTEN[@]} -ne 0 ]
then
	echo "[ Not LISTEN ]" 
	printf "%s\n" "${ARRAY_NOT_LISTEN[@]}"
fi
