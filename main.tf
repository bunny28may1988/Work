resource "azuredevops_project" "ado_project" {
  name               = var.project_name
  description        = var.project_description
  visibility         = var.project_visibility
  version_control    = var.version_control
  work_item_template = var.work_item_template
}

resource "null_resource" "init_default_repo" {
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    environment = {
      ADO_PAT      = var.pat_token
      PROJECT_NAME = var.project_name
    }

    command = <<EOT
set -e
[ -d temp-repo ] && rm -rf temp-repo
mkdir temp-repo
cd temp-repo
git init
echo "# Initialized via Terraform" > README.md
git config user.name "Terraform"
git config user.email "terraform@kotak.com"
git add README.md
git commit -m "Initial commit"
git branch -M main
git remote add origin https://$ADO_PAT@dev.azure.com/3angelsinv/$PROJECT_NAME/_git/$PROJECT_NAME
git push --set-upstream origin main
cd ..
[ -d temp-repo ] && rm -rf temp-repo
EOT
  }

  depends_on = [azuredevops_project.ado_project]
}