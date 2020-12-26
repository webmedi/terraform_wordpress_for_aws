####################
# Security Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
####################
resource "aws_security_group" "sgAlb" {
    name = "fw-alb"
    description = "SG_ALB"
    vpc_id = aws_vpc.myVpc.id
}

resource "aws_security_group" "sgFargate" {
    name = "fw-fargate"
    description = "SG_FARGATE"
    vpc_id = aws_vpc.myVpc.id
}

resource "aws_security_group" "sgEfs" {
    name = "fw-efs"
    description = "SG_EFS"
    vpc_id = aws_vpc.myVpc.id
}

resource "aws_security_group" "sgRds" {
    name = "fw-rds"
    description = "SG_RDS"
    vpc_id = aws_vpc.myVpc.id
}

####################
# Security Group Rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule
####################
resource "aws_security_group_rule" "sgAlbAccept80" {
    security_group_id = aws_security_group.sgAlb.id
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_ALB_ACCEPT_80"
}

resource "aws_security_group_rule" "sgAlbAccept443" {
    security_group_id = aws_security_group.sgAlb.id
    type = "ingress"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_ALB_ACCEPT_443"
}

resource "aws_security_group_rule" "sgFargateAccept80" {
    security_group_id = aws_security_group.sgFargate.id
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    source_security_group_id = aws_security_group.sgAlb.id
    description = "SG_FORGATE_ACCEPT_80"
}

resource "aws_security_group_rule" "sgFargateAccept443" {
    security_group_id = aws_security_group.sgFargate.id
    type = "ingress"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    source_security_group_id = aws_security_group.sgAlb.id
    description = "SG_FORGATE_ACCEPT_443"
}

resource "aws_security_group_rule" "sgEFSAccept2049" {
    security_group_id = aws_security_group.sgEfs.id
    type = "ingress"
    protocol = "tcp"
    from_port = 2049
    to_port = 2049
    source_security_group_id = aws_security_group.sgFargate.id
    description = "SG_EFS_ACCEPT_2049"
}

resource "aws_security_group_rule" "sgRdsAccept3306" {
    security_group_id = aws_security_group.sgRds.id
    type = "ingress"
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    source_security_group_id = aws_security_group.sgFargate.id
    description = "SG_RDS_ACCEPT_3306"
}

# variable "aws_rds_mante_ip" {}

# resource "aws_security_group_rule" "sgRdsAccept3306io" {
#     security_group_id = aws_security_group.sgRds.id
#     type = "ingress"
#     protocol = "all"
#     from_port = 0
#     to_port = 65535
#     cidr_blocks = [ var.aws_rds_mante_ip ]
#     description = "SG_RDS_ACCEPT_3306"
# }

resource "aws_security_group_rule" "sgAlbAccept0" {
    security_group_id = aws_security_group.sgAlb.id
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_ALB_ACCEPT_ANY_OUTBOUND"
}

resource "aws_security_group_rule" "sgFargateAccept0" {
    security_group_id = aws_security_group.sgFargate.id
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_FARGATE_ACCEPT_ANY_OUTBOUND"
}

resource "aws_security_group_rule" "sgEfsAccept0" {
    security_group_id = aws_security_group.sgEfs.id
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_EFS_ACCEPT_ANY_OUTBOUND"
}

resource "aws_security_group_rule" "sgRdsAccept0" {
    security_group_id = aws_security_group.sgRds.id
    type = "egress"
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "SG_RDS_ACCEPT_ANY_OUTBOUND"
}
