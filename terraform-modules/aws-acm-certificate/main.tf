terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.region
}


resource "aws_acm_certificate" "app" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

data "aws_route53_zone" "app" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "app" {
  for_each = {
    for dvo in aws_acm_certificate.app.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.app.zone_id
}

resource "aws_acm_certificate_validation" "app" {
  certificate_arn         = aws_acm_certificate.app.arn
  validation_record_fqdns = [for record in aws_route53_record.app : record.fqdn]
}