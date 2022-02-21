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
    key                  = "terraform.tfstate"
    use_microsoft_graph  = true
  }
}

variable "prefix" {
  description = "Prefix for app resources"
  type = string
}

variable "label" {
  description = "Label prefix for public DNS names"
  type = string
  sensitive = true
}

provider "azurerm" {
  features {}
}
