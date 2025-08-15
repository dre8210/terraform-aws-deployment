
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
  sensitive   = false
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket names"
  type        = string
  sensitive   = true
}

variable "bucket_suffix" {
  description = "Suffix for S3 bucket names (typically date)"
  type        = string
  default     = ""
}

variable "dev_environment_name" {
  description = "Name for development environment"
  type        = string
  default     = "dev"
}

variable "prod_environment_name" {
  description = "Name for production environment"
  type        = string
  default     = "prod"
}

variable "encryption_algorithm" {
  description = "Server-side encryption algorithm"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.encryption_algorithm)
    error_message = "Encryption algorithm must be either 'AES256' or 'aws:kms'."
  }
}

variable "enable_versioning" {
  description = "Enable versioning on S3 buckets"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "Infrastructure"
  }
}

