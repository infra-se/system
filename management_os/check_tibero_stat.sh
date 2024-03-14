#!/bin/bash
#Script by 2024.03.13 helperchoi@gmail.com
SCRIPT_VER=0.1.20240314

export LANG=C
export LC_ALL=C

FUNCT_CHECK_DB() {
	echo -n "Tibero DB Status Check"
	tbsql SYS/tibero << EOF
	SELECT 1 FROM dual;
EOF
}

FUNCT_CHECK_DB | grep "Connected to Tibero" > /dev/null

if [ $? -ne 0 ]; then
	echo
	echo "Status Code 1 [ Fail ]"
	echo
	exit 1
else
	echo
	echo "Status Code 0 [ OK ]"
	echo
	exit 0
fi
