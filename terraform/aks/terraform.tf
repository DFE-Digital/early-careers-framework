terraform {
  required_version = "1.5.4"

  backend "azurerm" {}

  required_providers {
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = ">= 2.0.5"
    }
  }
}
