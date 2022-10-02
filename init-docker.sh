#!/bin/bash

# Run: ssh docker-registry 'bash -s' < init-docker.sh

# Install Docker
sudo apt update --yes
sudo apt upgrade --yes
sudo apt install apt-transport-https ca-certificates curl software-properties-common --yes
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update --yes
sudo apt-cache policy docker-ce --yes
sudo apt install docker-ce --yes
sudo docker --version

echo " +-+-+-+-+-+-+ "
echo " |D|o|c|k|e|r| "
echo " +-+-+-+-+-+-+ "

# Install docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version


echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " |d|o|c|k|e|r|-|c|o|m|p|o|s|e| "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+-+-+ "
