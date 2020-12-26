####################
# ALB
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
####################
resource "aws_lb" "myAlb" {
    name = "myAlbToFargate"
    internal = "false"
    load_balancer_type = "application"
    security_groups = [
        aws_security_group.sgAlb.id
    ]
    subnets = [
        aws_subnet.mySubnetPub1a.id,
        aws_subnet.mySubnetPub1c.id
    ]
}

####################
# ALB Target Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
####################
resource "aws_lb_target_group" "myAlbTarget" {
    name = "myAlbToFargateTarget"
    port = "80"
    protocol = "HTTP"
    target_type = "ip"
    vpc_id = aws_vpc.myVpc.id
    deregistration_delay = "60"

    health_check {
        interval = "10"
        path = "/"
        port = "traffic-port"
        protocol = "HTTP"
        timeout = "4"
        healthy_threshold = "2"
        unhealthy_threshold = "10"
        matcher = "200-302"
    }
}

####################
# ALB Target Listener
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
####################
resource "aws_lb_listener" "myAlbTargetListener" {
    load_balancer_arn = aws_lb.myAlb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "redirect"
        target_group_arn = aws_lb_target_group.myAlbTarget.arn

        redirect {
            port = "443"
            protocol = "HTTPS"
            status_code = "HTTP_301"
        }
    }
}
