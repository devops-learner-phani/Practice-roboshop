USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo you are Non root user
    echo you have to run the script as a root user or run the script with sudo
   exit 1
fi





yum install nginx -y
systemctl enable nginx
systemctl start nginx
curl -s -L -o /tmp/frontend.zip https://github.com/roboshop-devops-project/frontend/archive/main.zip
cd /usr/share/nginx/html
rm -rf *
unzip /tmp/frontend.zip
mv frontend-main/static/* .
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
sed -i -e '/catalogue/ s/localhost/catalogue-1.roboshop.internal/' -e '/user/ s/localhost/user-1.roboshop.internal/' -e '/cart/ s/localhost/cart-1.roboshop.internal/' -e '/shipping/ s/localhost/shipping-1.roboshop.internal/' -e '/payment/ s/localhost/payment-1.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
systemctl restart nginx




