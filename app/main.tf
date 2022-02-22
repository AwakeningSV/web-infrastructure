terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"

  backend "azurerm" {
    resource_group_name  = "TerraformState"
    storage_account_name = "awakeningterraform"
    container_name       = "tfstate"
    key                  = "web.tfstate"
    use_microsoft_graph  = true
  }
}

variable "prefix" {
  description = "Prefix for app resources"
  type        = string
}

variable "label" {
  description = "Label inside public DNS names"
  type        = string
  sensitive   = true
}

variable "region" {
  type = string
}

provider "azurerm" {
  features {}
}
