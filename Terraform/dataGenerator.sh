#!/bin/bash
touch /tmp/gothere
sudo apt update
#sudo apt upgrade -y
sudo apt install docker.io docker-compose nmon kafkacat -y
sudo usermod -a -G docker ubuntu
newgrp docker

cd ~
git clone https://github.com/JohnRTurner/TerraformTest.git
cd TerrraformTest/docker/dataGenerator
cat ~/.env >> .env
docker-compose up -d
