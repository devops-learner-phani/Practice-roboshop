curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo
yum install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld


#curl -s -L -o /tmp/mysql.zip https://github.com/roboshop-devops-project/mysql/archive/main.zip
#cd /tmp
#unzip -o mysql.zip
#cd mysql-main
#mysql -uroot -p"${MYSQL_PASSWORD}" <shipping.sql

