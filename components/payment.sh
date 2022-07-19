source components/common.sh

CHECK_ROOT




echo "Python installation is "
yum install python36 gcc python3-devel -y
if [ $? -ne 0 ]; then
  echo -e  "\e[31mPRINT it is a FAILURE\e[0m"
else
  echo -e "\e[32mSUCCESS\e[0m"
fi

useradd roboshop
cd /home/roboshop
rm -rf payment
curl -s -L -o /tmp/payment.zip https://github.com/roboshop-devops-project/payment/archive/main.zip
unzip /tmp/payment.zip
mv payment-main payment
cd payment
pip3 install -r requirements.txt
USER_ID=$(id -u roboshop)
GROUP_ID=$(id -g roboshop)
sed -i -e "/^uid/ c uid = ${USER_ID}" -e "/^gid/ c gid = ${GROUP_ID}" /home/roboshop/payment/payment.ini
sed -i -e 's/CARTHOST/cart-1.roboshop.internal/' -e 's/USERHOST/user-1.roboshop.internal/' -e 's/AMQPHOST/rabbitmq-1.roboshop.internal/' /home/roboshop/payment/systemd.service
mv /home/roboshop/payment/systemd.service /etc/systemd/system/payment.service
systemctl daemon-reload 
systemctl enable payment
systemctl restart payment


