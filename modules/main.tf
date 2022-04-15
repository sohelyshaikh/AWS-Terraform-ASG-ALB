provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source        = "./network"
  vpc_cidr      = var.vpc
  private_cidrs = var.cidr
  public_cidrs  = var.cidrpub
}

module "alb" {
  source  = "./alb"
  vpc_id  = module.vpc.vpc_id
  subnet1 = module.vpc.private_subnet1
  subnet2 = module.vpc.private_subnet2
  subnet3 = module.vpc.private_subnet3
}

module "asg" {
  source           = "./asg"
  vpc_id           = module.vpc.vpc_id
  subnet1          = module.vpc.private_subnet1
  subnet2          = module.vpc.private_subnet2
  subnet3          = module.vpc.private_subnet3
  instance_type    = var.instancetype
  target_group_arn = module.alb.alb_target_group_arn
  maxsize          = var.max
  minsize          = var.min
}
# variable "vpc"{

# }
