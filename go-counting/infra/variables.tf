variable "name" {
  description = "A name variable"
  type        = string
  default     = "goplayground"
}

variable "private_subnets_cidr_block" {
  description = "cidr blocks for th public subnets"
  type = list
}

variable "public_subnets_cidr_block" {
  description = "cidr blocks for th public subnets"
  type = list
}

variable "domain_name" {
  description = "the domain name for the site"
  type = string
}

variable "dns_zone" {
  description = "teh dns zone name"
  type = string
}