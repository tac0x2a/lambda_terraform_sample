
data "aws_caller_identity" "self" {}

resource "aws_sns_topic" "x-ray_sample_topic" {
  name = "x-ray_sample-topic"
}

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
