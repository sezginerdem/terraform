output "aws_instance_public_ip" {

# output "alb-dns-name" {
#  value = aws_alb.fp-alb.dns_name
  value = aws_instance.jenkins.public_ip
}