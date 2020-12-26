####################
# VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
####################
resource "aws_vpc" "myVpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  tags = {
      Name = "vpc-wordpress"
  }
}

####################
# Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
####################
resource "aws_subnet" "mySubnetPub1a" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = "true"

  tags = {
      Name = "パブリックサブネット-1a"
  }
}

resource "aws_subnet" "mySubnetPub1c" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}c"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "パブリックサブネット-1c"
  }
}

resource "aws_subnet" "myDmz1a" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}a"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "非武装地帯-1a"
  }
}

resource "aws_subnet" "myDmz1c" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}c"
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"

  tags = {
      Name = "非武装地帯-1c"
  }
}

resource "aws_subnet" "myPri1a" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}a"
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "true"

  tags = {
      Name = "プライベートサブネット-1a"
  }
}

resource "aws_subnet" "myPri1c" {
  vpc_id = aws_vpc.myVpc.id
  availability_zone = "${var.region}c"
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = "true"

  tags = {
      Name = "プライベートサブネット-1c"
  }
}

####################
# Route Table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
####################
resource "aws_route_table" "myPubRoute1ac" {
    vpc_id = aws_vpc.myVpc.id

    tags = {
      Name = "パブリックルートテーブル"
    }
}

resource "aws_route_table" "myDmzRoute1ac" {
    vpc_id = aws_vpc.myVpc.id

    tags = {
      Name = "非武装地帯ルートテーブル"
    }
}

resource "aws_route_table" "myPriRoute1ac" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "プライベートルートテーブル"
  }
}

####################
# IGW
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway
####################
resource "aws_internet_gateway" "myIgw" {
  vpc_id = aws_vpc.myVpc.id

  tags = {
    Name = "インターネットゲートウェイ"
  }
}

####################
# NATGW
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway
####################
resource "aws_eip" "myEip" {
  vpc = "true"

  tags = {
      Name = "固定IPアドレス"
  }
}

resource "aws_nat_gateway" "myNatGw" {
  allocation_id = aws_eip.myEip.id
  subnet_id = aws_subnet.mySubnetPub1a.id

  tags = {
    Name = "ナットゲートウェイ"
  }

  depends_on = [aws_internet_gateway.myIgw]
}

####################
# Route Rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
####################
resource "aws_route" "myPubRouteRule1ac" {
  route_table_id = aws_route_table.myPubRoute1ac.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.myIgw.id
  depends_on = [aws_route_table.myPubRoute1ac]
}

resource "aws_route" "myDmzRouteRule1ac" {
  route_table_id = aws_route_table.myDmzRoute1ac.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.myNatGw.id
  depends_on = [aws_route_table.myDmzRoute1ac]
}

# resource "aws_route" "myPriRouteRule1ac" {
#   route_table_id = aws_route_table.myPriRoute1ac.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id = aws_internet_gateway.myIgw.id
#   depends_on = [aws_route_table.myPriRoute1ac]
# }

####################
# Route Rule Associcate Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
####################
resource "aws_route_table_association" "myPubRouteRuleAssociatSubnet1a" {
    subnet_id = aws_subnet.mySubnetPub1a.id
    route_table_id = aws_route_table.myPubRoute1ac.id
}

resource "aws_route_table_association" "myPubRouteRuleAssociatSubnet1c" {
    subnet_id = aws_subnet.mySubnetPub1c.id
    route_table_id = aws_route_table.myPubRoute1ac.id
}

resource "aws_route_table_association" "myDmzRouteRuleAssociatSubnet1a" {
    subnet_id = aws_subnet.myDmz1a.id
    route_table_id = aws_route_table.myDmzRoute1ac.id
}

resource "aws_route_table_association" "myDmzRouteRuleAssociatSubnet1c" {
    subnet_id = aws_subnet.myDmz1c.id
    route_table_id = aws_route_table.myDmzRoute1ac.id
}

resource "aws_route_table_association" "myPriRouteRuleAssociatSubnet1a" {
    subnet_id = aws_subnet.myPri1a.id
    route_table_id = aws_route_table.myPriRoute1ac.id
}

resource "aws_route_table_association" "myPriRouteRuleAssociatSubnet1c" {
    subnet_id = aws_subnet.myPri1c.id
    route_table_id = aws_route_table.myPriRoute1ac.id
}
