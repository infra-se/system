#!/bin/bash
#Script made by  helperchoi@gmail.com
SCRIPT_VERSION=0.2.20231212

export LANG=C
export LC_ALL=C

LIMIT=30

declare -a ARRAY_CPU_MAX
declare -a ARRAY_CPU_AVG
declare -a ARRAY_MEM_MAX
declare -a ARRAY_MEM_AVG
declare -a ARRAY_DISK_MAX
declare -a ARRAY_DISK_AVG

MEM_TOTAL_KB=`grep "MemTotal" /proc/meminfo | awk '{print $2}'`


for (( LIST=01; LIST <= LIMIT; LIST++ ))
do
	CHECK_WC=`echo "${LIST}" | wc -m`

	if [ ${CHECK_WC} -eq 2 ]
 	then
		CPU_MAX_DAY=`sar -f /var/log/sa/sa0${LIST} -p | egrep -vi 'linux|average|00:00:0[1-2]|^$' | awk '{print 100 - $NF}' | sort -nrk1 | head -1`
		MEM_MAX_DAY=`sar -f /var/log/sa/sa0${LIST} -r | egrep -vi 'kbmemfree|linux|average|00:00:0[1-2]|^$' | awk '{print ($3 - $6) * 100 / '"${MEM_TOTAL_KB}"'}' | sort -nrk1 | head -1`
		DISK_MAX_DAY=`sar -f /var/log/sa/sa0${LIST} -d | egrep -vi 'tps|linux|average|00:00:0[1-2]|^$' | awk '{print $NF}' | sort -nrk1 | head -1`

		export ARRAY_CPU_MAX=("${ARRAY_CPU_MAX[@]}" "${CPU_MAX_DAY}")
		export ARRAY_MEM_MAX=("${ARRAY_MEM_MAX[@]}" "${MEM_MAX_DAY}")
		export ARRAY_DISK_MAX=("${ARRAY_DISK_MAX[@]}" "${DISK_MAX_DAY}")
	else
		CPU_MAX_DAY=`sar -f /var/log/sa/sa${LIST} -p | egrep -vi 'linux|average|00:00:0[1-2]|^$' | awk '{print 100 - $NF}' | sort -nrk1 | head -1`
		MEM_MAX_DAY=`sar -f /var/log/sa/sa${LIST} -r | egrep -vi 'kbmemfree|linux|average|00:00:0[1-2]|^$' | awk '{print ($3 - $6) * 100 / '"${MEM_TOTAL_KB}"'}' | sort -nrk1 | head -1`
		DISK_MAX_DAY=`sar -f /var/log/sa/sa${LIST} -d | egrep -vi 'tps|linux|average|00:00:0[1-2]|^$' | awk '{print $NF}' | sort -nrk1 | head -1`

		export ARRAY_CPU_MAX=("${ARRAY_CPU_MAX[@]}" "${CPU_MAX_DAY}")
		export ARRAY_MEM_MAX=("${ARRAY_MEM_MAX[@]}" "${MEM_MAX_DAY}")
		export ARRAY_DISK_MAX=("${ARRAY_DISK_MAX[@]}" "${DISK_MAX_DAY}")
        fi
done

for (( LIST=01; LIST <= LIMIT; LIST++ ))
do
	CHECK_WC=`echo "${LIST}" | wc -m`

	if [ ${CHECK_WC} -eq 2 ]
 	then
		CPU_AVG_DAY=`sar -f /var/log/sa/sa0${LIST} -p | grep -i 'average' | awk '{print 100 - $NF}' | sort -nrk1 | head -1`
		MEM_AVG_DAY=`sar -f /var/log/sa/sa0${LIST} -r | grep -i 'average' | awk '{print ($3 - $6) * 100 / '"${MEM_TOTAL_KB}"'}' | sort -nrk1 | head -1`
		DISK_AVG_DAY=`sar -f /var/log/sa/sa0${LIST} -d | grep -i 'average' | awk '{print $NF}' | sort -nrk1 | head -1`

		export ARRAY_CPU_AVG=("${ARRAY_CPU_AVG[@]}" "${CPU_AVG_DAY}")
		export ARRAY_MEM_AVG=("${ARRAY_MEM_AVG[@]}" "${MEM_AVG_DAY}")
		export ARRAY_DISK_AVG=("${ARRAY_DISK_AVG[@]}" "${DISK_AVG_DAY}")
	else
		CPU_AVG_DAY=`sar -f /var/log/sa/sa${LIST} -p | grep -i 'average' | awk '{print 100 - $NF}' | sort -nrk1 | head -1`
		MEM_AVG_DAY=`sar -f /var/log/sa/sa${LIST} -r | grep -i 'average' | awk '{print ($3 - $6) * 100 / '"${MEM_TOTAL_KB}"'}' | sort -nrk1 | head -1`
		DISK_AVG_DAY=`sar -f /var/log/sa/sa${LIST} -d | grep -i 'average' | awk '{print $NF}' | sort -nrk1 | head -1`

		export ARRAY_CPU_AVG=("${ARRAY_CPU_AVG[@]}" "${CPU_AVG_DAY}")
		export ARRAY_MEM_AVG=("${ARRAY_MEM_AVG[@]}" "${MEM_AVG_DAY}")
		export ARRAY_DISK_AVG=("${ARRAY_DISK_AVG[@]}" "${DISK_AVG_DAY}")
        fi
done

CPU_MAX_MONTH=`printf "%s\n" "${ARRAY_CPU_MAX[@]}" | sort -nrk 1 | head -1`
CPU_AVG_MONTH=`printf "%s\n" "${ARRAY_CPU_AVG[@]}" | sort -nrk 1 | head -1`
MEM_MAX_MONTH=`printf "%s\n" "${ARRAY_MEM_MAX[@]}" | sort -nrk 1 | head -1`
MEM_AVG_MONTH=`printf "%s\n" "${ARRAY_MEM_AVG[@]}" | sort -nrk 1 | head -1`
DISK_MAX_MONTH=`printf "%s\n" "${ARRAY_DISK_MAX[@]}" | sort -nrk 1 | head -1`
DISK_AVG_MONTH=`printf "%s\n" "${ARRAY_DISK_AVG[@]}" | sort -nrk 1 | head -1`

echo "[CHECK_RESULT] ${HOSTNAME}|${CPU_MAX_MONTH}|${CPU_AVG_MONTH}|${MEM_MAX_MONTH}|${MEM_AVG_MONTH}|${DISK_MAX_MONTH}|${DISK_AVG_MONTH}"
