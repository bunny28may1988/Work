terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.6.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "39ac6650-eb05-4bc6-abb3-5751abf3df0e"
  tenant_id       = "73a4c997-ac5a-4bcd-81f3-fd25589a48b7"
}
resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-pool"
  location = "Central India"
}

resource "azurerm_dev_center" "dc" {
  name                = "dc-devops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_dev_center_project" "devproj" {
  name                = "dcproj-devops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dev_center_id       = azurerm_dev_center.dc.id
}

resource "azurerm_user_assigned_identity" "mdp_uami" {
  name                = "uami-mdp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "mdp_uami_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mdp_uami.principal_id
}

resource "azapi_resource" "managed_devops_pool" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
  name      = "SampleDevOpsPool"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mdp_uami.id]
  }

  body = {
    properties = {
     
      organizationProfile = {
        kind = "AzureDevOps"
        organizations = [{
          url        = "https://dev.azure.com/kmbl-devops"
          openAccess = true
          # projects = []  # (optional) use if you want to restrict to specific projects
        }]
      }

      devCenterProjectResourceId = azurerm_dev_center_project.devproj.id
      agentProfile = {
        kind = "Stateless"
        resourcePredictionsProfile = {
          kind = "Automatic"
        }
      }

      fabricProfile = {
        kind = "Vmss"
        sku = { name = "Standard_D2s_v5"
        }
        images = [
          { wellKnownImageName = "ubuntu-22.04/latest" }
        ]
      }
      maximumConcurrency = 1
    }
  }

  depends_on = [
    azurerm_dev_center_project.devproj,
    azurerm_role_assignment.mdp_uami_contributor
  ]
}
