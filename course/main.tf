provider "aws" {
    version = "3.28.0"
    region = "us-east-1"
}

resource "aws_instance" "sezgin" {
    count = 2
    ami = "ami-047a51fa27710816e"
    instance_type = "t2.micro"
    tags = {
        Name = "test ${count.index}"
    }

}


output "instance" {
    value = aws_instance.sezgin[0].public_ip
}