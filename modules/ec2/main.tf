resource "aws_iam_role" "main" {
  name = "ec2-role-${var.workload}"

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

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_security_group" "main" {
  name        = "ec2-ssm-${var.workload}-nat"
  description = "Controls access for EC2 via Session Manager"
  vpc_id      = var.vpc_id

  tags = {
    Name = "sg-ssm-${var.workload}-nat"
  }
}

resource "aws_security_group_rule" "allow_all_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.main.id
}


resource "aws_iam_instance_profile" "main" {
  name = "instance-profile-${var.workload}"
  role = aws_iam_role.main.id
}

resource "aws_launch_configuration" "main" {
  name_prefix   = "launchconfig-${var.workload}"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile = aws_iam_instance_profile.main.name
  security_groups      = [aws_default_security_group.default.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "default" {
  name                 = "asg-${var.workload}"
  launch_configuration = aws_launch_configuration.main.name
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnets
  target_group_arns    = var.target_group

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_instance" "box" {
#   ami           = "ami-08fdd91d87f63bb09"
#   instance_type = "t4g.nano"

#   associate_public_ip_address = true
#   subnet_id                   = var.subnet
#   vpc_security_group_ids      = [aws_security_group.main.id]

#   availability_zone    = var.az
#   iam_instance_profile = aws_iam_instance_profile.main.id
#   user_data            = file("${path.module}/userdata.sh")

#   metadata_options {
#     http_endpoint = "enabled"
#     http_tokens   = "required"
#   }

#   monitoring    = false
#   ebs_optimized = false

#   root_block_device {
#     encrypted = true
#   }

#   lifecycle {
#     ignore_changes = [
#       ami,
#       associate_public_ip_address,
#       user_data
#     ]
#   }

#   tags = {
#     Name = "${local.affix}-nat"
#   }
# }
