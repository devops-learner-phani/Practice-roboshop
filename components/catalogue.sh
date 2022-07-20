
USER_ID=$(id -u)
if [ $USER_ID -ne 0]; then
  echo "You are Non root user"
  echo "You should run as root user or with sudo to script"
  exit
fi

curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
rm -rf catalogue
curl -s -L -o /tmp/catalogue.zip https://github.com/roboshop-devops-project/catalogue/archive/main.zip
cd /home/roboshop
unzip /tmp/catalogue.zip
mv catalogue-main catalogue
cd catalogue
npm install
sed -i -e 's/MONGO_DNSNAME/mongodb-1.roboshop.internal/' /home/roboshop/catalogue/systemd.service
mv /home/roboshop/catalogue/systemd.service  /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue  


