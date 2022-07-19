CHECK_ROOT() {
  USER_ID=$(id -u)
  if [ $USER_ID -ne 0 ]; then
      echo you are Non root user
      echo you have to run the script as a root user or run the script with sudo
     exit 1
  fi
}

CHECK_ROOT


curl -L -o /etc/yum.repos.d/redis.repo https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo
yum install redis-6.2.7 -y
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf
systemctl enable redis
systemctl start redis
