####################
# ECS Cluster
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
####################
resource "aws_ecs_cluster" "myEcsCluster" {
    name = "my_ecs_cluster"

    setting {
        name = "containerInsights"
        value = "disabled"
    }
}

####################
# ECS Task Definition
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
####################
resource "aws_ecs_task_definition" "myEcsClusterTask" {
    family = "task-fargate-wordpress"
    container_definitions = file("tasks/myEcsClusterTask.json")
    cpu = "256"
    memory = "512"
    network_mode = "awsvpc"
    execution_role_arn = aws_iam_role.myIamFargateTaskExec.arn

    volume {
        name = "ecs_cluster_task"

        efs_volume_configuration {
            file_system_id = aws_efs_file_system.myEfs.id
            root_directory = "/"
        }
    }

    requires_compatibilities = [
        "FARGATE"
     ]
}

####################
# ECS Task Service
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
####################
resource "aws_ecs_service" "myEcsClusterTaskService" {
    name = "ecs_cluster_task_service"
    cluster = aws_ecs_cluster.myEcsCluster.arn
    task_definition = aws_ecs_task_definition.myEcsClusterTask.arn
    desired_count = "2"
    launch_type = "FARGATE"
    platform_version = "1.4.0"

    load_balancer {
        target_group_arn = aws_lb_target_group.myAlbTarget.arn
        container_name = "wordpress"
        container_port = "80"
    }

    network_configuration {
        subnets = [
            aws_subnet.myDmz1a.id,
            aws_subnet.myDmz1c.id
        ]
        security_groups = [
            aws_security_group.sgFargate.id
        ]
        assign_public_ip = "false"
    }
}
