#!/bin/bash
#判断被控主机的IP与密码对应文件是否存在
[ -e /opt/ip_pd.file ] || { echo "Error no IP password table"; exit 2; }

if [ -d /root/.ssh ]
then
        true
else
expect <<EOF
     spawn ssh-keygen
     expect {
     "id_rsa" { send "\n";exp_continue }
     "empty" { send "\n";exp_continue }
     "again" { send "\n" }
}
expect eof
EOF
fi

for i in `cat /opt/ip_pd.file`
do
    ip=$(echo $i | cut -d":" -f1)
    password=$(echo $i | cut -d":" -f2)

expect <<EOF
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@${ip} 
expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" {send "${password}\n"}
}
expect eof
EOF
done

------------------------
cat /opt/ip_pd.file
192.168.3.222:123
192.168.3.20:123
------------------------
#冒号隔开，前面被控IP，后面密码