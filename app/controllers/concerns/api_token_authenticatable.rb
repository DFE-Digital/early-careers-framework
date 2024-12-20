# frozen_string_literal: true

module ApiTokenAuthenticatable
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  UNAUTHORIZED_MESSAGE = {
    error: I18n.t(:unauthorized),
  }.to_json.freeze

  included do
    before_action :authenticate
    before_action :check_access_scope
    before_action :set_paper_trail_whodunnit
  end

  def authenticate
    result = authenticate_or_request_with_http_token("Application", UNAUTHORIZED_MESSAGE) do |unhashed_token|
      @current_api_token = supported_api_token_class.find_by_unhashed_token(unhashed_token)
      if @current_api_token
        @current_api_token.update!(
          last_used_at: Time.zone.now,
        )
      end
    end

    if result == UNAUTHORIZED_MESSAGE
      response.content_type = Mime::Type.lookup_by_extension(:json)
    end
  end

  def current_user
    @current_api_token&.owner
  end

private

  # By default all API token types are supported, this method can be overridden on a case by case basis
  # to narrow down who can access different areas of the API
  def supported_api_token_class
    ApiToken
  end

  def current_api_token
    @current_api_token
  end

  def check_access_scope
    head :forbidden unless access_scope.include?(@current_api_token)
  end

  def access_scope
    ApiToken.all
  end
end
