#!/bin/bash
#Script made by  helperchoi@gmail.com
SCRIPT_DESCRIPTION="Check Ethernet Interface Info"
SCRIPT_VERSION=0.2.20220425

export LANG=C
export LC_ALL=C

LINK_UP_INTERFACE=`/usr/sbin/ip a | grep "^[0-9]" | cut -d : -f 2 | tr -d ' ' | egrep -v "lo$|docker_gwbridge|docker0|br-|virbr|cali|veth|tunl0|cilium_|lxc|dummy|nodelocal"`

for LIST in ${LINK_UP_INTERFACE}
do
	### CHECK ETHERNET TYPE ###
	CHECK_ETHERNET=`echo ${LIST} | grep "bond" | wc -l`

	if [ ${CHECK_ETHERNET} -eq 1 ]
	then
		export ETH_TYPE_NO=1
		export ETH_TYPE=MASTER
	else
		CHECK_SLAVE_ETH=`/usr/sbin/ip a show ${LIST} | grep "^[0-9]" | awk '{print $8,$9}' | grep "master" | wc -l`

		if [ ${CHECK_SLAVE_ETH} -eq 1 ]
		then
			export ETH_TYPE_NO=2
		else
			export ETH_TYPE_NO=0
			export ETH_TYPE=SINGLE
		fi
	fi

	### CHECK MAC ADDRESS ###	
	if [ ${ETH_TYPE_NO} -eq 0 -o ${ETH_TYPE_NO} -eq 1 ]
	then
		export MAC_ADDRESS=`/usr/sbin/ip a show ${LIST} | grep -w "link/ether" | awk '{print $2}'`	

	elif [ ${ETH_TYPE_NO} -eq 2 ]
	then
		BOND_NAME=`/usr/sbin/ip a show ${LIST} | grep -w "${LIST}" | awk '{print $9}'`
		export MAC_ADDRESS=`cat /proc/net/bonding/${BOND_NAME} | grep -A5 "Slave Interface: ${LIST}" | grep "Permanent HW addr" | cut -d : -f 2- | tr -d ' '`
		ETH_MASTER=`/usr/sbin/ip a show ${LIST} | awk '$2 ~ /'"${LIST}"'/ {print $9}'`
		export ETH_TYPE="SLAVE:${ETH_MASTER}"
	fi


	### CHECK IP ADDRESS ###
	CHECK_IP_ADDRESS=`/usr/sbin/ip a show ${LIST} | grep -w "inet" | awk '{print $2}' | wc -l`

	if [ ${CHECK_IP_ADDRESS} -gt 0 ]
	then
		export IP_ADDRESS=`/usr/sbin/ip a show ${LIST} | grep -w "inet" | awk '{print $2}' | head -1`
	else
		export IP_ADDRESS=N/A
	fi

	CHECK_LINK_STAT=`/usr/sbin/ip a show ${LIST} | awk '{print $9, $11}' | head -1 | sed 's#default##g' | sed 's#bond[0-9]##g'`

	echo "[CHECK_RESULT] ${HOSTNAME} ${LIST} ${MAC_ADDRESS} ${IP_ADDRESS} ${ETH_TYPE} ${CHECK_LINK_STAT}"
done
