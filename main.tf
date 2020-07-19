provider "aws" {
  region = "ap-south-2"
}


/*module "ec2" {
  source         = "./ec2_dhyanio"
  public_key     = "/tmp/id_rsa.pub"
  instance_type  = "t2.micro"
  security_group = "${module.vpc.security_group}"
  subnets        = "${module.vpc.public_subnets}"
}*/

module "vpc" {
  source          = "./main_vpc_dhyanio"
  vpc_cidr        = "10.0.0.0/16"
  public_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs   = ["10.0.3.0/24", "10.0.4.0/24"]
  
}
