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

resource "aws_launch_template" "main" {
  name          = "launchtemplate-${var.workload}"
  image_id      = "ami-08fdd91d87f63bb09"
  user_data     = filebase64("${path.module}/userdata.sh")
  instance_type = "t4g.nano"

  iam_instance_profile {
    # name = "test"
    arn = aws_iam_instance_profile.main.arn
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.main.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "NLB EC2 template"
    }
  }
}

resource "aws_autoscaling_group" "default" {
  name                = "asg-${var.workload}"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.subnets
  target_group_arns   = [var.target_group]

  // Make sure both fields "id" and "version" are set to not conflict with the launch template
  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }
}
