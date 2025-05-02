#!/bin/bash

IP=$(hostname -I | awk '{print $1}')
UPTIME=$(uptime -p)
HOSTNAME=$(hostname)

cat <<EOF > /etc/issue
Ubuntu \n \l

主機名稱：$HOSTNAME
IP 位址：$IP
開機時間：$UPTIME

登入帳號：
EOF

