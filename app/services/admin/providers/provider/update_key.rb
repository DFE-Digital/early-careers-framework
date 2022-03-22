module Admin
  module Providers
    module Provider
      class UpdateKey
        include ActiveModel
        attr_reader :token
        def initialize(provider, api_key_form)
          self.provider = provider
          provider.assign_attributes(api_key_form.serializable_hash(only: :use_vault))
        end

        def call
          return provider if provider.invalid?

          provider.transaction do
            if provider.use_vault?
              secret = Vault.logical.write("secret/data/cpdlp/#{provider.id}/id", data: {cpd_lead_provider_id: provider.id})
              policy = <<-EOH

path "auth/token/create/#{provider.id}" {
  capabilities = ["sudo", "create", "update"]
}

path "auth/token/roles/#{provider.id}" {
  capabilities = ["read"]
}

path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
EOH
              p = Vault.sys.put_policy(provider.id, policy)
              t = Vault.auth_token.create(policies: [provider.id])

              self.token = t.auth.client_token
              provider.update!(accessor: t.auth.accessor)
              provider
            end
            provider.save!
          end
        end
        private

        attr_writer :token
        attr_accessor :provider, :api_key_form
      end
    end
  end
end
