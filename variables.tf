variable "region" {
  type    = string
  default = "us-east-2"
}

variable "acm_nlb_domain" {
  type    = string
  default = "aws-nlb.pomatti.io"
}

variable "create_jumpserver" {
  type    = bool
  default = false
}
