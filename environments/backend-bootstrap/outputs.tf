# outputs.tf
output "dev_bucket_name" {
  description = "Name of the development S3 bucket"
  value       = aws_s3_bucket.terraform_state_dev.id
}

output "prod_bucket_name" {
  description = "Name of the production S3 bucket"
  value       = aws_s3_bucket.terraform_state_prod.id
}

output "dev_bucket_arn" {
  description = "ARN of the development S3 bucket"
  value       = aws_s3_bucket.terraform_state_dev.arn
}

output "prod_bucket_arn" {
  description = "ARN of the production S3 bucket"
  value       = aws_s3_bucket.terraform_state_prod.arn
}
