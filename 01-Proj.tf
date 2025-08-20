terraform {
  required_version = ">= 1.5.0"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

variable "ado_org" { type = string }
variable "ado_pat" { type = string, sensitive = true }
variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Exact project names to exclude"
}
variable "requirements_path" {
  type        = string
  default     = "${path.module}/requirements.txt"
}

resource "null_resource" "python_venv" {
  triggers = {
    req_hash = fileexists(var.requirements_path) ? filesha256(var.requirements_path) : ""
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<-EOT
      set -e
      cd ${path.module}
      if [ ! -d ".venv" ]; then
        python3 -m venv .venv
      fi
      source .venv/bin/activate
      python -m pip install --upgrade pip
      if [ -f "${var.requirements_path}" ]; then
        # empty file is fine; pip exits 0
        pip install -r "${var.requirements_path}"
      fi
    EOT
  }
}

data "external" "ado_projects" {
  program = [
    "${path.module}/.venv/bin/python",
    "${path.module}/scripts/project_list.py"
  ]
  query = {
    org     = var.ado_org
    pat     = var.ado_pat
    exclude = jsonencode(var.exclude_projects)
  }
  depends_on = [null_resource.python_venv]
}

locals {
  project_names   = tolist(try(data.external.ado_projects.result.projects, []))
  project_objects = [for p in local.project_names : { name = p }]
}

output "project_names"   { value = local.project_names }
output "project_objects" { value = local.project_objects }
