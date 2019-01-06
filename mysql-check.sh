#!/bin/bash
#zabbix 监控mysql从服务器复制状态
USER="root"
PASSWORD="centos"
HOST="127.0.0.1"
mysql -u${USER} -p${PASSWORD} -h${HOST} -e "show slave status\G;" > /tmp/mysql_state.log
mysql(){
	STATE=$1
	if [ ${STATE} == "IO" ]
	then
		state=$(cat /tmp/mysql_state.log | awk '/Slave_IO_Running/{print $2}')
		if [ ${state} == "Yes" ]
		then
			IO_STATE="0"
			echo ${IO_STATE}
		else
			IO_STATE="1"
			echo ${IO_STATE}
		fi
	fi
	if [ ${STATE} == "SQL" ]
	then
		state=$(cat /tmp/mysql_state.log | awk '/Slave_SQL_Running/{print $2}')
		if [ ${state} == "Yes" ]
		then
			SQL_STATE="0"
			echo ${SQL_STATE}
		else
			SQL_STATE="1"
			echo ${SQL_STATE}
		fi
	fi
	if [ ${STATE} == "Behind" ]
	then
		state=$(cat /tmp/mysql_state.log | awk '/Seconds_Behind_Master/{print $2}')
		if [ ${state} == "NULL" ]
		then
			echo "1"
		else
			echo ${state}
		fi
	fi
}

main () {
case $1 in
	192.168.3.172)
		mysql $2
		;;
	*)
		echo "Bad Input"
		;;
esac
}

[ $# -lt 2 ] && { echo "Input not OK" ; exit 2 ; }
main $1 $2
