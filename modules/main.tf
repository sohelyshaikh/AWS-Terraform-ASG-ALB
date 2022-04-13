provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source          = "./network"
  vpc_cidr        = var.vpc
  public_cidrs    = var.cidrpub
  private_cidrs   = var.cidr
}

module "alb" {
  source = "./alb"
  vpc_id = ${module.vpc.vpc_id}
  subnet1 = ${module.vpc.private_subnet1}
  subnet2 = ${module.vpc.private_subnet2}
  subnet3 = ${module.vpc.private_subnet3}
}

module "asg" {
  source           = "./asg"
  vpc_id           = ${module.vpc.vpc_id}
  subnet1          = ${module.vpc.private_subnet1}
  subnet2          = ${module.vpc.private_subnet2}
  subnet3          = ${module.vpc.private_subnet3}
  instance_type    = var.instancetype
  target_group_arn = ${module.alb.alb_target_group_arn}
}
