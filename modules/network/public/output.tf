output "subnets" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id, aws_subnet.public3.id]
}
