#!/bin/bash

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
    port=$(echo $i | cut -d":" -f3)

expect << EOF
spawn ssh-copy-id -i /root/.ssh/id_rsa.pub -p ${port} root@${ip}
expect {
	"yes/no" { send "yes\n";exp_continue }
	"password" {send "${password}\n"}
}
expect eof
EOF
done
--------------------------->
cat /opt/ip_pd.file
192.168.3.222:123:22
192.168.3.20:123:6081
-------------------------
#冒号隔开，IP、密码、端口