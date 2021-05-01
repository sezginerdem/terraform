provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.5.0.0/16"

  tags = {
    Name = "tuts vpc"
  }
}

resource "aws_subnet" "web" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.5.0.0/16"

  tags = {
    Name = "web-subnet"
  }
}

resource "aws_instance" "foobar" {
  ami           = "ami-048f6ed62451373d9"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web.id

  tags = {
    Name = "tuts example"
    foo  = "bar"
  }

}