# Setup azurerm as a state backend
terraform {
  backend "azurerm" {
    resource_group_name  = "<RESOURCE_GROUP_NAME>"
    storage_account_name = "<STORAGE_ACCOUNT_NAME>" # Provide Storage Account name, where Terraform Remote state is stored
    container_name       = "<CONTAINER_NAME>"
    key                  = "bdcc.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "<SUBSCRIPTION_ID>"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "bdcc" {
  name     = "rg-${var.ENV}-${var.LOCATION}-${random_string.suffix.result}"
  location = var.LOCATION

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}

resource "azurerm_storage_account" "bdcc" {
  depends_on = [
  azurerm_resource_group.bdcc]

  name                     = "st${var.ENV}${var.LOCATION}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.bdcc.name
  location                 = azurerm_resource_group.bdcc.location
  account_tier             = "Standard"
  account_replication_type = var.STORAGE_ACCOUNT_REPLICATION_TYPE
  is_hns_enabled           = "true"

  network_rules {
    default_action = "Allow"
    ip_rules       = values(var.IP_RULES)
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gen2_data" {
  depends_on = [
  azurerm_storage_account.bdcc]

  name               = "data"
  storage_account_id = azurerm_storage_account.bdcc.id

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_databricks_workspace" "bdcc" {
  depends_on = [
    azurerm_resource_group.bdcc
  ]

  name                = "dbw-${var.ENV}-${var.LOCATION}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.bdcc.name
  location            = azurerm_resource_group.bdcc.location
  sku                 = "standard"

  tags = {
    region = var.BDCC_REGION
    env    = var.ENV
  }
}
