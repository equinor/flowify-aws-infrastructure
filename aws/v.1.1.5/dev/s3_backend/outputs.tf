output "bucket_region" {
  value = module.s3_backend.bucket_region
}

output "bucket_name" {
  value = module.s3_backend.bucket_name
}

output "bucket_arn" {
  value = module.s3_backend.bucket_arn
}

output "dynamodb_table_name" {
  value = module.s3_backend.dynamodb_table_name
}

output "dynamodb_table_arn" {
  value = module.s3_backend.dynamodb_table_arn
}

