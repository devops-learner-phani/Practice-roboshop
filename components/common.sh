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
if [ $1 -ne 0 ]; then
  echo -e "\e[31mFAILED\e[0m"
  echo -e "\n check log file - ${LOG} for errors \n"
  exit 2
else
  echo -e "\e[32mSUCCESS\e[0m"
fi

}
