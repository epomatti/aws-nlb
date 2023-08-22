variable "workload" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "domain" {
  type = string
}

variable "enable_deletion_protection" {
  type = bool
}
