#!/bin/bash

DIR=$(pwd)
ZABBIX="zabbix-3.0.24.tar.gz"
yum -y install java-1.8.0-openjdk-devel mariadb-devel libxml2-devel pcre pcre-devle gcc gcc-c++ net-snmp-devel libevent-devel libcurl-devel \
httpd php php-mysql  php-gettext php-session php-ctype php-xmlreader php-xmlwriter php-xml php-net-socket php-gd php-mysql php-bcmath  php-mbstring 

cat >> /etc/profile.d/java.sh <<EOF
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-2.b14.el7.x86_64
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH
EOF


tar xf ${DIR}/${ZABBIX} -C /opt
cd /opt/zabbix-3.0.24 ; ./configure --prefix=/usr/local/zabbix --enable-server --enable-agent --with-mysql  --with-net-snmp --with-libcurl --with-libxml2 --enable-java 
make -j && make install 

cp -r ${DIR}/zabbix-3.0.24/frontends/php/*  /var/www/html/
cp /opt/zabbix-3.4.11/misc/init.d/fedora/core/* /etc/init.d/

sed -i.bak -r 's#(BASEDIR=/usr/local)#&/zabbix#g' /etc/init.d/zabbix_server
sed -i.bak -r 's#(BASEDIR=/usr/local)#&/zabbix#g' /etc/init.d/zabbix_agentd
sed -i.bak '/#ServerName/cServername www.xfy.com:80' /etc/httpd/conf/httpd.conf
sed -i.bak '/post_max_size/c post_max_size = 16M' /etc/php.ini
sed -i '/max_execution_tim/cmax_execution_time = 300' /etc/php.ini
sed -i '/^max_input_time/cmax_input_time = 300' /etc/php.ini
sed -i '/^;date.timezone/cdate.timezone = Asia/Shanghai' /etc/php.ini
useradd -r zabbix

systemctl start httpd
exec bash
