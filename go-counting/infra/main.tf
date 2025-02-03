terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "random" {
  # Configuration options
}

# Random string for naming things

resource "random_string" "random" {
  length           = 8
  special          = false
  numeric          = false
  upper          = false
  }


# Certificate

module "certificate" {
  source = "../../terraform-modules/aws-acm-certificate"
  domain_name = var.domain_name
  dns_zone = var.dns_zone
  region = "ap-southeast-2"
}

## Load balancer

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name_prefix = "alb-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# ALB

resource "aws_lb" "main" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  access_logs {
    bucket  = aws_s3_bucket.lb_logs.bucket
    prefix  = "alb-logs"
    enabled = true
  }
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.certificate.certificate_arn
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}


# Logging on ALB

# S3 Bucket for ALB Logs
resource "aws_s3_bucket" "lb_logs" {
  bucket = "alb-logs-${random_string.random.}"
}

data "aws_elb_service_account" "main" {}

data "aws_iam_policy_document" "allow_elb_logging" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.lb_logs.arn}/AWSLogs/*"]
  }
}

resource "aws_s3_bucket_policy" "allow_elb_logging" {
  bucket = aws_s3_bucket.lb_logs.id
  policy = data.aws_iam_policy_document.allow_elb_logging.json
}