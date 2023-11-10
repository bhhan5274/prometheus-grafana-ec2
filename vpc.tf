module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name           = "vpc-cloudn"
  cidr           = var.vpc_cidr
  azs            = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    Type = "public-subnets"
  }

  tags = {
    Owner       = "bhhan"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "vpc-cloudn"
  }
}
