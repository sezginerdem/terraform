/********
terraform/network.tf contains all the necessary resources to
setup the basis for our jenkins apllication on a docker-compose container
on an ec2 instance and AWS environment

Resources:
- Virtual Private Cloud
- Internet Gateway
- Route Table
- Public Subnet
- Security Groups
*********/

# availability zones in london (eu-west-2)region
data "aws_availability_zones" "azs" {}

# create a virtual private cloud
#resource "aws_vpc" "jenkins" {
#  cidr_block            = var.vpc_cidr
#  enable_dns_hostnames  = true
#  enable_dns_support    = true
#
#  tags = {
#    Name = "jenkins-vpc"
#  }
#}

# create an internet gateway (so resources can talk to the internet)
resource "aws_internet_gateway" "jenkins-igw" {
  vpc_id = aws_vpc.jenkins-vpc.id

  tags = {
    Name = "jenkins-igw"
  }
}

# create a route table for our virtual private cloud
resource "aws_route_table" "jenkins-rt-public" {
  vpc_id = aws_vpc.jenkins-vpc.id

  route {
    cidr_block = var.rt_wide_route
    gateway_id = aws_internet_gateway.jenkins-igw.id
  }

  tags = {
    Name = "jenkins-public"
  }
}

# create <count> number of public subnets in each availability zone
resource "aws_subnet" "jenkins-public-subnets" {
  count = 1
  cidr_block = var.public_cidrs[count.index]
  vpc_id = aws_vpc.jenkins-vpc.id
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    Name = "jenkins-tf-public-${count.index + 1}"
  }
}

# associate the public subnets with the public route table
resource "aws_route_table_association" "jenkins-public-rt-assc" {
  count = 1
  route_table_id = aws_route_table.jenkins-rt-public.id
  subnet_id = aws_subnet.jenkins-public-subnets.*.id[count.index]
}


# create security group
#resource "aws_security_group" "jenkins-public-sg" {
#  name = "jenkins-public-group"
#  description = "access to public instances"
#  vpc_id = aws_vpc.jenkins-vpc.id
#}


