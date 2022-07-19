CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo you are Non root user
      echo you have to run the script as a root user or run the script with sudo
     exit 1
  fi
}
