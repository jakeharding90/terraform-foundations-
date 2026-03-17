locals {
  name_prefix = "terraform-foundations-${var.environment}"

  ecs_cluster_name = "${local.name_prefix}-ecs"
  log_group_name   = "/ecs/${local.name_prefix}"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "terraform-foundations"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = "terraform-foundations-${random_id.bucket_suffix.hex}"

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-foundations-bucket"
    }
  )
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "terraform-foundations-${var.environment}"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags

  public_subnet_tags = {
    Name = "terraform-foundations-public"
  }

  private_subnet_tags = {
    Name = "terraform-foundations-private"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = local.log_group_name
  retention_in_days = 7

  tags = local.common_tags
}

resource "aws_ecs_cluster" "main" {
  name = local.ecs_cluster_name

  tags = local.common_tags
}

resource "aws_security_group" "alb" {
  name        = "terraform-foundations-${var.environment}-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-foundations-${var.environment}-alb-sg"
    }
  )
}

resource "aws_security_group" "ecs_service" {
  name        = "terraform-foundations-${var.environment}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "terraform-foundations-${var.environment}-ecs-sg"
    }
  )
}