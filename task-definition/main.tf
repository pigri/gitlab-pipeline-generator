locals {
  service_prefix = var.service_prefix == null ? var.cluster : var.service_prefix
  service_name   = var.cluster == "main" ? var.service_name : "${local.service_prefix}-${var.service_name}"
  module_type    = var.module_type
}

resource "local_file" "task_definition" {
  content              = data.template_file.task_definition.rendered
  directory_permission = "0750"
  file_permission      = "0644"
  filename             = "${var.ci_project_dir}/service-${var.service_name}/ci/task_definition.json"
}

data "template_file" "task_definition_env" {
  template = file("${path.module}/env.tpl")
  vars = {
    aws_environment       = var.aws_environment
    micronaut_environment = var.micronaut_environment
    memory                = var.memory_limit
    service_name          = var.service_name
    module_type           = var.module_type
  }
}

data "template_file" "task_definition" {
  template = file("${path.module}/task_definition.tpl")
  vars = {
    service_name          = var.service_name
    environment_variables = data.template_file.task_definition_env.rendered
    aws_environment       = var.aws_environment
    cluster               = var.cluster
    aws_region            = var.aws_region
    image_tag             = var.image_tag
    aws_account           = var.aws_account
    cpu                   = var.cpu_limit
    memory                = var.memory_limit
    cpu_architecture      = var.cpu_architecture
  }
}
