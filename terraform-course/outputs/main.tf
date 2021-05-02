provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.5.0.0/16"
}

resource "aws_subnet" "web" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.5.0.0/16"
}

resource "aws_instance" "foobar" {
  ami = "ami-048f6ed62451373d9"
  instance_type = "t2.micro"
}

output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "foobar" {
  value = "Tuts"
}