####################
# EFS
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system
####################
resource "aws_efs_file_system" "myEfs" {
    creation_token = "myEfsToFargate"
    provisioned_throughput_in_mibps = "1"
    throughput_mode = "provisioned"

    lifecycle_policy {
        transition_to_ia = "AFTER_7_DAYS"
    }

    tags = {
        Name = "エラスティックファイルシステム"
    }
}

####################
# EFS Mount Target
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target
####################
resource "aws_efs_mount_target" "myEfsTargetDmz1a" {
    file_system_id = aws_efs_file_system.myEfs.id
    subnet_id = aws_subnet.myDmz1a.id
    security_groups = [
        aws_security_group.sgEfs.id
    ]
}

resource "aws_efs_mount_target" "myEfsTargetDmz1c" {
    file_system_id = aws_efs_file_system.myEfs.id
    subnet_id = aws_subnet.myDmz1c.id
    security_groups = [
        aws_security_group.sgEfs.id
    ]
}
