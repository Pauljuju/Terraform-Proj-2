
# aws vpc #

resource "aws_vpc" "website_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags = {
    Name = "website_vpc"
  }
}

# # use data source to get all avalablility zones in region #

data "aws_availability_zones" "available" {
  state = "available"
}


# aws subnets #

resource "aws_subnet" "website_pubsub" {
  count                   = 2
  vpc_id                  = aws_vpc.website_vpc.id
  cidr_block              = var.pubsub_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "website_pubsub_${count.index + 1}"
  }
}


resource "aws_subnet" "website_ptesub" {
  count = 2

  vpc_id            = aws_vpc.website_vpc.id
  cidr_block        = var.ptesub_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "website_ptesub_${count.index + 1}"
  }
}


# aws route tables #

resource "aws_route_table" "website_pubrt" {
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Names = "${var.project_name}-pubrt"
  }
}

resource "aws_route_table" "website_ptert" {
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Names = "${var.project_name}-ptert"
  }
}


# Route table association to subnets #

resource "aws_route_table_association" "website_pubrt_association" {
  count          = 2
  subnet_id      = aws_subnet.website_pubsub[count.index].id
  route_table_id = aws_route_table.website_pubrt.id
}


resource "aws_route_table_association" "website_ptert_association" {
  count          = 2
  subnet_id      = aws_subnet.website_ptesub[count.index].id
  route_table_id = aws_route_table.website_ptert.id
}

# Internet gateway attached to vpc #

resource "aws_internet_gateway" "website_IGW" {
  vpc_id = aws_vpc.website_vpc.id

  tags = {
    Name = var.internet_gateway
  }
}

# Routing IGW to public route table #

resource "aws_route" "IGW_route" {
  route_table_id         = aws_route_table.website_pubrt.id
  gateway_id             = aws_internet_gateway.website_IGW.id
  destination_cidr_block = "0.0.0.0/0"
}

# Ellastic ip #

resource "aws_eip" "eip" {
  vpc = true
}

# Provisioning vpc Nat gateway #

resource "aws_nat_gateway" "website_nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.website_pubsub[0].id

  tags = {
    Name = var.nat_gateway
  }
}

# Routing Nat Gateway to private RT # 

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.website_ptert.id
  gateway_id             = aws_nat_gateway.website_nat_gateway.id
  destination_cidr_block = var.nat_gateway_route_cidr
}


# # security group exposing port 80 and port 22 #

# # resource "aws_security_group" "sg_website" {
# #   name        = "sg_website"
# #   description = "Allow SSH, HTTP"
# #   vpc_id      = aws_vpc.website_vpc.id

# #   ingress {
# #     description = "HTTP from VPC"
# #     from_port   = 80
# #     to_port     = 80
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   ingress {
# #     description = "SSH from VPC"
# #     from_port   = 22
# #     to_port     = 22
# #     protocol    = "tcp"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   egress {
# #     from_port   = 0
# #     to_port     = 0
# #     protocol    = "-1"
# #     cidr_blocks = ["0.0.0.0/0"]
# #   }

# #   tags = {
# #     Name = "sg_website"
# #   }
# # }

locals {
  inbound_ports  = var.inbound_ports
  outbound_ports = [0]
}

resource "aws_security_group" "sg_website" {
  vpc_id      = aws_vpc.website_vpc.id
  name        = "sg_website"
  description = "Allow ssh, Http"


  dynamic "ingress" {
    for_each = var.inbound_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.outbound_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


# aws ec2 instance with public and private subnet #

resource "aws_instance" "instance_a" {
  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = data.aws_availability_zones.available.names[count.index]
  subnet_id                   = aws_subnet.website_pubsub[count.index].id
  security_groups             = ["${aws_security_group.sg_website.id}"]
  associate_public_ip_address = true
  count                       = 2

  key_name = var.key_name

  tags = {
    Name = "website_pub_server ${count.index + 1}"
  }
}


resource "aws_instance" "instance_b" {
  ami               = var.ami
  instance_type     = var.instance_type
  availability_zone = data.aws_availability_zones.available.names[count.index]
  subnet_id         = aws_subnet.website_ptesub[count.index].id
  security_groups   = ["${aws_security_group.sg_website.id}"]
  count             = 2

  key_name = var.key_name

  tags = {
    Name = "website_pte_server ${count.index + 1}"
  }
}

# create security group for the database

resource "aws_security_group" "database_sg_website" {
  name        = "database_sg_website"
  description = "enable mysql access on port 3306"
  vpc_id      = aws_vpc.website_vpc.id

  ingress {
    description     = "mysql access"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_website.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg_website"
  }
}


# creating RDS using MySQL #

resource "aws_db_instance" "websiterds" {
  engine              = var.engine
  engine_version      = var.engine_version
  allocated_storage   = var.allocated_storage
  instance_class      = var.instance_class
  storage_type        = var.storage_type
  identifier          = "websitedb"
  username            = "website"
  password            = "pw203040"
  publicly_accessible = true
  skip_final_snapshot = true

  tags = {
    Name = "websiterdsdb"
  }
}




