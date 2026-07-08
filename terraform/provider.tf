terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Remote backend (Azure Storage) is used in production for state
  # storage and locking. Left commented out here for local validation,
  # since it requires an existing Storage Account and Azure login.
  #
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstatedevopsassess"
  #   container_name       = "tfstate"
  #   key                  = "devops-assessment.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
