variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "essay_lambda"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda deployment package"
  type        = string
  default     = "lambda_function.zip"
}

variable "api_key" {
  description = "deepseek api key"
  type        = string
  sensitive   = true
}

variable "s3_bucket" {
  description = "s3 bucket for static website"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "environment name"
  type        = string
  default     = "staging"
}