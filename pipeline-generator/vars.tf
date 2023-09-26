variable "service_name" {
  type = string
}

variable "module_type" {
  type = string
  default = "service"
}

variable "pipeline_branch" {
  type = string
  default = "main"
}

variable "ci_project_dir" {
  type = string
}

variable "main_enabled" {
  type    = bool
  default = false
}

variable "api_enabled" {
  type    = bool
  default = false
}

variable "service_enabled" {
  type    = bool
  default = false
}

variable "cluster" {
  type = string
}

variable "log_containers" {
  type = string
  default = ""
}

variable "full_deploy" {
  type    = string
  default = "false"
}

variable "services" {
  type    = list(any)
  default = []
}
