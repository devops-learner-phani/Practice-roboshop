curl -sL https://rpm.nodesource.com/setup_lts.x | bash
yum install nodejs -y
useradd roboshop
rm -rf catalogue
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip"
cd /home/roboshop
unzip -o /tmp/catalogue.zip
mv catalogue-main catalogue
cd catalogue
npm install
sed -i -e 's/MONGO_DNSNAME/mongodb-1.roboshop.internal/' /home/roboshop/catalogue/systemd.service
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
systemctl daemon-reload
systemctl start catalogue
systemctl enable catalogue
