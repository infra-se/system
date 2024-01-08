#!/bin/bash
#Script by helperchoi@gmail.com

export LANG=C
export LC_ALL=C

declare -a ARRAY_OK
declare -a ARRAY_FAIL
declare -a ARRAY_NOT

[ $1 -ge 0 2>/dev/null ]

if [ $# -eq 1 -a -e "$1" ]
then
	LIST_FILE=`cat $1`

	for LIST in ${LIST_FILE}
	do
		CHECK_HTTP_CODE=`curl -I -4 -m 1 ${LIST} 2>/dev/null | grep "^HTTP" | awk '{print $2}'`
		VERIFY_CEHCK=`expr ${CHECK_HTTP_CODE} + 0 2>/dev/null`
	
		if [ ${VERIFY_CEHCK} -ge 1 ]
		then
			if [ "$CHECK_HTTP_CODE" -eq 200 -o "$CHECK_HTTP_CODE" -le 308 ]
			then
				ARRAY_OK=("${ARRAY_OK[@]}" "`echo "HTTP Code ${CHECK_HTTP_CODE} OK - ${LIST}"`")
			else
				ARRAY_FAIL=("${ARRAY_FAIL[@]}" "`echo "HTTP Code ${CHECK_HTTP_CODE} Fail - ${LIST}"`")
			fi
		else
			ARRAY_NOT=("${ARRAY_NOT[@]}" "`echo "HTTP Not Listen - ${LIST}"`")
		fi
	done
		if [ ${#ARRAY_OK[@]} -ne 0 ]
		then
			echo
			echo "========================= HTTP OK ========================="
			LOOP_COUNT=0
			LOOP_LIMIT=${#ARRAY_OK[@]}
			while [ "${LOOP_COUNT}" -lt "${LOOP_LIMIT}" ]
			do
				echo "${ARRAY_OK[${LOOP_COUNT}]}"
				LOOP_COUNT=`echo "${LOOP_COUNT} + 1" | bc`
			done
		fi

		if [ ${#ARRAY_FAIL[@]} -ne 0 ]
		then
			echo "======================== HTTP Fail ========================"
			echo "(Response Server Error Code)"
			LOOP_COUNT=0
			LOOP_LIMIT=${#ARRAY_FAIL[@]}
			while [ "${LOOP_COUNT}" -lt "${LOOP_LIMIT}" ]
			do
				echo "${ARRAY_FAIL[${LOOP_COUNT}]}"
				LOOP_COUNT=`echo "${LOOP_COUNT} + 1" | bc`
			done
		fi
	
		if [ ${#ARRAY_NOT[@]} -ne 0 ]
		then
			echo "===================== HTTP Not Listen ====================="
			echo "(Not Response or Connection Timeout)"
			LOOP_COUNT=0
			LOOP_LIMIT=${#ARRAY_NOT[@]}
			while [ "${LOOP_COUNT}" -lt "${LOOP_LIMIT}" ]
			do
				echo "${ARRAY_NOT[${LOOP_COUNT}]}"
				LOOP_COUNT=`echo "${LOOP_COUNT} + 1" | bc`
			done
		fi

		echo "==========================================================="
		echo
  
else 
	echo
	echo "Usage1 - $0 [List File]"
	echo "ex1) - $0 list"
	echo
	exit 0
fi
