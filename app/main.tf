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

module "staging_web" {
  source = "./webserver"

  prefix = var.prefix
  label  = var.label
  region = var.region
  env    = "staging"
}

module "production_web" {
  source = "./webserver"

  prefix = var.prefix
  label  = var.label
  region = var.region
  env    = "production"
}

output "staging_fqdn" {
  description = "Public FQDN for staging webserver"
  value       = module.staging_web.fqdn
  sensitive   = true
}

output "production_fqdn" {
  description = "Public FQDN for production webserver"
  value       = module.production_web.fqdn
  sensitive   = true
}