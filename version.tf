terraform {
  required_version = "~> 1.12.0"
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = "1.10.0"
    }
  }
}

provider "azuredevops" {
  org_service_url       = var.Org_Url
  personal_access_token = var.pat_token
}