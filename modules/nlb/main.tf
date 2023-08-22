resource "aws_lb" "main" {
  name                       = "nlb-${var.workload}"
  internal                   = false
  load_balancer_type         = "network"
  security_groups            = [aws_security_group.lb.id]
  subnets                    = var.subnets
  enable_deletion_protection = false
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "aws-nlb.pomatti.io"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "tcp" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "TCP"
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "tls" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.cert.arn
  alpn_policy       = "HTTP2Preferred"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name        = "tg-lb-${var.workload}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    protocol = "TCP"
    enabled  = true
  }
}

### Security Group ###

resource "aws_security_group" "lb" {
  name        = "lb-${var.workload}"
  vpc_id      = var.vpc_id
  description = "Controls LB security"

  tags = {
    Name = "sg-lb-${var.workload}"
  }
}

resource "aws_security_group_rule" "inbound_https" {
  description       = "Allows secure internet inbound traffic"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "outbound_ecs" {
  description       = "Allows traffic to ECS"
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.lb.id
}
