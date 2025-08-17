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

# Minimal networked example (private networking)
module "managed_devops_pool" {
  source = "Azure/avm-res-devopsinfrastructure-pool/azurerm"

  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  name                 = var.pool_name

  # Dev Center Project (can be pre-created or created separately)
  dev_center_project_resource_id = azurerm_dev_center_project.devproj.id

  # Link to your Azure DevOps org/project(s)
  version_control_system_organization_name = var.ado_org_name
  version_control_system_project_names     = [var.ado_project_name]

  # Optional: inject agents into your VNet (else omit for public)
  subnet_id = azurerm_subnet.devops_subnet.id

  # Useful knobs (all optional)
  maximum_concurrency                              = 2
  fabric_profile_sku_name                           = "Standard_D2ads_v5"
  fabric_profile_images = [
    { well_known_image_name = "ubuntu-22.04/latest" }
  ]
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