# AWS Lambda Terraform Module

Convenience module for AWS Lambda

## Usage

```tf
module "get-user-lambda" {
  source                       = "assemble-inc/lambda/simple"
  source_path           = "./bin/get-user-bin"
  handler               = "get-user"
  environment_variables = {
    "AWS_REGION": "US_WEST_2"
  }
}
```

## Inputs

- **source_path**: Source Path
- **handler**: Lambda Handler
- **runtime**: Runtime _(Default: go1.x)_
- **timeout**: Timeout _(Default: 10)_
- **memory_size**: Memory size _(Default: 1024)_
- **environment_variables**: Environment variables map

## Outputs

- **arn**: Lambda function ARN
- **function_name**: Lambda function name
- **invoke_arn**: Lambda invoke ARN
- **role_id**: Lambda execution role ID
