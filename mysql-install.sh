#/bin/bash
#
#*******************************************
#Author:        xfy
#*******************************************
DIR=$(pwd)
NAME="mysql-5.6.42-linux-glibc2.12-x86_64.tar.gz"
FULL_NAME=${DIR}/${NAME}
DATA_DIR="/data/mysql"

#显示安装开始时间、并记录安装开始时间
echo "Installation start time $(date +%T)" | tee starttime.file
#打印进度条
jindu(){
while true
do
        echo -n "*"
        sleep 0.2
done
}
jindu &
#安装
yum install vim gcc gcc-c++ wget autoconf  net-tools lrzsz iotop lsof iotop bash-completion -y &>/dev/null
yum install curl policycoreutils openssh-server openssh-clients postfix libaio-devel -y &>/dev/null

[ -f ${FULL_NAME} ] || { echo "The database source package does not exist" ; exit 1 ; }

if [ -h /usr/local/mysql ];then
    echo "Mysql has been installed"
    exit 1
else
    tar xf ${FULL_NAME}   -C /usr/local
    ln -sv /usr/local/mysql-5.6.42-linux-glibc2.12-x86_64  /usr/local/mysql &>/dev/null
fi
#判断mysql用户是否存在
id mysql &>/dev/null || useradd -r mysql &>/dev/null
chown  -R mysql.mysql  /usr/local/mysql/*
#判断/data/mysql目录是否存在，如果存在直接退出
[ -d /data/mysql ] && exit 1 || { mkdir -pv /data/mysql /var/lib/mysql &>/dev/null ; chown -R mysql.mysql /data/mysql /var/lib/mysql ; }
#初始化数据库
/usr/local/mysql/scripts/mysql_install_db  --user=mysql --datadir=/data/mysql  --basedir=/usr/local/mysql/ &>/dev/null

cp  /usr/local/mysql-5.6.42-linux-glibc2.12-x86_64/support-files/mysql.server /etc/init.d/mysqld

#赋予权限
chmod a+x /etc/init.d/mysqld

#提供配置文件
cp ${DIR}/my.cnf   /etc/my.cnf
chkconfig mysqld on &>/dev/null

#设置环境变量
cat > /etc/profile.d/mysql.sh <<EOF
PATH=/usr/local/mysql/bin:$PATH
EOF

/etc/init.d/mysqld start &>/dev/null
ln -sv /data/mysql/mysql.sock /var/lib/mysql/ &>/dev/null ; echo
echo "Installation completion time $(date +%T)" | tee stoptime.file
#终止最后一个后台运行程序
kill -9 $!
#重启bash让/etc/profile.d/mysql.sh里面的变量生效
exec bash
