source components/common.sh

CHECK_ROOT

PRINT "setting up nodejs "
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Installing the nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Creating application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
fi
CHECK_STAT $?

PRINT "Downloading cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG} && cd /home/roboshop
CHECK_STAT $?

PRINT "Remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}  && mv cart-main cart && cd cart
CHECK_STAT $?


PRINT "Install nodejs dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update system congifuration"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

PRINT "Setup system configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
CHECK_STAT $?


PRINT "restart cart service"
systemctl enable cart &>>${LOG} && systemctl restart cart &>>${LOG}
CHECK_STAT $?

