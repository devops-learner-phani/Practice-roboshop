source components/common.sh

CHECK_ROOT

PRINT "Install yum repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Install Nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Update application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
fi
CHECK_STAT $?


PRINT "Download cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

PRINT "Remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

PRINT "Download cart dependencies"
npm install  &>>${LOG}
CHECK_STAT $? &>>${LOG}

PRINT "Update systemd configuration"
sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup systemd configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?


systemctl daemon-reload
systemctl enable cart

PRINT "Start cart services"
systemctl restart cart &>>${LOG}
CHECK_STAT $?


