####################
# Route53 Deligation Set
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_delegation_set
####################
variable "domain" {}

resource "aws_route53_delegation_set" "myDnsDelegation" {
    reference_name = var.domain
}

####################
# Route53 Deligation Zone
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone
####################
# data "aws_route53_zone" "myDnsDelegationDataZone" {
#     name = aws_route53_delegation_set.myDnsDelegation.reference_name
# }

resource "aws_route53_zone" "myDnsDelegationZone" {
    name = aws_route53_delegation_set.myDnsDelegation.reference_name

    tags = {
      Name = "サブドメイン"
    }
}

####################
# Route53 Deligation Zone Ns Record
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
####################
resource "aws_route53_record" "myDnsDelegationZoneRecord" {
    allow_overwrite = "true"
    #zone_id = data.aws_route53_zone.myDnsDelegationDataZone.id
    zone_id = aws_route53_zone.myDnsDelegationZone.id
    name = aws_route53_delegation_set.myDnsDelegation.reference_name
    type = "NS"
    ttl = "60"
    records = [
        aws_route53_zone.myDnsDelegationZone.name_servers[0],
        aws_route53_zone.myDnsDelegationZone.name_servers[1],
        aws_route53_zone.myDnsDelegationZone.name_servers[2],
        aws_route53_zone.myDnsDelegationZone.name_servers[3],
    ]
}

resource "aws_route53_record" "myDnsDelegationZoneRecordLbAlias" {
    zone_id = aws_route53_record.myDnsDelegationZoneRecord.zone_id
    name    = aws_route53_record.myDnsDelegationZoneRecord.name
    type    = "A"

    alias {
        name                   = aws_lb.myAlb.dns_name
        zone_id                = aws_lb.myAlb.zone_id
        evaluate_target_health = true
    }
}
