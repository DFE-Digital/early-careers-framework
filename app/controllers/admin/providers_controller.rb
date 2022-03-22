module Admin
  class ProvidersController < Admin::BaseController
    skip_after_action :verify_policy_scoped, only: :show

    def show
      @provider = CpdLeadProvider.find(params[:id])
      authorize @provider

      @api_key_form = Providers::ApiKey.from(@provider)

      @auth_tokens = @provider.auth_tokens
    end
  end
end
