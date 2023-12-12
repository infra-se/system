#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.2.20231212

export LANG=C
export LC_ALL=C

ANSIBLE_ACCOUNT=ansadm
ANSIBLE_TARGET_GROUP=TARGET_LIST
ANSIBLE_CHECK_LOG=/tmp/ansible_raw.log

ansible -i /home/${ANSIBLE_ACCOUNT}/ANSIBLE_SCRIPT/INVENTORY/verify.hosts ${ANSIBLE_TARGET_GROUP} -t ./logs/ -u ${ANSIBLE_ACCOUNT} -b -m shell -a "id" | egrep 'CHANGED|Failed' > ${ANSIBLE_CHECK_LOG}

declare -a ARRAY_CHECK_OK
declare -a ARRAY_CHECK_FAIL

while read LIST
do
	CHECK_STAT_OK=`echo "${LIST}" | grep "CHANGED" | wc -l`

	if [ ${CHECK_STAT_OK} -eq 1 ]
	then
		ARRAY_CHECK_OK=("${ARRAY_CHECK_OK[@]}" "${LIST}")
	else
		ARRAY_CHECK_FAIL=("${ARRAY_CHECK_FAIL[@]}" "${LIST}")
	fi

done < ${ANSIBLE_CHECK_LOG}

echo
echo "### Ansible Check OK - ${#ARRAY_CHECK_OK[@]} ###"
echo "### Ansible Check FAIL - ${#ARRAY_CHECK_FAIL[@]} ###"
printf "%s\n" "${ARRAY_CHECK_FAIL[@]}"
echo
