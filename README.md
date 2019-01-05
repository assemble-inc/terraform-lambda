# AWS Lambda Terraform Module

Convenience module for AWS Lambda

## Usage

```tf
module "get-user-lambda" {
  source                       = "assemble-inc/lambda"
  lambda_source_path           = "./bin/get-user-bin"
  lambda_handler               = "get-user"
  lambda_environment_variables = {
    "AWS_REGION": "US_WEST_2"
  }
}
```

## Inputs

- **lambda_source_path**: Source Path
- **lambda_handler**: Lambda Handler
- **lambda_runtime**: Runtime _(Default: go1.x)_
- **lambda_timeout**: Timeout _(Default: 10)_
- **lambda_memory_size**: Memory size _(Default: 128)_
- **lambda_environment_variables**: Environment variables map

## Outputs

- **function_arn**: Lambda function ARN
- **function_name**: Lambda function name
- **invoke_arn**: Lambda Invoke ARN
- **role_id**: Lambda Role ID
- **policy_arn**: Dynamo Policy ARN
