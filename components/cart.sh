source components/common.sh

CHECK_ROOT


echo "Setting up nodejs yum repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
CHECK_STAT $?

echo "Install Nodejs"
yum install nodejs -y &>>${LOG}
CHECK_STAT $?

echo "Update the application user"
useradd roboshop &>>${LOG}
CHECK_STAT $?

echo "remove old content"
rm -rf cart &>>${LOG}
CHECK_STAT $?

echo "Download cart content"
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG}
CHECK_STAT $?

cd /home/roboshop

echo "Extract cart content"
unzip /tmp/cart.zip &>>${LOG}
CHECK_STAT $?

mv cart-main cart
cd cart

echo "Install nodejs dependencies"
npm install &>>${LOG}
CHECK_STAT $?

echo "Update systemd file configuration"
sed -i -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
CHECK_STAT $?

echo "setup systemd configuration"
mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart. &>>${LOG}
CHECK_STAT $?


systemctl daemon-reload
systemctl enable cart

echo "start cart services"
systemctl start cart &>>${LOG}
CHECK_STAT $?

