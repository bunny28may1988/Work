terraform {
  required_version = "~> 1.12.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}

# ---- Inputs ----
variable "ado_org" {
  type        = string
  description = "ADO org short name (e.g., kmbl-devops)"
}

variable "ado_pat" {
  type        = string
  sensitive   = true
  description = "Azure DevOps PAT with Org scope (Project & Team: Read)"
}

# Optional: names to exclude (exact, case-sensitive)
variable "exclude_projects" {
  type        = list(string)
  default     = []
  description = "Project names to exclude from the output"
}

# ---- External data: run the bash script ----
# The script prints JSON: {"projects":["ProjA","ProjB",...]}
data "external" "ado_projects" {
  program = ["bash", "${path.module}/scripts/EProjList.sh"]

  # Pass inputs via environment (matches how your script reads them)
  environment = {
    ORG     = var.ado_org
    ADO_PAT = var.ado_pat
    EXCLUDE = join(",", var.exclude_projects) # script splits on commas
  }
}

# ---- Locals from the data source ----
locals {
  project_names = tolist(try(data.external.ado_projects.result.projects, []))
  # If you need name objects later:
  project_objects = [for p in local.project_names : { name = p }]
}

# ---- Outputs ----
output "project_names" {
  value       = local.project_names
  description = "List of ADO project names (after exclusions handled by the script)."
}

output "project_objects" {
  value       = local.project_objects
  description = "Same list but as objects { name = <project> }."
}
