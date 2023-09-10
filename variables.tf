variable "region" {
  type    = string
  default = "us-east-2"
}

variable "acm_nlb_domain" {
  type    = string
  default = "aws-nlb.pomatti.io"
}

variable "vpces_private_name" {
  type    = string
  default = "aws-nlb-vpces.pomatti.io"
}

variable "elb_account_id" {
  type        = string
  default     = "033677994240"
  description = "Ohio (us-east-2) ELB account for access logs in S3"
}

variable "enable_elb_accesslogs" {
  type    = bool
  default = false
}

variable "create_jumpserver" {
  type    = bool
  default = true
}

variable "create_vpces" {
  type    = bool
  default = true
}
