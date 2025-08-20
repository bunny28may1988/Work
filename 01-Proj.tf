terraform {
  required_version = ">= 1.6"
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

# ---------- Inputs ----------
variable "ado_org" {
  type        = string
  description = "ADO org short name (e.g., kmbl-devops)"
}

variable "ado_pat" {
  type        = string
  sensitive   = true
  description = "Azure DevOps PAT (Org scope: Project & Team -> Read)"
}

variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Exact project names to exclude (case-sensitive)."
}

# ---------- Locals ----------
locals {
  venv_dir                     = "${path.module}/.venv"
  script_path                  = "${path.module}/scripts/proj_list.py"
  effective_requirements_path  = "${path.module}/requirements.txt"

  # compute a stable hash for triggers; if file missing, use sentinel
  requirements_hash = fileexists(local.effective_requirements_path)
    ? filesha256(local.effective_requirements_path)
    : "no-file"

  # external data source accepts only strings; pass excludes as CSV
  exclude_csv = join(",", var.exclude_projects)
}

# ---------- Create / update the venv and pip install ----------
resource "null_resource" "venv_setup" {
  triggers = {
    req_hash = local.requirements_hash
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
      set -e
      cd ${path.module}

      # Create venv if not present
      if [ ! -d "${local.venv_dir}" ]; then
        python3 -m venv "${local.venv_dir}"
      fi

      # Activate + upgrade pip
      source "${local.venv_dir}/bin/activate"
      python -m pip install --upgrade pip

      # Install requirements if file exists and is non-empty
      if [ -s "${local.effective_requirements_path}" ]; then
        pip install -r "${local.effective_requirements_path}"
      fi
    EOT
  }
}

# ---------- Run the Python script and capture results ----------
data "external" "ado_projects" {
  depends_on = [null_resource.venv_setup]

  # Run the script using the venv's python
  program = ["bash", "-lc", "${local.venv_dir}/bin/python ${local.script_path}"]

  # external only accepts strings in 'query'
  query = {
    org     = var.ado_org
    pat     = var.ado_pat
    exclude = local.exclude_csv
  }
}

# ---------- Make results easy to use ----------
locals {
  project_names   = tolist(try(data.external.ado_projects.result.projects, []))
  project_objects = [for p in local.project_names : { name = p }]
}

# ---------- Outputs ----------
output "project_names" {
  value       = local.project_names
  description = "List of ADO project names after exclusions."
}

output "project_objects" {
  value       = local.project_objects
  description = "Same, but as objects { name = <project> }."
}
