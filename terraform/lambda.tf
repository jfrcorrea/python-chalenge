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

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "functions/validate"
  output_path = "validate.zip"
}

resource "aws_iam_role" "validate-role" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  path               = "/service-role/"
  tags               = {}
}

resource "aws_lambda_function" "validate" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "validate.zip"
  function_name = "validate"
  description   = "An Amazon Data Firehose stream processor that accesses the records in the input and returns them with a processing status.  Use this processor for any custom transformation logic."
  role          = aws_iam_role.validate-role.arn
  handler       = "main.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"

  tags = {
    "lambda-console:blueprint" = "kinesis-firehose-process-record-python"
  }

  timeout = 60
}

resource "aws_iam_policy" "firehose_lambda" {
  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction",
          "lambda:GetFunctionConfiguration"
        ],
        "Resource": "${aws_lambda_function.validate.arn}:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_lambda_policy" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_lambda.arn
}
