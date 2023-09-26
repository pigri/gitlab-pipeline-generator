variable "service_name" {
  type = string
}

variable "module_type" {
  type    = string
  default = "service"
}

variable "aws_environment" {
  type = string
}

variable "cluster" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "aws_account" {
  type = string
}

variable "cpu_limit" {
  type    = number
  default = 256
}

variable "memory_limit" {
  type    = number
  default = 512
}

variable "micronaut_environment" {
  type = string
}

variable "ci_project_dir" {
  type = string
}

variable "service_prefix" {
  type    = string
  default = null
}

variable "cpu_architecture" {
  type    = string
  default = "X86_64"
}
