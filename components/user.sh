USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "\e[31myou have to run the script as a root user or run the script with sudo\e[0m"
   exit 1
fi



curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
rm -rf user
curl -s -L -o /tmp/user.zip https://github.com/roboshop-devops-project/user/archive/main.zip
cd /home/roboshop
unzip /tmp/user.zip
mv user-main user
cd user
npm install
sed -i -e 's/MONGO_ENDPOINT/mongodb-1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' /home/roboshop/user/systemd.service
mv /home/roboshop/user/systemd.service  /etc/systemd/system/user.service
systemctl daemon-reload
systemctl enable user
systemctl restart user
