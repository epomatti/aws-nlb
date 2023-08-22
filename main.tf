terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  workload = "awsomeapp"
}

module "network" {
  source   = "./modules/network"
  workload = local.workload
  region   = var.region
}

module "nlb" {
  source   = "./modules/nlb"
  workload = local.workload
  vpc_id   = module.network.vpc_id
  subnets  = module.network.public_subnets
}
