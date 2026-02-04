module "vpc" {
  source = "./vpc"
}

/*
module "jenkins" {
  source               = "./jenkins"
  vpc_id               = module.vpc.vpc_id
  public_a_subnet_id   = module.vpc.public_a_subnet_id
  public_b_subnet_id   = module.vpc.public_b_subnet_id
}
*/

/*
module "eks" {
  source = "./eks"

  vpc_id             = module.vpc.vpc_id
  public_a_subnet_id  = module.vpc.public_a_subnet_id
  public_b_subnet_id  = module.vpc.public_b_subnet_id
  private_a_subnet_id = module.vpc.private_a_subnet_id
  private_b_subnet_id = module.vpc.private_b_subnet_id
}
*/