output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnets" {
  value = module.private.subnets
}

output "public_subnets" {
  value = module.public.subnets
}
