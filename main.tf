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
  elb_name = "nlb-${local.workload}"
}

module "network" {
  source   = "./modules/network"
  workload = local.workload
  region   = var.region
}

module "bucket" {
  source         = "./modules/s3"
  elb_account_id = var.elb_account_id
  elb_name       = local.elb_name
}

module "nlb" {
  source                = "./modules/nlb"
  workload              = local.workload
  vpc_id                = module.network.vpc_id
  subnets               = module.network.public_subnets
  acm_nlb_domain        = var.acm_nlb_domain
  bucket                = module.bucket.bucket
  elb_name              = local.elb_name
  enable_elb_accesslogs = var.enable_elb_accesslogs
}

module "ec2" {
  source       = "./modules/ec2"
  workload     = local.workload
  vpc_id       = module.network.vpc_id
  subnets      = module.network.public_subnets
  target_group = module.nlb.target_group_arn
}

module "jump" {
  count    = var.create_jumpserver ? 1 : 0
  source   = "./modules/jump"
  workload = local.workload
  vpc_id   = module.network.vpc_id
  subnet   = module.network.public_subnets[0]
}

module "vpces_nbl" {
  count              = var.create_vpces ? 1 : 0
  source             = "./modules/vpces"
  affix              = local.workload
  vpc_id             = module.network.vpc_id
  nlb_arn            = module.nlb.lb_arn
  subnets            = module.network.public_subnets
  vpces_private_name = var.vpces_private_name
}
