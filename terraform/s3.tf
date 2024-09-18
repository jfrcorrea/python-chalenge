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

resource "aws_iam_policy" "firehose_s3" {
  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
        ],
        "Resource": [
            "${aws_s3_bucket.jfrcorrea-event-processor.arn}",
            "${aws_s3_bucket.jfrcorrea-event-processor.arn}/*"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_s3" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_s3.arn
}
