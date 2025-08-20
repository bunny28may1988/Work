terraform {
  required_version = ">= 1.5"
}

# ---- Inputs ----
variable "ado_org" {
  type        = string
  description = "ADO org short name (e.g., kmbl-devops)"
}

variable "ado_pat" {
  type        = string
  sensitive   = true
  description = "Azure DevOps PAT with Project & Team: Read"
}

# ---- External data: run your bash script ----
# The script must print JSON like: {"projects":["ProjA","ProjB",...]}
data "external" "ado_projects" {
  program = ["bash", "${path.module}/scripts/ProjectsList.sh"]

  # stdin to the script (your script should read this JSON)
  query = {
    org = var.ado_org
    pat = var.ado_pat
  }
}

# ---- Locals from the data source ----
locals {
  # raw array as returned by the script
  project_names = tolist(try(data.external.ado_projects.result.projects, []))

  # (optional) transform into objects { name = "..." } if you need that shape later
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
