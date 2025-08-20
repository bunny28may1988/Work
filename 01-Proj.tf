terraform {
  required_version = "~> 1.12.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

# ----------------------------
# Variables
# ----------------------------
variable "ado_org" {
  type        = string
  description = "Azure DevOps org short name (e.g., kmbl-devops)"
}

variable "ado_pat" {
  type        = string
  sensitive   = true
  description = "Azure DevOps PAT with Org scope: Project & Team (Read)"
}

# Optional: exact project names to exclude
variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Project names to exclude (exact, case-sensitive)"
}

# Where your requirements live (can be empty)
variable "requirements_path" {
  type        = string
  default     = "${path.module}/requirements.txt"
  description = "Path to requirements.txt (can be empty)"
}

# ----------------------------
# Build the venv & install deps (idempotent)
# Re-runs when requirements.txt content changes
# ----------------------------
resource "null_resource" "python_venv" {
  triggers = {
    req_hash = fileexists(var.requirements_path) ? filesha256(var.requirements_path) : ""
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-lc"]
    command = <<-EOT
      set -e
      cd ${path.module}

      # Create venv if missing
      if [ ! -d ".venv" ]; then
        python3 -m venv .venv
      fi

      # Activate and install requirements (ok if file empty)
      source .venv/bin/activate
      python -m pip install --upgrade pip
      if [ -f "${var.requirements_path}" ]; then
        # If file exists but is empty, pip exits 0 anyway
        pip install -r "${var.requirements_path}"
      fi
    EOT
  }
}

# ----------------------------
# External data: call the Python helper in the venv
# The script must read JSON from stdin and print:
#   {"projects": ["Proj A", "Proj B", ...]}
# ----------------------------
data "external" "ado_projects" {
  program = [
    "${path.module}/.venv/bin/python",
    "${path.module}/project_list.py"
  ]

  # external.query values must be strings; pass exclude list as JSON string
  query = {
    org     = var.ado_org
    pat     = var.ado_pat
    exclude = jsonencode(var.exclude_projects)
  }

  depends_on = [null_resource.python_venv]
}

# ----------------------------
# Locals & Outputs
# ----------------------------
locals {
  project_names   = tolist(try(data.external.ado_projects.result.projects, []))
  project_objects = [for p in local.project_names : { name = p }]
}

output "project_names" {
  value       = local.project_names
  description = "List of ADO projects after exclusions."
}

output "project_objects" {
  value       = local.project_objects
  description = "Projects as objects { name = <project> }."
}
