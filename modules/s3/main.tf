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
}

resource "aws_s3_bucket" "sample_input_bucket" {
  bucket = "tac0x2a-sample-input-bucket"
}

resource "aws_s3_bucket_notification" "sample_input_bucket_notification" {
  bucket = aws_s3_bucket.sample_input_bucket.id

  topic {
    topic_arn     = aws_sns_topic.sample_input_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}