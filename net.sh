#!/bin/bash
#centos7 网卡修改为默认方式
EDITION=$(cat /etc/redhat-release | egrep -o "[1-9]+" | head -n1)

if [ ${EDITION} == "7" ]
then
	sed -i '/LINUX/s/"$/ net.ifnames=0&/' /etc/default/grub
	grub2-mkconfig -o /etc/grub2.cfg
	sed -i -e "/DEVICE/s/ens.*/eth0/" -e "/NAME/s/ens.*/eth0/" /etc/sysconfig/network-scripts/ifcfg-ens33 

else
	true
	
fi
