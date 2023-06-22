terraform {
  required_version = "1.5.1"

  backend "azurerm" {}

  required_providers {
    # statuscake = {
    #   source = "StatusCakeDev/statuscake"
    # }
  }
}
