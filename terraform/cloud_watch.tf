resource "aws_cloudwatch_log_group" "firebose_log_group" {
  name = "/aws/kinesisfirehose/source-stream-delivery"

  tags = {}
}

resource "aws_cloudwatch_log_stream" "firebose_log_stream" {
  name           = "/aws/kinesisfirehose/source-stream"
  log_group_name = aws_cloudwatch_log_group.firebose_log_group.name
}
