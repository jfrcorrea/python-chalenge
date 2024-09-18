data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_kinesis_stream" "source_stream" {
  name                      = "SourceStream"
  retention_period          = 24
  enforce_consumer_deletion = null

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }

  tags = {}
}

resource "aws_kinesis_firehose_delivery_stream" "kds" {
  name        = "KDS"
  destination = "extended_s3"
  tags        = {}

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.jfrcorrea-event-processor.arn
    buffering_interval  = 0
    prefix              = "data/"
    error_output_prefix = "error/"

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.firebose_log_group.name
      log_stream_name = aws_cloudwatch_log_stream.firebose_log_stream.name
    }

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = 0
        }
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.validate.arn}:$LATEST"
        }
      }
    }
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.source_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}

resource "aws_iam_role" "firehose_role" {
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
  path               = "/service-role/"
  tags               = {}
}

resource "aws_iam_policy" "kinesis_firehose" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "kinesis:DescribeStream",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords",
            "kinesis:ListShards"
        ],
        "Resource": "${aws_kinesis_stream.source_stream.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.kinesis_firehose.arn
}

resource "aws_iam_policy" "put_record" {
  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [
                "${aws_kinesis_firehose_delivery_stream.kds.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "put_record" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.put_record.arn
}

resource "aws_iam_policy" "firehose_cloudwatch" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": [
            "${aws_cloudwatch_log_group.firebose_log_group.arn}"
        ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_cloudwatch" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_cloudwatch.arn
}
