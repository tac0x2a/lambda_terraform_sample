# SNS Topic
data "aws_iam_policy_document" "sns_topic_service_role_policy" {
  statement {
    effect = "Allow"
    actions   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:PutMetricFilter",
        "logs:PutRetentionPolicy"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "sns_topic_service_role" {
  name = "sns_topic_service_role"
  inline_policy {
    name   = "inline_sns_topic_service_role_policy"
    policy = data.aws_iam_policy_document.sns_topic_service_role_policy.json
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sns.amazonaws.com"
        }
      }]
  })
}

data "aws_iam_policy_document" "topic" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:s3-event-notification-topic"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.sample_input_bucket.arn]
    }
  }
}
resource "aws_sns_topic" "sample_input_topic" {
  name   = "s3-event-notification-topic"
  policy = data.aws_iam_policy_document.topic.json

  sqs_failure_feedback_role_arn = aws_iam_role.sns_topic_service_role.arn
  sqs_success_feedback_role_arn = aws_iam_role.sns_topic_service_role.arn
  sqs_success_feedback_sample_rate = 100
}


# S3 Bucket
resource "aws_s3_bucket" "sample_input_bucket" {
  bucket = "tac0x2a-sample-input-bucket"
}
resource "aws_s3_bucket_notification" "sample_input_bucket_notification" {
  bucket = aws_s3_bucket.sample_input_bucket.id

  topic {
    topic_arn     = aws_sns_topic.sample_input_topic.arn
    events        = ["s3:ObjectCreated:*"]
  }
}

# SQS
resource "aws_sqs_queue" "sample_input_queue" {
  name                      = "sample_input_queue"
}

data "aws_iam_policy_document" "sqs_queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.sample_input_queue.arn]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.sample_input_topic.arn]
    }
  }
}
resource "aws_sqs_queue_policy" "sample_sns2sqs_policy" {
  queue_url = aws_sqs_queue.sample_input_queue.id
  policy    = data.aws_iam_policy_document.sqs_queue.json
}

resource "aws_sns_topic_subscription" "sample_sns2sqs" {
  topic_arn = aws_sns_topic.sample_input_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sample_input_queue.arn
}
