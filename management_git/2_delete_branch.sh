#!/bin/bash
#Script by helperchoi@gmail.com
DESCRIPTION="github PR branch Delete."

export LANG=C
export LC_ALL=C

LOG_DIR=/root/shell/logs
LOG_DATE=`date +%Y%m%d_%H%M%S`
LOG_NAME=${LOG_DATE}_delete_branch.log

FUNCT_MAIN() {
### Git Repo Sync ###
echo
echo "[WARNING] Be sure to go through the [ Create pull request ] and [ Merge pull request ] steps before executing."
echo "[QUESTION] Do you want Execute ? : y or n"
read ANSWER
echo

if [ "${ANSWER}" == "y" ]
then
	echo "[INFO] Github PR Branch Delete : pr_branch"
	git pull origin main
	git checkout main
	git branch -D pr_branch
	git push --delete origin pr_branch
	git pull origin main
else
	echo "[INFO] Github PR Branch Not Delete : pr_branch"
fi
}

FUNCT_MAIN | tee ${LOG_DIR}/${LOG_NAME}
