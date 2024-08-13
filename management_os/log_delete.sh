#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : log delete script
SCRIPT_VER=0.1.20240813

export LANG=C
export LC_ALL=C

LOG_DIR_LIST="/logs/user_logs /logs/iptables"
LOG_LIMIT_DAY=30

FUNCT_LOG_DELETE() {
	LOG_DIR=$1
	find ${LOG_DIR} -type f -mtime +${LOG_LIMIT_DAY} -exec rm -f {} \;
}

for LIST in ${LOG_DIR_LIST}
do
	FUNCT_LOG_DELETE ${LIST}
done
