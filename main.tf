terraform {
  backend "s3" {
    bucket         = "omer-state-tf"
    key            = "essay/terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# Lambda function
resource "aws_lambda_function" "essay" {
  function_name    = var.function_name
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 179
  memory_size      = 256
  layers           = ["arn:aws:lambda:us-east-1:463470967866:layer:requests:1"]
  
  environment {
    variables = {
      OPENROUTER_API_KEY = var.api_key
    }
  }
  
  role = aws_iam_role.lambda_role.arn
}

# Function URL for Lambda
resource "aws_lambda_function_url" "essay_url" {
  function_name      = aws_lambda_function.essay.function_name
  authorization_type = "NONE"
  cors{
    allow_origins  = ["*"]
    allow_methods  = ["*"]
    allow_headers  = ["content-type"]
    expose_headers = ["content-type"]
    max_age        = 86400
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"
  
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

# Basic execution permissions for Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions for Lambda Function URL to invoke the Lambda function
resource "aws_lambda_permission" "allow_lambda_url_invocation" {
  statement_id  = "AllowExecutionFromLambdaURL"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.essay.function_name
  principal     = "lambda.amazonaws.com"
}

# CloudWatch logs for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

# Output the function URL
output "function_url" {
  value = aws_lambda_function_url.essay_url.function_url
}