module "frontend_vpc" {
  source = "./modules/vpc"
  name = "frontend-vpc"
  vpc_cidr = var.frontend_vpc_cidr

}

module "backend_vpc" {
  source = "./modules/vpc"
  name = "backend-vpc"
  vpc_cidr = var.backend_vpc_cidr
  
}

module "db_vpc" {
  source = "./modules/vpc"
  name = "db-vpc"
  vpc_cidr = var.db_vpc_cidr
  
}

# -------------------------------------------------------------------

resource "aws_vpc_peering_connection" "frontend_backend_peering" {
  vpc_id        = module.frontend_vpc.vpc_id
  peer_vpc_id   = module.backend_vpc.vpc_id
  peer_region   = "ap-south-1"
  tags = {
    Name = "frontend-backend-peering"
  }
}

resource "aws_vpc_peering_connection" "backend_db_peering" {
  vpc_id        = module.backend_vpc.vpc_id
  peer_vpc_id   = module.db_vpc.vpc_id
  peer_region   = "ap-south-1"
  tags = {
    Name = "backend-db-peering"
  }
}
# -------------------------------------------------------------------

module "frontend_public_subnets" {
  source = "./modules/subnets"
  vpc_id = module.frontend_vpc.vpc_id
  subnet_cidrs = [ var.frontend_pub_1_cidr, var.frontend_pub_2_cidr ]
  availability_zones = [ "ap-south-1a", "ap-south-1b" ]
  public = true
}

module "backend_public_subnets" {
  source = "./modules/subnets"
  vpc_id = module.backend_vpc.vpc_id
  subnet_cidrs = [ var.backend_pub_1_cidr ]
  availability_zones = [ "ap-south-1a"]
  public = true
}

module "backend_private_subnets" {
  source = "./modules/subnets"
  vpc_id = module.backend_vpc.vpc_id
  subnet_cidrs = [ var.backend_pvt_1_cidr ]
  availability_zones = [ "ap-south-1a"]
  public = false
}

module "db_private_subnets" {
  source = "./modules/subnets"
  vpc_id = module.db_vpc.vpc_id
  subnet_cidrs = [ var.db_pvt_1_cidr, var.db_pvt_2_cidr ]
  availability_zones = [ "ap-south-1a", "ap-south-1b"]
  public = false
}

# ------------------------------------------------------------------

resource "aws_internet_gateway" "igw_frontend" {
  vpc_id = module.frontend_vpc.vpc_id
  tags = {
    Name = "frontend-igw"
  }
}

resource "aws_internet_gateway" "igw_backend" {
  vpc_id = module.backend_vpc.vpc_id
  tags = {
    Name = "backend-igw"
  }
}

resource "aws_eip" "natgw_eip" {
  tags = {
    "Name" = "NAT-GW-EIP"
  }
}

resource "aws_nat_gateway" "natgw_backend" {
  allocation_id = aws_eip.natgw_eip.id
  subnet_id     = module.backend_public_subnets.public_subnet_ids[0]
  tags = {
    Name = "nat-gateway"
  }
  
}

# ------------------------------------------------------------------

resource "aws_route_table" "frontend" {
  vpc_id = module.frontend_vpc.vpc_id
  tags = {
    Name = "frontend-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_frontend.id
  }
  route {
    cidr_block = var.backend_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.frontend_backend_peering.id
  }
}

resource "aws_route_table" "backend" {
  vpc_id = module.backend_vpc.vpc_id
  tags = {
    Name = "backend-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw_backend.id
  }
  route {
    cidr_block = var.frontend_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.frontend_backend_peering.id
  }
  route {
    cidr_block = var.db_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.backend_db_peering.id
  }
}

resource "aws_route_table" "db" {
  vpc_id = module.db_vpc.vpc_id
  tags = {
    Name = "db-rt"
  }
  route {
    cidr_block = var.backend_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.backend_db_peering.id
  }
}

resource "aws_route_table_association" "frontend_public_rtb_assoc" {
  count          = length( module.frontend_public_subnets.public_subnet_ids )
  subnet_id      = module.frontend_public_subnets.public_subnet_ids[count.index]
  route_table_id = aws_route_table.frontend.id
}

resource "aws_route_table_association" "backend_public_rtb_assoc" {
  count          = length( module.backend_public_subnets.public_subnet_ids )
  subnet_id      = module.backend_public_subnets.public_subnet_ids[count.index]
  route_table_id = aws_route_table.backend.id
}

resource "aws_route_table_association" "backend_private_rtb_assoc" {
  count          = length( module.backend_private_subnets.private_subnet_ids )
  subnet_id      = module.backend_private_subnets.private_subnet_ids[count.index]
  route_table_id = aws_route_table.backend.id
}
resource "aws_route_table_association" "db_private_rtb_assoc" {
  count          = length( module.db_private_subnets.private_subnet_ids )
  subnet_id      = module.db_private_subnets.private_subnet_ids[count.index]
  route_table_id = aws_route_table.db.id
}

# ------------------------------------------------------------------

module "frontend_sg" {
  source = "./modules/security_groups"
  vpc_id = module.frontend_vpc.vpc_id
  name = "frontend-sg"
  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic from anywhere"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

module "backend_sg" {
  source = "./modules/security_groups"
  vpc_id = module.backend_vpc.vpc_id
  name = "backend-sg"
  ingress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "tcp"
      cidr_blocks = [ module.frontend_vpc.vpc_cidr, module.backend_vpc.vpc_cidr ]
      description = "Allow all inbound from frontend"
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

