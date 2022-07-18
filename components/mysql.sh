curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
yum install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld
MYSQL_DEFAULT_PASSWORD=$( grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" > /tmp/mysql.log
mysql -uroot -p"${MYSQL_DEFAULT_PASSWORD}" </tmp/mysql.log



