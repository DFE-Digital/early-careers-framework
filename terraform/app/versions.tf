terraform {
  required_version = ">= 0.13.1"

  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.13.0"
    }
    statuscake = {
      source  = "StatusCakeDev/statuscake"
      version = "~> 1.0.1"
    }
  }
}
