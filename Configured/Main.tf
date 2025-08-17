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
  subscription_id = var.subscription_id
}

resource "azapi_resource" "managed_devops_pool" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-01-21"
  name      = var.pool_name
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      versionControlSystem = {
        type            = "azuredevops"
        organization    = var.ado_org_name
        projectNames    = [var.ado_project_name]
      }
      devCenterProjectResourceId = azurerm_dev_center_project.devproj.id
      agentProfile = {
        kind                         = "Stateless"
        resourcePredictionsProfile   = { kind = "Off" } # Off | Manual | Automatic
        maxAgentLifetime             = null             # e.g., "1.00:00:00" (1 day)
        gracePeriodTimeSpan          = null             # e.g., "0.12:00:00" (12 hours)
      }
      fabricProfile = {
        skuName = "Standard_D2ads_v5"
        images  = [
          { wellKnownImageName = "ubuntu-22.04/latest" }
        ]
        # For private networking, include:
        networkProfile = {
          subnetId = azurerm_subnet.devops_subnet.id
        }
      }
      maximumConcurrency = 2
    }
  }
}


resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-pool"
  location = "uksouth"
}

# Example Dev Center + Project (if you don’t already have one)
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

# Example VNet/subnet for private networking (optional)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.20.0.0/16"]
}

resource "azurerm_subnet" "devops_subnet" {
  name                 = "snet-devops"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.20.1.0/24"]

  # Required: delegate to Managed DevOps Pools
  delegation {
    name = "mdp-delegation"
    service_delegation {
      name = "Microsoft.DevOpsInfrastructure/pools"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}