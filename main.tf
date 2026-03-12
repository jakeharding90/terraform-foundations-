locals {
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