data "azuredevops_project" "project" {
  name = var.project_name
}

resource "azuredevops_git_repository" "repo" {
  project_id = data.azuredevops_project.project.id
  name       = var.Custom_repo
  initialization {
    init_type = "Clean"
  }
  default_branch = "refs/heads/main"
}