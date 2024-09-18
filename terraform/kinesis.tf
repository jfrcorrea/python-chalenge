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
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.jfrcorrea-event-processor.arn
    buffering_interval = 0
    prefix             = "data/"

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
