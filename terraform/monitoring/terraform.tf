terraform {

  backend "s3" {
    key     = "monitoring/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = "true"
  }
}

provider cloudfoundry {
  api_url           = var.paas_api_url
  password          = var.paas_password
  store_tokens_path = "./tokens"
  user              = var.paas_user
}