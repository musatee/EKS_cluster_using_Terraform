
locals {
  Name       = "webapp"
  Created_By = "terraform"
}
locals {
  common_tags = {
    Name        = local.Name
    Created_By  = local.Created_By
    Environment = terraform.workspace
  }
}
// create vpc
resource "aws_vpc" "webapp_vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.common_tags
}

//create three public subnets
resource "aws_subnet" "webapp_sub" {
  for_each                = var.subnets
  vpc_id                  = aws_vpc.webapp_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.webapp_vpc.cidr_block, each.value["newbit"], each.value["netnum"])
  availability_zone       = each.value["az"]
  map_public_ip_on_launch = true

  tags = {
    Name                     = each.key
    "kubernetes.io/role/elb" = 1
    Created_By               = local.common_tags["Created_By"]
    Environment              = local.common_tags["Environment"]
  }
}

// create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webapp_vpc.id

  tags = {
    Name        = "webapp-IGW"
    Created_By  = local.common_tags["Created_By"]
    Environment = local.common_tags["Environment"]
  }
}


// create public RT
resource "aws_route_table" "webapp_publicRT" {
  vpc_id = aws_vpc.webapp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "webapp_publicRT"
    Created_By  = local.common_tags["Created_By"]
    Environment = local.common_tags["Environment"]
  }
}

// associate public subnets to RT 
resource "aws_route_table_association" "RT_assoc1" {
  subnet_id      = aws_subnet.webapp_sub["public_sub1"].id
  route_table_id = aws_route_table.webapp_publicRT.id
}

resource "aws_route_table_association" "RT_assoc2" {
  subnet_id      = aws_subnet.webapp_sub["public_sub2"].id
  route_table_id = aws_route_table.webapp_publicRT.id
}

resource "aws_route_table_association" "RT_assoc3" {
  subnet_id      = aws_subnet.webapp_sub["public_sub3"].id
  route_table_id = aws_route_table.webapp_publicRT.id
}
