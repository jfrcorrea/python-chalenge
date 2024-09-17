data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "validate-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path = "/service-role/"
  tags = {}
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir = "functions/validate"
  output_path = "validate.zip"
}

resource "aws_lambda_function" "validate" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "validate.zip"
  function_name = "validate"
  description = "An Amazon Data Firehose stream processor that accesses the records in the input and returns them with a processing status.  Use this processor for any custom transformation logic."
  role          = aws_iam_role.validate-role.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  tags = {
    "lambda-console:blueprint" = "kinesis-firehose-process-record-python"
  }

  timeout = 60
}