####################
# ACM Certificate Create
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
####################
resource "aws_acm_certificate" "myAcmCertCreate" {
    domain_name = aws_route53_delegation_set.myDnsDelegation.reference_name
    validation_method = "DNS"

    tags = {
      Name = "AWS証明書"
    }

    lifecycle {
        create_before_destroy = "true"
    }
}

####################
# Route53 Deligation Zone
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
####################
data "aws_route53_zone" "myAcmCertCreateZone" {
    name = aws_acm_certificate.myAcmCertCreate.domain_name
    private_zone = "false"
}

####################
# Route53 Deligation Zone Ns Record
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
####################
resource "aws_route53_record" "myAcmCertCreateZoneRecord" {
    for_each = {
    for dvo in aws_acm_certificate.myAcmCertCreate.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
    }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = aws_route53_record.myDnsDelegationZoneRecord.ttl
    type            = each.value.type
    zone_id         = data.aws_route53_zone.myAcmCertCreateZone.zone_id
}

####################
# ACM Certificate Validate FQDN
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation
####################
# resource "aws_acm_certificate_validation" "myAcmCertCreateZoneRecordValidate" {
#     certificate_arn = aws_acm_certificate.myAcmCertCreate.arn
#     validation_record_fqdns = [
#         for record in aws_route53_record.myAcmCertCreateZoneRecord : record.fqdn
#     ]
# }

####################
# ALB Target Listener
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
####################
resource "aws_lb_listener" "myAcmCertCreateZoneRecordAlbLitstener" {
    load_balancer_arn = aws_lb.myAlb.arn
    certificate_arn = aws_acm_certificate.myAcmCertCreate.arn

    port     = "443"
    protocol = "HTTPS"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.myAlbTarget.arn
    }
}

####################
# ALB Listener Rule
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule
####################
# resource "aws_lb_listener_rule" "redirect_http_to_https" {
#     listener_arn = aws_lb_listener.myAlbTargetListener.arn

#     priority = 1

#     action {
#         type = "redirect"

#         redirect {
#             port        = "443"
#             protocol    = "HTTPS"
#             status_code = "HTTP_301"
#         }
#     }

#     condition {
#         http_header {
#             http_header_name = "http-header"
#             values = [
#                 aws_route53_delegation_set.myDnsDelegation.reference_name
#             ]
#         }
#     }
# }
