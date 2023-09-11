#!/bin/bash
#Script made by  helperchoi@gmail.com

export LANG=C
export LC_ALL=C

RAWDATA=/tmp/swap.list

find /proc/ -maxdepth 1 -type d -regex '^/proc/[0-9]+$' | xargs -i{} grep -Hi Swap {}/smaps 2>&1 | grep -v "No such" | grep -v "0 kB" > ${RAWDATA}
 
SWAP_TOTAL=0
for LIST in `cat ${RAWDATA} | cut -d "/" -f 3 | sort -u`
do
	MEMSUM=0
	for SWAP_LIST in `cat ${RAWDATA} | awk '$1 ~ /^\/proc\/'"${LIST}"'\// {print $2}'`
	do
		MEMSUM=`expr ${MEMSUM} + ${SWAP_LIST}`
	done
 
	PROC_USER=`ps -ef | awk '$2 ~ /^'"${LIST}"'$/ {print $1}'`
	PROC_PATH=`ls -l /proc/${LIST}/exe | awk '{print $NF}'`
 
	echo -e "PID ${LIST} / User : ${PROC_USER} / Swap use Total : ${MEMSUM} KByte / Path : ${PROC_PATH}" 
	SWAP_TOTAL=`echo "${SWAP_TOTAL} + ${MEMSUM}" | bc`
done
 
echo 
echo "Total Swap Size - ${SWAP_TOTAL} KByte"
echo "RAW Data is - ${RAWDATA}"
