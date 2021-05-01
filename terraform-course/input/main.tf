provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "foobar" {
  ami           = "ami-048f6ed62451373d9" # us-east-1
  instance_type = var.my_instance_type

  tags = var.instance_tags
}

