sed -i "s/{RepPWD}/$(cat /tmp/rep_password.txt)/g" /etc/maxscale.cnf
sed -i "s/{MonPWD}/$(cat /tmp/monitor_password.txt)/g" /etc/maxscale.cnf
sed -i "s/{SvcPWD}/$(cat /tmp/service_password.txt)/g" /etc/maxscale.cnf
