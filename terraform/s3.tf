resource "aws_s3_bucket" "jfrcorrea-event-processor" {
  bucket = "jfrcorrea-event-processor"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.jfrcorrea-event-processor.id

  topic {
    topic_arn     = aws_sns_topic.target_topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "data/"
  }
}
