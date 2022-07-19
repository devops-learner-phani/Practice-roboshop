CHECK_ROOT() {
  USED_ID=$(id -u)
  if [ USER_ID -ne 0 ]; then
    echo -e "\e[33m you can run the script as root user or with sudo\e[0m"
    exit 1
  fi
}