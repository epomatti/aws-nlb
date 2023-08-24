variable "workload" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "acm_nlb_domain" {
  type = string
}

variable "bucket" {
  type = string
}

variable "elb_name" {
  type = string
}

variable "enable_elb_accesslogs" {
  type = bool
}
