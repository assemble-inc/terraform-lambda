terraform {
  required_version = ">= 0.10.0"
}

# Lambda
data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${var.lambda_source_path}"
  output_path = "${var.lambda_source_path}.zip"
}

data "template_file" "lambda_template" {
  template = "${var.lambda_handler}"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "${data.template_file.lambda_template.rendered}"
  filename         = "${data.archive_file.lambda_archive.output_path}"
  source_code_hash = "${data.archive_file.lambda_archive.output_base64sha256}"
  runtime          = "${var.lambda_runtime}"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "${var.lambda_handler}"
  timeout          = "${var.lambda_timeout}"
  memory_size      = "${var.lambda_memory_size}"

  environment {
    variables = "${var.lambda_environment_variables}"
  }

  tags = "${var.tags}"
}

# IAM
resource "aws_iam_role" "lambda_role" {
  name               = "${data.template_file.lambda_template.rendered}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "apigateway.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }
  }
}

# Cloudwatch
resource "aws_iam_policy" "lambda_cloudwatch" {
  name        = "${aws_lambda_function.lambda.function_name}"
  description = "Cloudwatch logging policy"

  policy = "${data.aws_iam_policy_document.lambda_cloudwatch_policy.json}"
}

data "aws_iam_policy_document" "lambda_cloudwatch_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "lambda_cloudwatch" {
  name       = "${aws_lambda_function.lambda.function_name}"
  roles      = ["${aws_iam_role.lambda_role.id}"]
  policy_arn = "${aws_iam_policy.lambda_cloudwatch.arn}"
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  tags = "${var.tags}"
}
