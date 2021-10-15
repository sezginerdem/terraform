
# public cloud provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
#     docker = {
#       source  = "kreuzwerker/docker"
#       version = "2.15.0"
#     }
  }
}

# configure the aws provider region
provider "aws" {
  region = "eu-west-2"
}

# create a vpc
#resource "aws_vpc" "jenkins" {
#  cidr_block = "10.0.0.0/16"
#}
resource "aws_vpc" "jenkins-vpc" {
  cidr_block            = var.vpc_cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true

  tags = {
    Name = "jenkins-vpc"
  }
}


# chose operating system for jenkins instance
data "aws_ami" "ubuntu" {
  most_recent = true
 filter {
   name   = "name"
   values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }  
  owners = ["099720109477"]
}

# create instance and determine size of the server
resource "aws_instance" "jenkins" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.2xlarge"
  security_groups = [aws_security_group.jenkins.name]
  key_name        = "aws3-london"
  user_data = "${file("user-data-jenkins.sh")}"

# Install dependencies + jenkins (for ubuntu)
# provisioner "remote-exec" {
#   inline = [
#     "sudo apt-get update -y",
#     "sudo apt-get install -y curl",
#     "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
#     "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
#     "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
#     "sudo apt-get update -y",
#     "sudo apt-get install -y apt-transport-https",
#     "sudo apt-get install -y ca-certificates",
#     "sudo apt-get install -y unzip",
#     "sudo apt-get install -y wget",
#     "sudo apt-get install -y gnupg",
#     "sudo apt-get install -y lsb-release",
#     "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg",
#     "sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
#     "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable'",
#     "sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
#     "sudo apt-get update -y",
#     "sudo apt install docker.io",
#     # "sudo apt-get install -y docker-ce",
#     "sudo apt-get install -y docker-ce-cli",
#     "sudo apt-get install -y containerd.io",
#     "sudo systemctl start docker",
#     "sudo systemctl enable docker",
#     "sudo usermod -a -G docker ubuntu",
#     "sudo curl -L 'https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)' -o /usr/local/bin/docker-compose",
#     "sudo chmod +x /usr/local/bin/docker-compose",
#     "sudo curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
#     "unzip awscliv2.zip",
#     "sudo ./aws/install",
#     "sudo docker run -d -p 8080:8080 --name=jenkins jenkins/jenkins:2.315"
#   #  "sudo docker run -d -p 8080:8080 --name=jenkins jenkins/jenkins:2.315 -g 'daemon off;'",
#   # "sudo docker-compose up -d"
#   ]
# }
#    "sudo apt update -y",
#    "sudo apt install --yes wget htop default-jre build-essential make python-minimal",
#    "curl https://get.docker.com | sh",
#    "sudo usermod -aG docker ubuntu",
#
#    # Prevent jenkins to start by itself
#    "echo exit 101 | sudo tee /usr/sbin/policy-rc.d",
#
#    "sudo chmod +x /usr/sbin/policy-rc.d",
#    "wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -",
#    "echo deb https://pkg.jenkins.io/debian binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list",
#    "sudo apt update",
#    "sudo apt install --yes jenkins",
#    "sudo rsync -av --progress --update /home/ubuntu/jenkins/ /efs/jenkins",


  # Start jenkins (for ubuntu)
#  provisioner "remote-exec" {
#    inline = [
#      "sudo chown jenkins /tmp/clientid",
#      "sudo chown jenkins /tmp/clientsecret",
#      "sudo chown jenkins /tmp/userauthtoken",
#      "sudo chown jenkins /tmp/githubwebhooksecret",
#      "sudo chown jenkins /tmp/dnsimple_token",
#      "sudo cp /home/ubuntu/jenkins.default /etc/default/jenkins",
#      "sudo systemctl daemon-reload",
#      "sudo systemctl restart jenkins",
#      "echo applied default file",
#    ]
#  }

  # Install jenkins and open 8080 port (for ubuntu)
#  provisioner "remote-exec" {
#    inline = [
#      "sudo apt install wget -y",
#      "wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -",
#      "sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'",
#      "sudo apt update -qq",
#      "sudo apt install -y default-jre",
#      "sudo apt install -y jenkins",
#      "sudo systemctl start jenkins",
#      "sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080",
#      "sudo sh -c \"iptables-save > /etc/iptables.rules\"",
#      "echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections",
#      "echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections",
#      "sudo apt-get -y install iptables-persistent",
#      "sudo ufw allow 8080",
#    ]
#  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("~/aws3-london.pem")
  }

  tags = {
    "Name"      = "Jenkins_Server"
    "Terraform" = "true"
  }
}
# set open ingress ports rules 
variable "ingressrules" {
  type    = list(number)
  default = [80, 443, 22, 8080]
}

# launch security group of the instance
resource "aws_security_group" "jenkins" {
  name        = "Jenkins - Allow web traffic"
  description = "Allow ssh and standard http/https ports inbound and everything outbound"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Terraform" = "true"
  }
}

# launch iam role for the instance so that it can connect and restore backup data from s3 bucket