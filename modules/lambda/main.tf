data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.sample-dynamodb-table.arn]
  }
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name = "inline_policy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "${path.module}/sample_function/src/"
  output_path = "/tmp/sample_function/sample_lambda_function_payload.zip"
}

resource "aws_lambda_function" "test_lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "sample_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "hello.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.sample-dynamodb-table.name
    }
  }
}