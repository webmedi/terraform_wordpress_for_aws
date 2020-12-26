####################
# IAM Role
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
####################
resource "aws_iam_role" "myIamFargateTaskExec" {
    name = "role_iam_fargate_task_exec"
    assume_role_policy = file("roles/myIamFargateTaskExec.json")
}

####################
# IAM Role Policy
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy
####################
resource "aws_iam_role_policy" "myIamFargateTaskExec" {
    name = "iam_fargate_task_exec_policy"
    role = aws_iam_role.myIamFargateTaskExec.name
    policy = file("roles/myIamFargateTaskExecPolicy.json")
}
