#!/bin/bash
LOG_FILE=~/jenkins_install.log

# install jenkins
sudo apt update && sudo apt install -y fontconfig openjdk-17-jre

curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# install required packages as the ubuntu
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update
sudo apt install -y python3.7
sudo apt install -y python3.7-venv