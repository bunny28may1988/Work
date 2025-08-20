terraform {
  required_version = ">= 1.2.0"
}

# --- inputs ---
variable "ado_org"  { type = string }
variable "ado_pat"  { type = string, sensitive = true }
variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Exact project names to exclude"
}

# Can't use path.module in a variable default, so keep this empty by default …
variable "requirements_path" {
  type        = string
  default     = ""
  description = "Optional path to requirements.txt (absolute or relative). Leave empty to use ${path.module}/requirements.txt"
}

# … and compute the real path here.
locals {
  effective_requirements_path = (
    var.requirements_path != "" ? var.requirements_path : "${path.module}/requirements.txt"
  )
}

# --- create venv & install deps (safe if requirements.txt is empty/missing) ---
resource "null_resource" "venv_setup" {
  triggers = {
    req_hash = fileexists(local.effective_requirements_path)
      ? filesha256(local.effective_requirements_path)
      : ""
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<EOT
      set -e
      cd ${path.module}

      if [ ! -d ".venv" ]; then
        python3 -m venv .venv
      fi

      source .venv/bin/activate
      python -m pip install --upgrade pip

      if [ -s "${local.effective_requirements_path}" ]; then
        pip install -r "${local.effective_requirements_path}"
      fi
    EOT
  }
}

# --- call your Python script via external data source ---
data "external" "ado_projects" {
  depends_on = [null_resource.venv_setup]

  program = [".venv/bin/python", "${path.module}/Proj_List.py"]

  query = {
    org      = var.ado_org
    pat      = var.ado_pat
    excludes = join(",", var.exclude_projects)
  }
}

locals {
  project_names   = tolist(try(data.external.ado_projects.result.projects, []))
  project_objects = [for p in local.project_names : { name = p }]
}

output "project_names"   { value = local.project_names }
output "project_objects" { value = local.project_objects }
