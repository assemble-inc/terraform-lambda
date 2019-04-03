variable "application_name" {
  type = "string"
}

variable "application_environment" {
  type    = "string"
  default = ""
}

variable "name" {
  type = "string"
}

variable "file_name" {
  type = "string"
}

variable "handler" {
  type = "string"
}

variable "runtime" {
  type    = "string"
  default = "go1.x"
}

variable "timeout" {
  default = 10
}

variable "memory_size" {
  default = 1024
}

variable "environment_variables" {
  type = "map"
}

variable "tags" {
  type = "map"
}

variable "vpc_subnet_ids" {
  type    = "list"
  default = []
}

variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}
