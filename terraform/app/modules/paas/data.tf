data cloudfoundry_org org {
  name = "dfe-ecf"
}

data cloudfoundry_space space {
  name = var.space_name
  org  = data.cloudfoundry_org.org.id
}

data cloudfoundry_domain cloudapps_digital {
  name = "london.cloudapps.digital"
}


data cloudfoundry_service postgres {
  name = "postgres"
}
