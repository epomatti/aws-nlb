data "aws_subnet" "selected" {
  id = var.subnet
}

resource "aws_iam_instance_profile" "jumpserver" {
  name = "jumpserver-${var.workload}"
  role = aws_iam_role.jumpserver.id
}

resource "aws_instance" "jumpserver" {
  ami           = "ami-08fdd91d87f63bb09"
  instance_type = "t4g.nano"

  associate_public_ip_address = true
  subnet_id                   = var.subnet
  vpc_security_group_ids      = [aws_security_group.jumpserver.id]

  availability_zone    = data.aws_subnet.selected.availability_zone
  iam_instance_profile = aws_iam_instance_profile.jumpserver.id
  user_data            = file("${path.module}/userdata.sh")

  # Enables metadata V2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring    = false
  ebs_optimized = false

  lifecycle {
    ignore_changes = [
      ami,
      associate_public_ip_address
    ]
  }

  tags = {
    Name = "jumpserver-${var.workload}"
  }
}

### IAM Role ###

resource "aws_iam_role" "jumpserver" {
  name = "jumpserver-${var.workload}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-managed-instance-core" {
  role       = aws_iam_role.jumpserver.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_security_group" "jumpserver" {
  name        = "ec2-ssm-${var.workload}-jumpserver"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ec2-ssm-${var.workload}-jumpserver"
  }
}

resource "aws_security_group_rule" "egress_internet" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = []
  security_group_id = aws_security_group.jumpserver.id
}
