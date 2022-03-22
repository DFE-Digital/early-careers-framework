Vault.configure do |config|
  # The address of the Vault server, also read as ENV["VAULT_ADDR"]
  config.address = "http://127.0.0.1:8200"

  # The token to authenticate with Vault, also read as ENV["VAULT_TOKEN"]
  config.token = "dev-only-token"
  # Optional - if using the Namespace enterprise feature
  # config.namespace   = "my-namespace" # Also reads from ENV["VAULT_NAMESPACE"]

  # Proxy connection information, also read as ENV["VAULT_PROXY_(thing)"]
  # config.proxy_address  = "..."
  # config.proxy_port     = "..."
  # config.proxy_username = "..."
  # config.proxy_password = "..."

  # Custom SSL PEM, also read as ENV["VAULT_SSL_CERT"]
  # config.ssl_pem_file = "/path/on/disk.pem"

  # As an alternative to a pem file, you can provide the raw PEM string, also read in the following order of preference:
  # ENV["VAULT_SSL_PEM_CONTENTS_BASE64"] then ENV["VAULT_SSL_PEM_CONTENTS"]
  # config.ssl_pem_contents = "-----BEGIN ENCRYPTED..."

  # Use SSL verification, also read as ENV["VAULT_SSL_VERIFY"]
  config.ssl_verify = false

  # Timeout the connection after a certain amount of time (seconds), also read
  # as ENV["VAULT_TIMEOUT"]
  config.timeout = 30

  # It is also possible to have finer-grained controls over the timeouts, these
  # may also be read as environment variables
  config.ssl_timeout  = 5
  config.open_timeout = 5
  config.read_timeout = 30
end
