# variables.tf

variable "aws_region" {
  description = "The AWS region where resources will be created"
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The base name of the S3 bucket for storing room scans"
  default     = "ntr-ar-room-scans"
}
