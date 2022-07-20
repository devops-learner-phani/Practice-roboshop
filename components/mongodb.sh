source components/common.sh

CHECK_ROOT

PRINT "Download yum repos"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG}
CHECK_STAT $?

PRINT "Install Mongodb service"
yum install mongodb-org -y &>>${LOG}
CHECK_STAT $?

PRINT "Start mongodb service"
systemctl enable mongod &>>${LOG} && systemctl start mongod &>>${LOG} && systemctl status mongod &>>${LOG}
CHECK_STAT $?

PRINT "Setup mongodb configuration"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf 
CHECK_STAT $?

PRINT "Restart mongodb service"
systemctl restart mongod &>>${LOG}
CHECK_STAT $?

PRINT "Download mongodb content"
curl -s -L -o /tmp/mongodb.zip https://github.com/roboshop-devops-project/mongodb/archive/main.zip &>>${LOG}
CHECK_STAT $?

PRINT "Extract the systemd configuration"
cd /tmp && unzip mongodb.zip &>>${LOG} && cd mongodb-main && mongo < catalogue.js &>>${LOG}  && mongo < users.js &>>${LOG}
CHECK_STAT $?


