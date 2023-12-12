#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_VER=0.1.20231205

export LANG=C
export LC_ALL=C


FUNCT_CHECK_OS() {
        export OS_FAMILY=`awk '{print $1, $2}' /etc/system-release | sed 's#Linux##' | sed 's#release##' | sed 's# $##'`
        export OS_VER=`grep -o "release [0-9]\{1\}.[0-9]*" /etc/system-release | awk '{print $2}'`
        export KER_VER=`uname -r`
}

FUNCT_CHECK_OS

CHECK_OS_VER=`echo "${OS_VER}" | awk '$1 >= "7.0" {print "OK"}' | wc -l`

if [ ${CHECK_OS_VER} -eq 0 ]
then
	### xinetd BASE ###
	CHECK_SERVICE_STAT=`service iptables status | grep -i "is not running" | wc -l`
	CHECK_SERVICE_ENABLED=`chkconfig --list iptables | awk '$5 ~ /3:on/ || $7 ~ /5:on/ {print $0}' | wc -l`
	CHECK_FILTER_RULE_STAT=`iptables -nL -t filter --line-numbers | awk '$1 ~ /[0-9]/ {print $0}' | wc -l`
	CHECK_NAT_RULE_STAT=`iptables -nL -t nat --line-numbers | awk '$1 ~ /[0-9]/ {print $0}' | wc -l`
	CHECK_NF_CONNTRACK=`lsmod | grep "nf_conntrack" | wc -l`
	CHECK_NF_CONNTRACK_SIZE=`sysctl net.nf_conntrack_max | awk '{print $3}'`

	if [ ${CHECK_SERVICE_STAT} -eq 0 ]
	then
		export SERVICE_STAT="Not OK"
	else
		export SERVICE_STAT="OK"
	fi

	if [ ${CHECK_SERVICE_ENABLED} -eq 1 ]
	then
		export SERVICE_ENABLED="Not OK"
	else
		export SERVICE_ENABLED="OK"
	fi

	if [ ${CHECK_FILTER_RULE_STAT} -ge 1 ]
	then
		export FILTER_RULE_STAT="Not OK"
	else
		export FILTER_RULE_STAT="OK"
	fi

	if [ ${CHECK_NAT_RULE_STAT} -ge 1 ]
	then
		export NAT_RULE_STAT="Not OK"
	else
		export NAT_RULE_STAT="OK"
	fi

	if [ ${CHECK_NF_CONNTRACK} -gt 0 ]
	then
		export NF_CONNTRACK_STAT="Not OK"
	else
		export NF_CONNTRACK_STAT="OK"
	fi

	if [ ${CHECK_NF_CONNTRACK_SIZE} -lt 100000 ]
	then
		export NF_CONNTRACK_SIZE="Not OK"
	else
		export NF_CONNTRACK_SIZE="OK"
	fi

	echo "[CHECK_RESULT] ${HOSTNAME}|${SERVICE_STAT}|${SERVICE_ENABLED}|${FILTER_RULE_STAT}|${NAT_RULE_STAT}|${NF_CONNTRACK_STAT}|${NF_CONNTRACK_SIZE}"
else
	### systemd BASE ###
	CHECK_SERVICE_STAT=`systemctl status firewalld | grep "Active:" | awk '{print $2}' | grep "inactive" | wc -l`
	CHECK_SERVICE_ENABLED=`systemctl is-enabled firewalld | grep "enabled" | wc -l`
	CHECK_FILTER_RULE_STAT=`iptables -nL -t filter --line-numbers | awk '$1 ~ /[0-9]/ {print $0}' | wc -l`
	CHECK_NAT_RULE_STAT=`iptables -nL -t nat --line-numbers | awk '$1 ~ /[0-9]/ {print $0}' | wc -l`
	CHECK_NF_CONNTRACK=`lsmod | grep "nf_conntrack" | wc -l`
	CHECK_NF_CONNTRACK_SIZE=`sysctl net.nf_conntrack_max | awk '{print $3}'`

	if [ ${CHECK_SERVICE_STAT} -eq 0 ]
	then
		export SERVICE_STAT="Not OK"
	else
		export SERVICE_STAT="OK"
	fi

	if [ ${CHECK_SERVICE_ENABLED} -eq 1 ]
	then
		export SERVICE_ENABLED="Not OK"
	else
		export SERVICE_ENABLED="OK"
	fi

	if [ ${CHECK_FILTER_RULE_STAT} -ge 1 ]
	then
		export FILTER_RULE_STAT="Not OK"
	else
		export FILTER_RULE_STAT="OK"
	fi

	if [ ${CHECK_NAT_RULE_STAT} -ge 1 ]
	then
		export NAT_RULE_STAT="Not OK"
	else
		export NAT_RULE_STAT="OK"
	fi

	if [ ${CHECK_NF_CONNTRACK} -gt 0 ]
	then
		export NF_CONNTRACK_STAT="Not OK"
	else
		export NF_CONNTRACK_STAT="OK"
	fi

	if [ ${CHECK_NF_CONNTRACK_SIZE} -lt 100000 ]
	then
		export NF_CONNTRACK_SIZE="Not OK"
	else
		export NF_CONNTRACK_SIZE="OK"
	fi

	echo "[CHECK_RESULT] ${HOSTNAME}|${SERVICE_STAT}|${SERVICE_ENABLED}|${FILTER_RULE_STAT}|${NAT_RULE_STAT}|${NF_CONNTRACK_STAT}|${NF_CONNTRACK_SIZE}"
fi
