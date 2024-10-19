
data "aws_caller_identity" "self" {}
data "aws_iam_policy_document" "x-ray_sample_topic_policy" {
  statement {
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
    resources = [aws_sns_topic.x-ray_sample_topic.arn]

    principals {
      type        = "AWS"
      identifiers = ["${data.aws_caller_identity.self.account_id}"]
    }

  }
}

resource "aws_sns_topic_policy" "smaple_topic_policy" {
  arn    = aws_sns_topic.x-ray_sample_topic.arn
  policy = data.aws_iam_policy_document.x-ray_sample_topic_policy.json
}

data "aws_iam_policy_document" "sns_feedback_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "sns_feedback_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
      "logs:PutRetentionPolicy"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}
resource "aws_iam_role" "sns_feedback" {
  name               = "sns_feedback"
  assume_role_policy = data.aws_iam_policy_document.sns_feedback_assume_role_policy.json
  inline_policy {
    name   = "sns_feedback_inline_policy"
    policy = data.aws_iam_policy_document.sns_feedback_inline_policy.json
  }
}

resource "aws_sns_topic" "x-ray_sample_topic" {
  name                             = "x-ray_sample-topic"
  sqs_success_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  sqs_failure_feedback_role_arn    = aws_iam_role.sns_feedback.arn
  sqs_success_feedback_sample_rate = 100
}
