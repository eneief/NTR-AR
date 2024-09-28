# main.tf

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket resource
resource "aws_s3_bucket" "room_scans" {
  bucket = "${var.bucket_name}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "NTR-AR Room Scans"
    Environment = "Dev"
  }
}

# Separate resource for bucket ACL
resource "aws_s3_bucket_acl" "room_scans_acl" {
  bucket = aws_s3_bucket.room_scans.id
  acl    = "private"
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "room_scans_versioning" {
  bucket = aws_s3_bucket.room_scans.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# Define the Lambda function
resource "aws_lambda_function" "process_room_scan" {
  function_name    = "process_room_scan"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x" # Adjust based on your Node.js version
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.room_scans.bucket
    }
  }
}

# Define IAM Role and Policy for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.room_scans.arn}/*"
      }
    ]
  })
}
