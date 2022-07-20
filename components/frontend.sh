source components/common.sh

CHECK_ROOT



PRINT "Install nginx "
yum install nginx -y &>>${LOG}
CHECK_STAT $?

PRINT "Start Nginx service"
systemctl start nginx &>>${LOG} && systemctl enable nginx &>>${LOG}
CHECK_STAT $?


PRINT "Download frontend content"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG}
CHECK_STAT $?

PRINT "remove old content"
cd /usr/share/nginx/html
rm -rf * &>>${LOG}
CHECK_STAT $?

PRINT "Extract frontend content"
unzip /tmp/frontend.zip &>>${LOG}
CHECK_STAT $?

PRINT "Organise frontend content"
mv frontend-main/static/* . &>>${LOG}
CHECK_STAT $?

PRINT "Setup system configuration"
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}
CHECK_STAT $?

PRINT "Update frontend configuration"
sed -i -e '/catalogue/ s/localhost/catalogue-1.roboshop.internal/' -e '/user/ s/localhost/user-1.roboshop.internal/' -e '/cart/ s/localhost/cart-1.roboshop.internal/' -e '/shipping/ s/localhost/shipping-1.roboshop.internal/' -e '/payment/ s/localhost/payment-1.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
CHECK_STAT $?

PRINT "Restart nginx service"
systemctl enable nginx &>>${LOG} && systemctl restart nginx &>>${LOG}
CHECK_STAT $?





