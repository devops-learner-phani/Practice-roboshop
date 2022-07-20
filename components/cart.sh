source components/common.sh

CHECK_ROOT


PRINT "Setting up nodejs yum repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Install Nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Update the application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  echo "Update the application user"
  useradd roboshop &>>${LOG}
  CHECK_STAT $?
fi

PRINT "remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Download cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop &>>${LOG}

PRINT "Extract cart content"
unzip -o /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main &>>${LOG}
cd /home/roboshop/cart &>>${LOG}

PRINT "Install nodejs dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update systemd configuration"
sed -i -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/'  -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/'  /home/roboshop/cart/systemd.service 
CHECK_STAT $?

PRINT "setup systemd configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?


systemctl daemon-reload &>>${LOG}
systemctl enable cart &>>${LOG}

PRINT "start cart services"
systemctl start cart &>>${LOG}
CHECK_STAT $?

