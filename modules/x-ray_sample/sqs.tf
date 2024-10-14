resource "aws_sqs_queue" "x-ray_sample_queue" {
  name = "x-ray_sample_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.x-ray_sample_queue_dlq.arn
    maxReceiveCount     = 4
  })
}
data "aws_iam_policy_document" "x-ray_sample_queue_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.x-ray_sample_queue.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.x-ray_sample_topic.arn]
    }
  }
}
resource "aws_sqs_queue_policy" "x-ray_sample_queue_policy" {
  queue_url = aws_sqs_queue.x-ray_sample_queue.id
  policy    = data.aws_iam_policy_document.x-ray_sample_queue_policy.json
}
resource "aws_sns_topic_subscription" "x-ray_sample_queue_subscription" {
  topic_arn = aws_sns_topic.x-ray_sample_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.x-ray_sample_queue.arn
}

resource "aws_sqs_queue" "x-ray_sample_queue_dlq" {
  name = "x-ray_sample_queue_dlq"
}
resource "aws_sqs_queue_redrive_allow_policy" "x-ray_sample_queue_redrive_allow_policy" {
  queue_url = aws_sqs_queue.x-ray_sample_queue_dlq.id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.x-ray_sample_queue.arn]
  })
}
