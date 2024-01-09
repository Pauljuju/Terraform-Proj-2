# variable provider #

variable "region" {}

variable "project_name" {}

variable "instance_tenancy" {}

# varibale vpc #

variable "vpc_cidr_block" {}

# variable subnets #

variable "pubsub_cidrs" {}

variable "ptesub_cidrs" {}

# variable internet gateway #

variable "internet_gateway" {}

# variable nat gateway #

variable "nat_gateway" {}

# var pte nat gateway rt cidr #

variable "nat_gateway_route_cidr" {}

variable "internet_gateway_route_cidr" {}

# var instance type #

variable "instance_type" {}

# var RDS instance class #

variable "instance_class" {}

variable "ami" {}

variable "enable_dns_hostnames" {}

variable "enable_dns_support" {}

variable "engine_version" {}

variable "engine" {}

variable "allocated_storage" {}

variable "storage_type" {}

variable "key_name" {}

variable "inbound_ports" {}
