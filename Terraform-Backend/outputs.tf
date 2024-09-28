# outputs.tf

output "s3_bucket_name" {
  value       = aws_s3_bucket.room_scans.bucket
  description = "The name of the S3 bucket for storing room scans"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.process_room_scan.arn
  description = "The ARN of the Lambda function that processes room scans"
}
