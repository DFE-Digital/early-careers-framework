# frozen_string_literal: true

module LeadProviderAuthenticatable
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  included do
    before_action :authenticate
  end

  def authenticate
    authenticate_or_request_with_http_token do |unhashed_token|
      @current_lead_provider_api_token = LeadProviderApiToken.find_by_unhashed_token(unhashed_token)
      if @current_lead_provider_api_token
        @current_lead_provider_api_token.update!(
          last_used_at: Time.zone.now,
        )
      end
    end
  end

  def current_lead_provider
    @current_lead_provider ||= @current_lead_provider_api_token&.lead_provider
  end
end
