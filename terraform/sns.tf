data "aws_iam_policy_document" "target_topic_iam_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:target_topic"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.jfrcorrea-event-processor.arn]
    }
  }
}

resource "aws_sns_topic" "target_topic" {
  name   = "target_topic"
  policy = data.aws_iam_policy_document.target_topic_iam_policy.json
}
