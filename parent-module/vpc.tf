# calling from child-module #


module "parent-module" {
  source = "../child-module"

  project_name                = var.project_name
  instance_tenancy            = var.instance_tenancy
  region                      = var.region
  vpc_cidr_block              = var.vpc_cidr_block
  pubsub_cidrs                = var.pubsub_cidrs
  ptesub_cidrs                = var.ptesub_cidrs
  internet_gateway            = var.internet_gateway
  nat_gateway                 = var.nat_gateway
  nat_gateway_route_cidr      = var.nat_gateway_route_cidr
  internet_gateway_route_cidr = var.internet_gateway_route_cidr
  instance_type               = var.instance_type
  instance_class              = var.instance_class
  ami                         = var.ami
  enable_dns_hostnames        = var.enable_dns_hostnames
  enable_dns_support          = var.enable_dns_support
  engine_version              = var.engine_version
  allocated_storage           = var.allocated_storage
  engine                      = var.engine  
  storage_type                = var.storage_type 
  key_name                    = var.key_name 
  inbound_ports               = var.inbound_ports
}

