#!/bin/bash
#Script made by helperchoi@gmail.com
SCRIPT_DESCRIPTION="Ansible Script Initialize"
SCRIPT_VER=0.1.20231212

export LANG=C
export LC_ALL=C

if [ "${USER}" == "root" ]
then
	echo
	echo "[ERROR] This script must be used in a user account environment for Ansible. (Can not excute 'root')"
	echo
	exit 1
else
	echo
	echo "[INFO] Download the Ansible script to the top path under the user account."
	echo "(ex : /home/ANSIBLE_ACCOUNT/ANSIBLE_SCRIPT)"

	cd ~
	rm -rf .git ./ANSIBLE_SCRIPT
	git init
	git config core.sparseCheckout true
	git remote add -f origin https://github.com/infra-se/system.git
	echo "ANSIBLE_SCRIPT" > .git/info/sparse-checkout
	git pull origin main
	chmod -R 750 ./ANSIBLE_SCRIPT
 	cd ~
  	pwd
	ls -l ./ANSIBLE_SCRIPT
fi
