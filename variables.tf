variable "lambda_source_path" {
  type = "string"
}

variable "lambda_handler" {
  type = "string"
}

variable "lambda_runtime" {
  type    = "string"
  default = "go1.x"
}

variable "lambda_timeout" {
  default = 10
}

variable "lambda_memory_size" {
  default = 128
}

variable "lambda_environment_variables" {
  type = "map"
}

variable "tags" {
  type = "map"
}
