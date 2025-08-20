terraform {
  required_version = ">= 1.0.0"
}

# ------------ Variables ------------
variable "ado_org" {
  type        = string
  description = "ADO org short name (e.g., kmbl-devops)"
}

variable "ado_pat" {
  type        = string
  sensitive   = true
  description = "Azure DevOps PAT with Project & Team: Read"
}

variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Exact project names to exclude (case-sensitive)."
}

# ------------ Locals ------------
locals {
  venv_dir        = "${path.module}/.venv"
  script_path     = "${path.module}/scripts/proj_list.py"
  requirements    = "${path.module}/requirements.txt"

  # hash changes when requirements.txt changes
  requirements_hash = fileexists(local.requirements) ? filesha256(local.requirements) : "no-file"

  # external data source accepts only strings
  exclude_csv = join(",", var.exclude_projects)
}

# ------------ Create venv & install requirements ------------
resource "null_resource" "venv_setup" {
  triggers = {
    req_hash = local.requirements_hash
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
      set -e
      cd ${path.module}

      # Create venv if missing
      if [ ! -d "${local.venv_dir}" ]; then
        python3 -m venv "${local.venv_dir}"
      fi

      # Activate venv
      source "${local.venv_dir}/bin/activate"

      # Upgrade pip
      python -m pip install --upgrade pip

      # Install requirements if file exists
      if [ -f "${local.requirements}" ]; then
        pip install -r "${local.requirements}"
      fi
    EOT
  }
}

# ------------ External Data Source (Python script) ------------
data "external" "ado_projects" {
  program = ["${local.venv_dir}/bin/python", local.script_path]

  query = {
    org      = var.ado_org
    pat      = var.ado_pat
    excludes = local.exclude_csv
  }

  depends_on = [null_resource.venv_setup]
}

# ------------ Locals from Python output ------------
locals {
  project_names   = tolist(try(jsondecode(data.external.ado_projects.result.projects_json), []))
  project_objects = [for p in local.project_names : { name = p }]
}

output "project_names"   { value = local.project_names }
output "project_objects" { value = local.project_objects }
