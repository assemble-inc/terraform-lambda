terraform {
  required_version = ">= 0.10.0"
}

locals {
  application_name        = "${var.application_name}"
  application_environment = "${coalesce(var.application_environment, terraform.workspace)}"

  name = "${var.name}"

  filename               = "${var.filename}"
  handler                = "${var.handler}"
  runtime                = "${var.runtime}"
  timeout                = "${var.timeout}"
  memory_size            = "${var.memory_size}"
  environment_variables  = "${var.environment_variables}"
  tags                   = "${var.tags}"
  vpc_subnet_ids         = "${var.vpc_subnet_ids}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
}

# Lambda

data "template_file" "lambda_template" {
  template = "${local.name}"
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

resource "aws_iam_role" "lambda_role" {
  name               = "${local.application_name}_${data.template_file.lambda_template.rendered}_${local.application_environment}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

resource "aws_lambda_function" "lambda" {
  function_name = "${local.application_name}_${data.template_file.lambda_template.rendered}_${local.application_environment}"
  filename      = "${local.filename}"
  runtime       = "${local.runtime}"
  role          = "${aws_iam_role.lambda_role.arn}"
  handler       = "${local.handler}"
  timeout       = "${local.timeout}"
  memory_size   = "${local.memory_size}"

  environment {
    variables = "${local.environment_variables}"
  }

  tags = "${local.tags}"

  vpc_config {
    subnet_ids         = ["${local.vpc_subnet_ids}"]
    security_group_ids = ["${local.vpc_security_group_ids}"]
  }
}

# CloudWatch
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

resource "aws_iam_role_policy" "lambda_cloudwatch" {
  name   = "${local.application_name}_cloudwatch_access"
  role   = "${aws_iam_role.lambda_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_cloudwatch_policy.json}"
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch" {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
  tags              = "${local.tags}"
}

data "aws_iam_policy_document" "lambda_vpc_policy" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_vpc" {
  name   = "${local.application_name}_vpc_access"
  role   = "${aws_iam_role.lambda_role.id}"
  policy = "${data.aws_iam_policy_document.lambda_vpc_policy.json}"
}

resource "aws_cloudwatch_event_rule" "keep_warm" {
  name = "${local.application_name}_${local.name}_${local.application_environment}"

  depends_on = [
    "aws_lambda_function.lambda",
  ]

  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  target_id = "lambda"                                      // Worked for me after I added `target_id`
  rule      = "${aws_cloudwatch_event_rule.keep_warm.name}"
  arn       = "${aws_lambda_function.lambda.arn}"
}

resource "aws_lambda_permission" "lambda_keep_warm_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.keep_warm.arn}"
}
