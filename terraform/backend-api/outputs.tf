output "bucket_name" {
  value       = aws_s3_bucket.bucket.id
  description = "Bucket Name"

}

output "url" {
  value = aws_api_gateway_stage.example.invoke_url

}