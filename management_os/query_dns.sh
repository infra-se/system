#!/bin/bash
#Script by helperchoi@gmail.com
#Script Description : Query DNS
SCRIPT_VER=0.2.20240919

export LANG=C
export LC_ALL=C

DOMAIN_LIST="kt.com kakao.com blog.helperchoi.com"

FUNCT_CHECK_DNS() {

	D_LIST=$1

	if [ "${D_LIST}" == "168.126.63.1" -o "${D_LIST}" == "168.126.63.2" ]
	then
		export DNS_OWNER="KT"
	elif [ "${D_LIST}" == "210.220.163.82" -o "${D_LIST}" == "219.250.36.130" ]
	then
		export DNS_OWNER="SK Broadband"
	elif [ "${D_LIST}" == "164.124.101.2" -o "${D_LIST}" == "203.248.252.2" ]
	then
		export DNS_OWNER="LG U+"
	elif [ "${D_LIST}" == "8.8.8.8" -o "${D_LIST}" == "8.8.4.4" ]
	then
		export DNS_OWNER="Google"
	elif [ "${D_LIST}" == "ns.helperchoi.com" ]
	then
		export DNS_OWNER="Helperchoi"
	fi
}

FUNCT_LOOKUP() {

	for LIST in ${DOMAIN_LIST}
	do
		DNS_LIST="ns.helperchoi.com 168.126.63.1 168.126.63.2 210.220.163.82 219.250.36.130 164.124.101.2 203.248.252.2 8.8.8.8 8.8.4.4"

		for D_LIST in ${DNS_LIST}
		do
			FUNCT_CHECK_DNS ${D_LIST}

			echo "DNS : ${DNS_OWNER} (${D_LIST})"
			nslookup ${LIST} ${D_LIST} | grep -A1 "Name:"
			echo
		done
	done
}

FUNCT_LOOKUP 
