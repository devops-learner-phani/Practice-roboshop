source components/common.sh

CHECK_ROOT

PRINT "setting up nodejs yum repo"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

PRINT "Installing Nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

PRINT "Adding application user"
id roboshop &>>${LOG}
if [ $? -ne 0 ]; then
  useradd roboshop &>>${LOG}
  CHECK_STAT $?
  exit 1
fi


PRINT "removing the cart content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

PRINT "Downloading the cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

PRINT "Extracting the cart.zip files"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

PRINT "Install cart dependencies"
npm install &>>${LOG}
CHECK_STAT $?

PRINT "Update systemd configuration"
sed -i -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

PRINT "moving file to cart services"
mv /home/roboshop/cart/systemd.service  /etc/systemd/system/cart.service &>>${LOG}
CHECK_STAT $?

systemctl daemon-reload &>>${LOG}
systemctl enable cart &>>${LOG}

PRINT "start cart service"
systemctl restart cart &>>${LOG}
CHECK_STAT $?
