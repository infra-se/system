#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.2.20231120

export LANG=C
export LC_ALL=C

SERVICE_LIST=`systemctl --type service --state=active | awk '$3 ~ /active/ {print $1}'`

for LIST in ${SERVICE_LIST}
do
	echo "[CHECK_RESULT] ${HOSTNAME}|${LIST}"
done
