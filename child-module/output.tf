# vpc id #

output "vpc_id" {
  value = aws_vpc.website_vpc.id
}

# subnet ids #

output "subnet_id_1" {
  value = "aws_subnet.website_pubsub.id"
}

output "subnet_id_2" {
  value = "aws_subnet.website_ptesub.id"
}