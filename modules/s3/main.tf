resource "aws_s3_bucket" "main" {
  bucket = "bucket-nlbaccesslogs-789"

  # For development purposes
  force_destroy = true
}

# ELB Permissions
resource "aws_s3_bucket_policy" "elb_access_logs" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.elb_access_logs.json
}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

data "aws_iam_policy_document" "elb_access_logs" {

  statement {
    sid       = "Allow ELB access logs"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.main.bucket}/${var.elb_name}/AWSLogs/${local.account_id}/*"]
    principals {
      identifiers = ["arn:aws:iam::${var.elb_account_id}:root"]
      type        = "AWS"
    }
  }
}
