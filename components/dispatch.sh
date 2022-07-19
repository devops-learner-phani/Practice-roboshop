USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo you are Non root user
    echo you have to run the script as a root user or run the script with sudo
   exit 1
fi


yum install golang -y
useradd roboshop
rm -rf dispatch
curl -s -L -o /tmp/dispatch.zip https://github.com/roboshop-devops-project/dispatch/archive/main.zip
cd /home/roboshop
unzip /tmp/dispatch.zip
mv dispatch-main dispatch
cd dispatch
go mod init dispatch
go get
go build
sed -i -e 's/RABBITMQ-IP/rabbitmq-1.roboshop.internal/' /home/roboshop/dispatch/systemd.service
mv /home/roboshop/dispatch/systemd.service /etc/systemd/system/dispatch.service
systemctl daemon-reload
systemctl enable dispatch
systemctl start dispatch
