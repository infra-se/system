#!/bin/bash
#Script by helperchoi@gmail.com

export LANG=C
export LC_ALL=C

TARGET_PROCESS="altibase oracle mysqld postgres"

for LIST in ${TARGET_PROCESS}
do
	MAINTENANCE_PID_LIST=`ps -eL | awk '$5 ~ /'"${LIST}"'/ {print $2}' | sort -u | uniq`
	CHECK_TARGET=`ps -eL | awk '$5 ~ /'"${LIST}"'/ {print $2}' | sort -u | uniq | wc -l`

	if [ ${CHECK_TARGET} -gt 0 ]
	then
		for PID_LIST in ${MAINTENANCE_PID_LIST}
		do
			### OOM Score Except ###
	
			CHECK_OOM_SCORE=`cat /proc/${PID_LIST}/oom_score_adj`
		
			if [ ${CHECK_OOM_SCORE} != "-1000" ]
			then
				echo "[INFO] ${HOSTNAME} Change OOM Score PID : ${LIST} / ${PID_LIST}"
				echo '-1000' > /proc/${PID_LIST}/oom_score_adj
			else
				echo "[INFO] ${HOSTNAME} ${LIST} / ${PID_LIST} OOM Score OK."
			fi
		done
	else
		echo "[INFO] ${HOSTNAME} Target does not exist. : ${LIST}"
	fi
done
