#!/bin/bash

export LANG=C
export LC_ALL=C

for LIST in `awk -F : '{print $1}' /etc/passwd`
do
	CHECK_JOB=`crontab -u ${LIST} -l 2>&1 | grep "no crontab" | wc -l`
	if [ ${CHECK_JOB} -eq 0 ]
	then
		crontab -u ${LIST} -l | grep -v "^#" | xargs -i echo "[CHECK_RESULT] ${HOSTNAME}|${LIST}|{}" 
	fi
done
