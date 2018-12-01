#!/bin/bash
#数据库分库分表备份
jindu(){
while true
do
        echo -n "*"
        sleep 0.5
done
}
#用户名
MYUSER="root"
#密码
MYPASS="centos"
#SOCKET="/var/lib/mysql/mysql.sock"
#账号密码登陆
MYLOGIN="mysql -u${MYUSER} -p${MYPASS} -e"
#备份数据库
MYDBBACK="mysqldump -u${MYUSER} -p${MYPASS} -B"
#备份表
MYTBBACK="mysqldump -u${MYUSER} -p${MYPASS}"
#数据库备份的位置
DB_BACK_DIR=/data/back/DBBACK
#表备份的位置
TB_BACK_DIR=/data/back/TBBACK
#存放旧备份的位置
BACK=/data/back/OLDBACK
#定义一个时间用来匹配删除旧数据
TIME=$(date -d "1 day ago" +"%F")
#判断目录是否存在、如不存在则创建、如存在则把数据移动到旧备份目录
[ -d ${BACK} ] || mkdir -pv ${BACK} &>/dev/null
[ -d ${DB_BACK_DIR} ] && mv ${DB_BACK_DIR}/* ${BACK} || mkdir -p ${DB_BACK_DIR}
[ -d ${TB_BACK_DIR} ] && mv ${TB_BACK_DIR}/* ${BACK} || mkdir -p ${TB_BACK_DIR}

#生成数据库文本文件用来循环
${MYLOGIN} "show databases;" | egrep -v "^(Database|performance_schema|information_schema|mysql)" > /data/DB.file
echo "start -------------------------------------------------------> `date "+%F %T"`" 
#创建一个打印进度条的函数、显得不单调
jindu &
#循环备份
for DB in $(cat /data/DB.file);do
	${MYDBBACK} ${DB} | gzip > ${DB_BACK_DIR}/${DB}_$(date +%F).sql.gz 
	for DBTB in $( $MYLOGIN "use ${DB};show tables" | sed "1d")
	do
		${MYTBBACK} ${DB} ${DBTB} | gzip > ${TB_BACK_DIR}/${DBTB}_$(date +%F).sql.gz
	done
done

echo "stop -------------------------------------------------------> `date "+%F %T"`"
echo 

#扩展正则匹配日期、并删除对应数据
for i in $(ls ${BACK})
do
	if [[ "$i" =~ .*${TIME}.* ]]
	then
		rm -rf ${BACK}/${i}
	fi
done


kill -9 $!
