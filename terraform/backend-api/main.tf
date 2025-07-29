terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "dev-test"
}


resource "random_pet" "pet_name" {
  length    = 3
  separator = "-"
}

resource "aws_dynamodb_table" "my-dynamodb" {
  name         = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

}

resource "aws_dynamodb_table_item" "visits" {
  table_name = aws_dynamodb_table.my-dynamodb.name
  hash_key   = "id"
  item = jsonencode({
    "id" : {
      "S" : "visitors"
    },
    "number" : {
      "N" : "1"
    }
  })

}


resource "aws_s3_bucket" "bucket" {
  bucket = "${random_pet.pet_name.id}-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

data "archive_file" "lambda_function_update" {
  type = "zip"

  source_dir  = "${path.module}/lambda_function_update"
  output_path = "${path.module}/lambda_function_update.zip"
}

data "archive_file" "lambda_function" {
  type = "zip"

  source_dir  = "${path.module}/lambda-function_get"
  output_path = "${path.module}/lambda-function_get.zip"
}

resource "aws_s3_object" "python_function" {
  bucket = aws_s3_bucket.bucket.id

  key    = "lambda-function.zip"
  source = data.archive_file.lambda_function.output_path

  etag = filemd5(data.archive_file.lambda_function.output_path)

}

resource "aws_s3_object" "python_function_2" {
  bucket = aws_s3_bucket.bucket.id

  key    = "lambda_function_update.zip"
  source = data.archive_file.lambda_function_update.output_path

  etag = filemd5(data.archive_file.lambda_function_update.output_path)

}

resource "aws_cloudwatch_log_group" "hello_world" {
  name = "/aws/lambda/${aws_lambda_function.get_visits.function_name}"

  retention_in_days = 30
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.my-dynamodb.arn]
    effect    = "Allow"
  }

  statement {
    actions   = ["*"]
    resources = [aws_cloudwatch_log_group.hello_world.arn]
    effect    = "Allow"
  }

}

resource "aws_iam_policy" "policy" {
  name        = "AccessToDynamoDB"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.policy.arn
}


resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "get_visits" {
  function_name = "get_visits"

  s3_bucket = aws_s3_bucket.bucket.id
  s3_key    = aws_s3_object.python_function.key

  runtime = "python3.9"
  handler = "lambda_get.lambda_handler"

  source_code_hash = data.archive_file.lambda_function_update.output_base64sha256

  role = aws_iam_role.lambda_role.arn

}

resource "aws_lambda_function" "update_visits" {
  function_name = "update_counter"

  s3_bucket = aws_s3_bucket.bucket.id
  s3_key    = aws_s3_object.python_function_2.key

  runtime = "python3.9"
  handler = "lambda_update_item.lambda_handler"

  source_code_hash = data.archive_file.lambda_function_update.output_base64sha256

  role = aws_iam_role.lambda_role.arn

}