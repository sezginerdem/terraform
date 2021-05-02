provider "aws" {
  region = "us-east-1"
}

locals {
    setup_name = "tuts-foo"
    
}
#local.setup_name

resource "aws_vpc" "main" {
    cidr_block = "10.5.0.0/16"
    tags = {
        Name = "${local.setup_name}-vpc"
        foo = local.setup_name
    }
}

resource "aws_subnet" "web" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.5.0.0/16"
    tags = {
        Name = "${local.setup_name}-subnet"
    }
}

resource "aws_instance" "foobar" {
  ami = "ami-048f6ed62451373d9"
  instance_type = "t2.micro"

  tags = {
      Name = "tuts-example"
      foo = "bar"
  }
}

