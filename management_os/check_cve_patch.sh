#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Search CVE Patch Code"
SCRIPT_VER=0.3.20250425

export LANG=C
export LC_ALL=C

VAR_CVE_CODE=$1
PATTERN=$(echo "${VAR_CVE_CODE}" | sed 's/ /|/g')
CVE_COUNT=$(echo "${VAR_CVE_CODE}" | wc -w)

FUNCT_CHECK_OS() {
	CHECK_OS=`uname -s | tr '[A-Z]' '[a-z]'`

	if [ $CHECK_OS = "linux" ];
	then
		source /etc/os-release
		case "$ID" in
			ubuntu) OS_PLATFORM="UBUNTU" ;;
			rocky) OS_PLATFORM="RHEL" ;;
			centos) OS_PLATFORM="RHEL" ;;
			*) echo "[ERROR] ${HOSTNAME} Unsupported Linux"; exit 1 ;;
		esac

		export OS_VERSION=${VERSION_ID}
	else
		echo "[ERROR] ${HOSTNAME} Can not execute. run script is only Linux OS"
		exit 1
	fi
}

FUNCT_CHECK_CVE_PATTERN() {
	VAR_CVE_CODE=$1

	CHECK_PATTERN_RESULT=0

	for LIST in ${VAR_CVE_CODE}
	do
		CHECK_PATTERN=`echo "${LIST}" | grep -o "^CVE-[0-9]\{4\}-[0-9]\{4,5\}$" | wc -l`

		if [ ${CHECK_PATTERN} -ne 1 ]
		then
			echo "[ERROR] ${HOSTNAME} The input type did not meet the CVE code pattern. : ${LIST}"
			CHECK_PATTERN_RESULT=1
		fi
	done
}

FUNCT_SHOW_PROGRESS() {
	PROGRESS_BAR="/-\|"
	while true;
	do
		for (( i=0; i<${#PROGRESS_BAR}; i++ ));
		do
			echo -ne "\r[${PROGRESS_BAR:$i:1}] Please wait. Progress ..." 
			sleep 0.1
		done
	done
}

FUNCT_SEARCH_CVE() {
	if [ ${OS_PLATFORM} == "RHEL" ]
	then
		PKG_LIST=`rpm -qa`	

	elif [ ${OS_PLATFORM} == "UBUNTU" ]
	then
		PKG_LIST=`find /usr/share/doc/ -type f -name \*.gz`
	fi

	for LIST in ${PKG_LIST}
	do
		if [ ${OS_PLATFORM} == "RHEL" ]
		then
			rpm -qi ${LIST} --changelog | grep -o "CVE-[0-9]\{4\}-[0-9]\{4,5\}"
		elif [ ${OS_PLATFORM} == "UBUNTU" ]
		then
			zgrep -i "cve-" ${LIST} | grep -o "CVE-[0-9]\{4\}-[0-9]\{4,5\}"
		fi
	done

}

FUNCT_MANDATORY() {
	if [ "${USER}" != "root" ]
	then
		echo
		echo "[ERROR] ${HOSTNAME} This script must be used in a Only 'root' Account."
		echo
		exit 1
	else
		if [ -z "${VAR_CVE_CODE}" ]
		then
			echo
			echo "[ERROR] ${HOSTNAME} CVE Code was not Input."
			echo
			echo "Usage ) : $0 \"CVE-2024-53150 CVE-2024-53197\""
			echo
			exit 1
		else
			FUNCT_CHECK_CVE_PATTERN "${VAR_CVE_CODE}"

			if [ ${CHECK_PATTERN_RESULT} -ne 0 ]
			then
				echo "[INFO] ${HOSTNAME} The input type can only be the CVE Code Pattern. : ex) CVE-2024-53150 CVE-2024-53197"
				echo
				exit 1
			else
				FUNCT_CHECK_OS
			fi
		fi
	fi

}

FUNCT_MANDATORY
FUNCT_SHOW_PROGRESS &
PROGRESS_PID=$!

CHECK_CVE=`FUNCT_SEARCH_CVE | egrep "${PATTERN}" | sort -u | wc -l` 

kill ${PROGRESS_PID}
wait ${PROGRESS_PID} 2>/dev/null
echo 

if [ "${CHECK_CVE}" -lt "${CVE_COUNT}" ]
then
	echo "${HOSTNAME} | [ WARN ] Not Patched. (${VAR_CVE_CODE})"
else
	echo "${HOSTNAME} | [ OK ] Patched. (${VAR_CVE_CODE})"
fi
