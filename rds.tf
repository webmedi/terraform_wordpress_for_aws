####################
# RDS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
####################
resource "aws_db_parameter_group" "myRds" {
    name = "myrdsparamgroup"
    family = "mysql8.0"
    description = "myRds"
}

####################
# RDS Subnet Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
####################
resource "aws_db_subnet_group" "myRdsSubnetGroup" {
    name = "rdssubnetgroup"
    description = "rdsSunetGp"
    subnet_ids = [
        aws_subnet.myPri1a.id,
        aws_subnet.myPri1c.id
     ]
}

####################
# RDS Instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
####################
variable "aws_rds_user" {}
variable "aws_rds_pass" {}

resource "aws_db_instance" "myRdsInstance" {
    identifier = "myrdstofargatedb"
    engine = "mysql"
    engine_version = "8.0.20"
    instance_class = "db.t3.micro"
    storage_type = "gp2"
    allocated_storage = 50
    max_allocated_storage = 200
    username = var.aws_rds_user
    password = var.aws_rds_pass
    final_snapshot_identifier = "myRdsInstanceDbFinal"
    db_subnet_group_name = aws_db_subnet_group.myRdsSubnetGroup.name
    parameter_group_name = aws_db_parameter_group.myRds.name
    multi_az = "false"
    vpc_security_group_ids = [
        aws_security_group.sgRds.id
    ]
    backup_retention_period = "7"
    apply_immediately = "true"
    #publicly_accessible = "true"
}
