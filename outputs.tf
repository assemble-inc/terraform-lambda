output "function_arn" {
  value = "${aws_lambda_function.lambda.arn}"
}

output "function_name" {
  value = "${aws_lambda_function.lambda.function_name}"
}

output "invoke_arn" {
  value = "${aws_lambda_function.lambda.invoke_arn}"
}

output "role_id" {
  value = "${aws_iam_role.lambda_role.id}"
}
