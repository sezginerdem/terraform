provider "aws" {
  version = "~> 2.65"
  region  = "us-east-1"
}


resource "aws_instance" "foobar" {
  ami           = "ami-048f6ed62451373d9" # us-east-1
  instance_type = "t2.medium"

}
