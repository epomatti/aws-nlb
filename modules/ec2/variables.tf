variable "workload" {
  type = string
}

variable "vpc" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "target_group" {
  type = string
}
