provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "" {
  
}

resource "aws_instance" "foobar" {
  #count         = 2
  for_each = [ 
      prod = "t2.medium"
      dev = "t2.micro"
   ]


  ami           = "ami-048f6ed62451373d9" # us-east-1
  instance_type = each.value

  tags = {
    Name = "Test ${each.key}"
    #Name = "Test ${count.index}"
  }
}

output "foo" {
  value = aws_instance.web["prod"].public_ip
  #value = aws_instance.web[*].public_ip
}