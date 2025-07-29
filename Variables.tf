variable "Org_Url" {
  description = "Azure DevOps Personal Access Token (PAT)"
  type        = string
  default     = "https://dev.azure.com/3angelsinv"
}

variable "pat_token" {
  description = "Azure DevOps Personal Access Token (PAT)"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Name of the Azure DevOps project to be created"
  type        = string
  default     = "TestAdoAutomationProject"
}

variable "project_description" {
  description = "Description of the ADO project"
  type        = string
  default     = "Project created and initialized by Terraform"
}

variable "project_visibility" {
  description = "Visibility of the ADO project (private or public)"
  type        = string
  default     = "private"
}

variable "version_control" {
  description = "Version control system for the project repository"
  type        = string
  default     = "Git"
}

variable "work_item_template" {
  description = "Work item process template (Agile, Scrum, CMMI)"
  type        = string
  default     = "Agile"
}

variable "Custom_repo" {
  description = "Name of the Custom Git repository"
  type        = string
  default     = "InitialRepo"
}