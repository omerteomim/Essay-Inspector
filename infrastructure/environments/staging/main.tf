terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "omer-state-tf"
    key    = "essay/staging/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "lambda_essay" {
  source = "../../modules/lambda-essay"

  function_name      = "essay-lambda-${var.environment}"
  lambda_zip_path    = var.lambda_zip_path
  api_key           = var.api_key
  s3_bucket         = var.s3_bucket
}