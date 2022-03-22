module Admin
  module Providers
    module Users
      class ApiKeysController < Admin::BaseController
        skip_after_action :verify_policy_scoped

        def create
          authorize provider

          secret = vault.auth_token.create
          @api_key = Base64.encode64 secret.auth.client_token
          provider.auth_tokens.create!(accessor: secret.auth.accessor)
        end


        def destroy
          authorize provider

          auth_token = provider.auth_tokens.find_by(accessor: params[:id])
          auth_token.destroy
          Vault.auth_token.revoke_accessor(params[:id])

          redirect_to admin_provider_path(provider)
        end

        private

        def provider
          @provider ||= CpdLeadProvider.find(params[:provider_id])
        end

        def api_key_params
          params.require(:admin_providers_api_key).permit(:api_key)
        end

        def vault
          @vault ||= Vault::Client.new(address: ENV['VAULT_ADDR'], token: token)
        end

        def token
          Base64.decode64 api_key_params[:api_key]
        end
      end
    end
  end
end
