terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "0e772bc3-0a1a-466f-8d51-4076bdc28134"
  tenant_id       = "1a1680cb-e128-4577-9dbe-9aa330bd7f17"
}

# -------------------------
# Base infra
# -------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-pool"
  location = "Central India" #"Central India"
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

# -------------------------
# User-Assigned Managed Identity + RBAC
# (Pools require UserAssigned identity)
# -------------------------
resource "azurerm_user_assigned_identity" "mdp_uami" {
  name                = "uami-mdp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# Give the UAMI permissions to create/operate the underlying infra (tighten later if desired)
resource "azurerm_role_assignment" "mdp_uami_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mdp_uami.principal_id
}

# -------------------------
# Managed DevOps Pool (public agents; all projects in org)
# -------------------------
resource "azapi_resource" "managed_devops_pool" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
  name      = "SampleDevOpsPool"
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  # Must be UserAssigned (SystemAssigned not supported)
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.mdp_uami.id]
  }

  body = {
    properties = {
      # Link to Azure DevOps org; open to ALL projects
      organizationProfile = {
        kind = "AzureDevOps"
        organizations = [{
          url        = "https://dev.azure.com/3angelsinv"
          openAccess = true
          # projects = []  # (optional) use if you want to restrict to specific projects
        }]
      }

      devCenterProjectResourceId = azurerm_dev_center_project.devproj.id

      # Stateless ephemeral agents; Azure auto-predicts capacity
      agentProfile = {
        kind = "Stateless"
        resourcePredictionsProfile = {
          kind = "Automatic" # Off | Manual | Automatic
        }
      }

      # VM sizing/image (no networkProfile => public agents)
      fabricProfile = {
        kind = "Vmss"
        sku = { name = "Standard_D2s_v5" #"Standard_D2ads_v5" 
        }
        images = [
          { wellKnownImageName = "ubuntu-22.04/latest" }
        ]
      }

      # Cap of concurrent agents provisioned by Azure
      maximumConcurrency = 1
    }
  }

  depends_on = [
    azurerm_dev_center_project.devproj,
    azurerm_role_assignment.mdp_uami_contributor
  ]
}