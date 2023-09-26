locals {
  new_line               = "\n\n"
  service_name           = trimspace(var.service_name)
  module_type            = trimspace(split("-", local.service_name)[0])
  service_name_wo_prefix = trimspace(split("${local.module_type}-", local.service_name)[1])
  cluster                = trimspace(var.cluster)
  pipeline_branch        = var.pipeline_branch
  log_containers         = trimspace(var.log_containers)
  service_name_variable  = join("", ["$", replace(upper(local.service_name), "-", "_")])
  full_deploy            = var.full_deploy == "" ? false : var.full_deploy
}

data "template_file" "test_stage" {
  template = file("${path.module}/templates/test.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    service_name_variable = local.service_name_variable
  }
}

data "template_file" "deploy_stage" {
  template = file("${path.module}/templates/deploy.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    cluster               = local.cluster
    service_name_variable = local.service_name_variable
  }
}

data "template_file" "build_stage" {
  template = file("${path.module}/templates/build.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    service_name_variable = local.service_name_variable
  }
}

data "template_file" "compile_stage" {
  template = file("${path.module}/templates/compile.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    service_name_variable = local.service_name_variable
  }
}

data "template_file" "test_api_stage" {
  template = file("${path.module}/templates/test-api.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    service_name_variable = local.service_name_variable
  }
}

data "template_file" "publish_api_stage" {
  template = file("${path.module}/templates/publish-api.tpl")
  vars = {
    service_name_full     = local.service_name
    module_type           = local.module_type
    service_name          = local.service_name_wo_prefix
    service_name_variable = local.service_name_variable
  }
}

resource "local_file" "main" {
  count                = var.main_enabled ? 1 : 0
  content              = templatefile("${path.module}/templates/main.tpl", { full_deploy = local.full_deploy, pipeline_branch = local.pipeline_branch, module_type = local.module_type, services = var.services, log_containers = local.log_containers })
  directory_permission = "0750"
  file_permission      = "0644"
  filename             = "${var.ci_project_dir}/generated-pipeline.yml"
}

resource "local_file" "service" {
  count                = var.service_enabled ? 1 : 0
  content              = "${local.new_line}${data.template_file.test_stage.rendered}${local.new_line}${data.template_file.build_stage.rendered}${local.new_line}${data.template_file.compile_stage.rendered}${local.new_line}${data.template_file.deploy_stage.rendered}"
  directory_permission = "0750"
  file_permission      = "0644"
  filename             = "${var.ci_project_dir}/temp/${local.service_name}.yml"

  provisioner "local-exec" {
    command = "cat ${var.ci_project_dir}/temp/${local.service_name}.yml >> ${var.ci_project_dir}/generated-pipeline.yml"
  }
}

resource "local_file" "api" {
  count                = var.api_enabled ? 1 : 0
  content              = "${local.new_line}${data.template_file.test_api_stage.rendered}${local.new_line}${data.template_file.publish_api_stage.rendered}"
  directory_permission = "0750"
  file_permission      = "0644"
  filename             = "${var.ci_project_dir}/temp/${local.service_name}.yml"

  provisioner "local-exec" {
    command = "cat ${var.ci_project_dir}/temp/${local.service_name}.yml >> ${var.ci_project_dir}/generated-pipeline.yml"
  }
}
