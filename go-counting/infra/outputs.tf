output "s3_bucket_name" {
    description = "The S3 bucket name"
    value = aws_s3_bucket.lb_logs.id
}

output "carrot_s3_object" {
  value = aws_s3_object.app_files["carrot"]
}