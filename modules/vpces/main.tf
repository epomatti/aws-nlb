resource "aws_vpc_endpoint_service" "nlb" {
  acceptance_required        = false
  network_load_balancer_arns = [var.nlb_arn]
  supported_ip_address_types = ["ipv4"]
  private_dns_name           = var.vpces_private_name

  tags = {
    Name = "nlb-vpces-${var.affix}"
  }
}

resource "aws_vpc_endpoint" "nlb" {
  vpc_id              = var.vpc_id
  service_name        = aws_vpc_endpoint_service.nlb.service_name
  vpc_endpoint_type   = aws_vpc_endpoint_service.nlb.service_type
  private_dns_enabled = true
  subnet_ids          = var.subnets
  security_group_ids  = [aws_security_group.aws_service.id]

  tags = {
    Name = "nlb-vpce-${var.affix}"
  }
}

# resource "aws_vpc_endpoint_policy" "main" {
#   vpc_endpoint_id = aws_vpc_endpoint.nlb.id

#   policy = jsonencode({
#     Statement = [
#       {
#         Action    = "*"
#         Effect    = "Allow"
#         Resource  = "*"
#         Principal = "*"
#       }
#     ]
#   })
# }

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "aws_service" {
  name        = "vpce-nlb-${var.affix}-sg"
  description = "Allow AWS Service connectivity via Interface Endpoints"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-vpce-nlb-${var.affix}"
  }
}

resource "aws_security_group_rule" "ingress_http_endpoint" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.aws_service.id
}

resource "aws_security_group_rule" "ingress_https_endpoint" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.aws_service.id
}

resource "aws_security_group_rule" "egress_http_endpoint" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_service.id
}

resource "aws_security_group_rule" "egress_https_endpoint" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.aws_service.id
}
