terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.16.2"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.72.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "vitorrifaneterraformstat"
    container_name       = "remote-state"
    key                  = "pipeline-github/terraform.tfstate"
  }

}


provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      owner      = "vitorrifane"
      managed-by = "terraform"
    }
  }

}

provider "azurerm" {
  features {}

  #Estava dando erro e coloquei esse código
  skip_provider_registration = true
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "vitorrifane-remote-state"
    key    = "aws-vpc/terraform.tfstate"
    region = "eu-central-1"
  }

}

data "terraform_remote_state" "vnet" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "vitorrifaneterraformstat"
    container_name       = "remote-state"
    key                  = "azure-vnet/terraform.tfstate"
  }

}