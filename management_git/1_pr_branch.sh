#!/bin/bash
#Script by helperchoi@gmail.com
SCRIPT_VERSION=0.1.20220613
DESCRIPTION="github New branch Source Commit"

export LANG=C
export LC_ALL=C

declare -a ARRAY_ERROR_RESULT

LOG_DIR=/root/shell/logs
LOG_DATE=`date +%Y%m%d_%H%M%S`
LOG_NAME=${LOG_DATE}_pr_branch.log

export USER_DEFINE_LIST=$1

if [ $# -ne 1 ]
then
	echo
	echo "### 1. Create Source List File ###"
	echo "### 2. Please Input List File ###"
	echo
	echo "vi source.list"
	echo
	echo "./git_br_branch.sh"
	echo "./SYSTEM_MANAGEMENT/use_swap.sh"
	echo "./SYSTEM_CHECK/check_os.sh"
	echo
	echo "Usage ex) : $0 source.list"
	echo
	exit 1
fi

FUNCT_MAIN() {


### Git Repo Sync ###
echo
echo "[INFO] Git Repo Sync"
git pull origin main

git checkout -b pr_branch 

### VERIFY LIST FILE ###

if [ -e ${USER_DEFINE_LIST} ]
then
	### VERIFY SOURCE FILE ###
	
	VERIFI_CHECK=0
	LIST_FILE=`cat ${USER_DEFINE_LIST}`

	echo
	for LIST in ${LIST_FILE}
	do
		if [ ! -e ${LIST} ]	
		then
			ARRAY_ERROR_RESULT=("${ARRAY_ERROR_RESULT[@]}" "`echo "No such file or directory : ${LIST}"`")
			VERIFI_CHECK=1
		fi
	done
	echo

	if [ ${VERIFI_CHECK} -eq 0 ]
	then
		### Git Add Source ###
		LIST_FILE=`cat ${USER_DEFINE_LIST}`

		for LIST in ${LIST_FILE}
		do
			git add ${LIST}
		done

		### Git Commit & Push ###
		echo 
		echo "[INFO] Please Input Pull Request Commit Messages"
		read MSG
		echo

		COMMIT_MSG=$MSG

		if [ -z "${COMMIT_MSG}" ]
		then
			echo
			echo "[ERROR] Not Input Pull Request Commit Messages"
			echo
			exit 1
		else
			git commit -m "${COMMIT_MSG}"

			echo
			echo "[INFO] Git Push"
			git push -u origin pr_branch
		fi

	else
		echo 
		echo "[ERROR]"
		printf "%s\n" "${ARRAY_ERROR_RESULT[@]}"
		echo
		exit 1
	fi

else
	echo
	echo "[ERROR] No such file or directory : ${USER_DEFINE_LIST}"
	echo
	exit 1
fi
}

FUNCT_MAIN | tee ${LOG_DIR}/${LOG_NAME}
