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


NODEJS() {
  CHECK_ROOT

  PRINT "Install yum repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  CHECK_STAT $?

  PRINT "Install Nodejs"
  yum install nodejs -y &>>${LOG}
  CHECK_STAT $?

  PRINT "Update application user"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${LOG}
  fi
  CHECK_STAT $?


  PRINT "Download cart content"
  curl -s -L -o /tmp/cart.zip https://github.com/roboshop-devops-project/cart/archive/main.zip &>>${LOG} && cd /home/roboshop
  CHECK_STAT $?

  PRINT "Remove old content"
  rm -rf cart &>>${LOG}
  CHECK_STAT $?

  PRINT "Extract cart content"
  unzip /tmp/cart.zip &>>${LOG} && mv cart-main cart && cd cart
  CHECK_STAT $?

  PRINT "Download cart dependencies"
  npm install  &>>${LOG}
  CHECK_STAT $?

  PRINT "Update systemd configuration"
  sed -i -e 's/REDIS_ENDPOINT/redis-1.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue-1.roboshop.internal/' /home/roboshop/cart/systemd.service &>>${LOG}
  CHECK_STAT $?

  PRINT "Setup systemd configuration"
  mv /home/roboshop/cart/systemd.service /etc/systemd/system/cart.service &>>${LOG} && systemctl daemon-reload &>>${LOG}
  CHECK_STAT $?

  PRINT "Start cart services"
  systemctl restart cart &>>${LOG} && systemctl enable cart &>>${LOG}
  CHECK_STAT $?
}