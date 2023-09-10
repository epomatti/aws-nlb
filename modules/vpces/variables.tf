variable "affix" {
  type = string
}

variable "nlb_arn" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "vpces_private_name" {
  type = string
}
