USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "\e[31myou have to run the script as a root user or run the script with sudo\e[0m"
   exit 1
fi


curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
rm -rf cart
curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip
cd /home/roboshop
unzip /tmp/cart.zip
mv cart-main cart
cd cart
npm install
sed -i -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' /home/roboshop/cart/systemd.service
mv /home/roboshop/cart/systemd.service  /etc/systemd/system/cart.service
systemctl daemon-reload
systemctl enable cart
systemctl restart cart
