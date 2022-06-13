terraform {
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.46.0"
    }

    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "= 2.20.1"
    }
  }
}
