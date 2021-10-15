#! /bin/bash
# Setup on Ubuntu

#  Install Docker
#  Uninstall old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

#  Set up the repository
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release

#  Add Docker’s official GPG key:
 curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#  Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu

#  install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 

#  Verify
sudo docker run hello-world


# #! /bin/bash
sudo apt-get update -y
echo "The page was created by the user-data"
# sudo apt-get install -y curl
# sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'
# sudo apt-get update -y
# sudo apt-get install -y apt-transport-https
# sudo apt-get install -y ca-certificates
# sudo apt-get install -y unzip
# sudo apt-get install -y wget
# sudo apt-get install -y gnupg
# sudo apt-get install -y lsb-release
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg
# sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'
# sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# sudo apt-get update -y
# # sudo apt install docker.io
# sudo apt install docker-ce
# sudo apt-get install -y docker-ce-cli
# sudo apt-get install -y containerd.io
# sudo systemctl start docker
# sudo service docker stop
# sudo nohup docker daemon -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
# sudo usermod -aG docker $USER
# sudo systemctl start docker
# sudo systemctl enable docker
# sudo usermod -a -G docker ubuntu
# sudo curl -L 'https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose
# sudo curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
# unzip awscliv2.zip
# sudo ./aws/install
sudo docker run -d -p 8080:8080 --name=jenkins jenkins/jenkins:2.315
# # sudo docker run -d -p 8080:8080 --name=jenkins jenkins/jenkins:2.315 -g 'daemon off;'
# # sudo docker-compose up -d
# git clone bitbucket repo for docker-compose file
# docker-compose run -d
# retrieve backup data from s3 bucket
# move backup data to jenkins container's volume
# 