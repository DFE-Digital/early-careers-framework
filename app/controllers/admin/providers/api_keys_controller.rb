module Admin
  module Providers
    class ApiKeysController < Admin::BaseController
      skip_after_action :verify_policy_scoped
      skip_after_action :verify_authorized

      def create
        authorize provider
        Rails.logger.info { params.inspect }

        service = Admin::Providers::Provider::UpdateKey.new(provider, api_key_form)
        service.call
        @api_key = Base64.encode64(service.token)
      end

      def destroy
        byebug
        authorize provider


        if provider.accessor == params[:id]
           provider.update! accessor: nil
        else
          auth_token = provider.auth_tokens.find_by(accessor: params[:id])
          auth_token.destroy
        end
        Vault.auth_token.revoke_accessor(params[:id])
        redirect_to admin_provider_path(provider)
      end

    private

      def api_key_params
        params.require(:admin_providers_api_key).permit(:use_vault)
      end

      def api_key_form
        @api_key_form ||= Providers::ApiKey.new(api_key_params)
      end

      def provider
        @provider ||= CpdLeadProvider.find(params[:provider_id])
      end
    end
  end
end
