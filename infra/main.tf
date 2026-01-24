module "vpc" {
  source = "./vpc"
}

/*
module "eks" {
  source          = "./eks"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
}
*/

module "jenkins" {
  source    = "../platform/jenkins"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  depends_on = [module.vpc]   # <--- NEW
}
