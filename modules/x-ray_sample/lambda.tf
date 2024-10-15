## IAM Role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
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
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:DeleteMessage"
    ]
    resources = [aws_sqs_queue.x-ray_sample_queue.arn]
  }
}
resource "aws_iam_role" "iam_for_x-ray_lambda" {
  name               = "iam_for_x-ray_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  inline_policy {
    name   = "inline_policy"
    policy = data.aws_iam_policy_document.inline_policy.json
  }
}

## Lambda Layer
locals {
  layer_work_path = "/tmp/x-ray_sample/x-ray_sample_layer"
}
resource "terraform_data" "x-ray_lambda_layer_pip_install" {
  input = local.layer_work_path
  triggers_replace = {
    file_content = md5(file("${path.module}/src/requirements.txt"))
    # file_existance = md5(file("${layer_work_path}/python/requirements.txt"))
    # timestamp = timestamp()
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<EOF
      [[ -d "${local.layer_work_path}/python" ]] && rm -rf "${local.layer_work_path}/python"
      pip install -r '${path.module}/src/requirements.txt' --target='${local.layer_work_path}/python' --no-cache-dir
    EOF
  }
}
data "archive_file" "x-ray_lambda_layer" {
  type        = "zip"
  source_dir  = terraform_data.x-ray_lambda_layer_pip_install.output
  output_path = "${local.layer_work_path}.zip"
}
resource "aws_lambda_layer_version" "x-ray_lambda_layer" {
  filename            = data.archive_file.x-ray_lambda_layer.output_path
  layer_name          = "x-ray_sample_layer"
  source_code_hash    = data.archive_file.x-ray_lambda_layer.output_base64sha256
  compatible_runtimes = ["python3.11"]
}

## Lambda Function
data "archive_file" "x-ray_lambda" {
  type = "zip"
  dynamic "source" {
    for_each = toset([
      "sample.py"
    ])
    content {
      content  = file("${path.module}/src/${source.value}")
      filename = basename(source.value)
    }
  }
  output_path = "/tmp/x-ray_sample/x-ray_sample_payload.zip"
}

resource "aws_lambda_function" "x-ray_lambda" {
  filename         = data.archive_file.x-ray_lambda.output_path
  function_name    = "x-ray_sample_function"
  role             = aws_iam_role.iam_for_x-ray_lambda.arn
  handler          = "sample.handler"
  source_code_hash = data.archive_file.x-ray_lambda.output_base64sha256
  runtime          = "python3.11"
  environment {
    variables = {}
  }
  logging_config {
    log_format = "JSON"
  }
  layers = [aws_lambda_layer_version.x-ray_lambda_layer.arn]
}


resource "aws_lambda_event_source_mapping" "x-ray_sqs2lambda_mapping" {
  event_source_arn = aws_sqs_queue.x-ray_sample_queue.arn
  function_name    = aws_lambda_function.x-ray_lambda.arn
}
