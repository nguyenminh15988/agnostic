terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "cloud-agnostic"
    key            = "devops-challenge/terraform.tfstate"
    region         = "ap-south-1"
  }
}

provider "aws" {
  region = var.region
}

module "eks" {
  source          = "./eks"
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  region          = var.region
}

module "rds" {
  source         = "./rds"
  db_name        = var.db_name
  db_user        = var.db_user
  db_password    = var.db_password
  db_instance    = var.db_instance
}

resource "aws_lb" "api_alb" {
  name               = "api-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.main[*].id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.api_alb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.main.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
