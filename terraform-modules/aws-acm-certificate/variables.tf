variable "domain_name" {
  description = "the domain name for the site"
  type = string
}

variable "dns_zone" {
  description = "the dns zone name"
  type = string
}

variable "region" {
    description = "the region to create the certificate"
    type = string
}