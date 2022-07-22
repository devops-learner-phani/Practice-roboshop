CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo -e "\e[31mYou should run as root user or with sudo to script\e[0m"
      exit 1
  fi
}


LOG=/tmp/roboshop.log
rm -r $LOG



CHECK_STAT() {
echo "---------------" >>${LOG}
if [ $1 -ne 0 ]; then
  echo -e "\e[31mFAILED\e[0m"
  echo -e "\n check log file - ${LOG} for errors \n"
  exit 2
else
  echo -e "\e[32mSUCCESS\e[0m"
fi

}

PRINT() {
  echo "------- $1 -------" >>${LOG}
  echo $1
}


APP_COMMON_SETUP() {

  PRINT "Update application user"
    id roboshop &>>${LOG}
    if [ $? -ne 0 ]; then
      useradd roboshop &>>${LOG}
    fi
    CHECK_STAT $?


    PRINT "Download ${COMPONENT} content"
    curl -s -L -o /tmp/${COMPONENT}.zip https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip &>>${LOG} && cd /home/roboshop
    CHECK_STAT $?

    PRINT "Remove old content"
    rm -rf ${COMPONENT} &>>${LOG}
    CHECK_STAT $?

    PRINT "Extract ${COMPONENT} content"
    unzip /tmp/${COMPONENT}.zip &>>${LOG} && mv ${COMPONENT}-main ${COMPONENT} && cd ${COMPONENT}
    CHECK_STAT $?
}


SYSTEMD() {

  PRINT "Update systemd configuration"
    sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' -e 's/CARTENDPOINT/cart-1.roboshop.internal/' -e 's/DBHOST/mysql-1.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb-1.roboshop.internal/' -e 's/CARTHOST/cart-1.roboshop.internal/' -e 's/USERHOST/user-1.roboshop.internal/' -e 's/AMQPHOST/rabbitmq-1.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG}
    CHECK_STAT $?

    PRINT "Setup systemd configuration"
    mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
    CHECK_STAT $?

    PRINT "Start ${COMPONENT} services"
    systemctl restart ${COMPONENT} &>>${LOG} && systemctl enable ${COMPONENT} &>>${LOG}
    CHECK_STAT $?

}


NODEJS() {

  CHECK_ROOT

  PRINT "Install yum repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Install Nodejs"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Download ${COMPONENT} dependencies"
  npm install  &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}

NGINX() {

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

  for backend in cart catalogue user shipping payment; do
  PRINT "Update $backend configuration"
  #sed -i -e '/catalogue/ s/localhost/catalogue-1.roboshop.internal/' -e '/user/ s/localhost/user-1.roboshop.internal/' -e '/cart/ s/localhost/cart-1.roboshop.internal/' -e '/shipping/ s/localhost/shipping-1.roboshop.internal/' -e '/payment/ s/localhost/payment-1.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
  CHECK_STAT $?
  sed -i -e "/$backend/ s/localhost/$backend.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
  done

  PRINT "Restart nginx service"
  systemctl enable nginx &>>${LOG} && systemctl restart nginx &>>${LOG}
  CHECK_STAT $?
}

GOLANG() {

  CHECK_ROOT

  PRINT "Install Golang"
  yum install golang -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Download dependencies"
  go mod init dispatch &>>${LOG} && go get &>>${LOG} && go build &>>${LOG}
  CHECK_STAT $?

  SYSTEMD 
}

MAVEN() {
  
  CHECK_ROOT

  PRINT "Install maven"
  yum install maven -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Download dependencies"
  mvn clean package &>>${LOG} && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}

PYTHON() {

  CHECK_ROOT

  PRINT "Install python"
  yum install python36 gcc python3-devel -y &>>${LOG}
  CHECK_STAT $?

  APP_COMMON_SETUP

  PRINT "Download dependencies"
  pip3 install -r requirements.txt &>>${LOG}
  CHECK_STAT $?

  USER_ID=$(id -u roboshop)
  GROUP_ID=$(id -g roboshop)

  PRINT "Update ${COMPONENT} configuration"
  sed -i -e "/^uid/ c uid = ${USER_ID}" -e "/^gid/ c gid = ${GROUP_ID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>${LOG}
  CHECK_STAT $?

  SYSTEMD
}


