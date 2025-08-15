provider "aws" {
  region = var.aws_region
}

locals {
  dev_bucket_name  = "${var.bucket_prefix}-terraform-state-${var.dev_environment_name}${var.bucket_suffix != "" ? "-${var.bucket_suffix}" : ""}"
  prod_bucket_name = "${var.bucket_prefix}-terraform-state-${var.prod_environment_name}${var.bucket_suffix != "" ? "-${var.bucket_suffix}" : ""}"
}

# DEV ENVIRONMENT BUCKET AND CONFIG
####################################

resource "aws_s3_bucket" "terraform_state_dev" {
  bucket = local.dev_bucket_name

  tags = merge(var.common_tags, {
    Name        = "Dev State Storage Bucket"
    Environment = title(var.dev_environment_name)
  })
}

resource "aws_s3_bucket_public_access_block" "terraform_state_dev" {
  bucket = aws_s3_bucket.terraform_state_dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "dev_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_dev.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "dev_encryption" {
  bucket = aws_s3_bucket.terraform_state_dev.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}

# PROD ENVIRONMENT BUCKET CONFIG
#####################################

resource "aws_s3_bucket" "terraform_state_prod" {
  bucket = local.prod_bucket_name

  tags = merge(var.common_tags, {
    Name        = "Prod State Storage Bucket"
    Environment = title(var.prod_environment_name)
  })
}

resource "aws_s3_bucket_public_access_block" "terraform_state_prod" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "prod_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "prod_encryption" {
  bucket = aws_s3_bucket.terraform_state_prod.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.encryption_algorithm
    }
  }
}


