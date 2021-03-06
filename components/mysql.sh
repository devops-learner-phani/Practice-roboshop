source components/common.sh

CHECK_ROOT

if [ -z "${MYSQL_PASSWORD}" ]; then
  echo "Then MYSQL_PASSWORD need to add"
else
  echo "No need to change MYSQL_PASSWORD "
fi

PRINT "Download yum repos"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install mysql"
yum install mysql-community-server -y &>>${LOG}
CHECK_STAT $?

PRINT "Start Mysql"
systemctl start mysqld &>>${LOG} && systemctl enable mysqld &>>${LOG}
CHECK_STAT $?


MYSQL_DEFAULT_PASSWORD=$( grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

echo show databases | mysql -uroot -p"${MYSQL_PASSWORD}" &>>${LOG}
if [ $? -ne 0 ]; then
  PRINT "Reset MYSQL_DEFAULT_PASSWORD"
  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';" | mysql  --connect-expired-password -uroot -p"${MYSQL_DEFAULT_PASSWORD}" &>>${LOG}
  CHECK_STAT $?
fi


echo show plugins |  mysql -uroot -p"${MYSQL_PASSWORD}" 2>>${LOG} | grep validate_pasword &>>${LOG}
if [ $? -eq 0 ]; then
  PRINT "Uninstall validate password plugin"
  echo "uninstall plugin validate_password;" | mysql -uroot -p"${MYSQL_PASSWORD}" &>>${LOG}
  CHECK_STAT $?
fi

PRINT "Download Mysql content"
curl -s -L -o /tmp/mysql.zip https://github.com/roboshop-devops-project/mysql/archive/main.zip &>>${LOG}
CHECK_STAT $?

PRINT "Extract mysql configuration"
cd /tmp && unzip -o mysql.zip &>>${LOG} && cd mysql-main && mysql -uroot -p"${MYSQL_PASSWORD}" <shipping.sql &>>${LOG}
CHECK_STAT $?





