# frozen_string_literal: true

module ApiTokenAuthenticatable
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  included do
    before_action :authenticate
    before_action :check_access_scope
  end

  def authenticate
    authenticate_or_request_with_http_token do |unhashed_token|
      @current_api_token = ApiToken.find_by_unhashed_token(unhashed_token)
      if @current_api_token
        @current_api_token.update!(
          last_used_at: Time.zone.now,
        )
      end
    end
  end

  def current_user
    @current_api_token.owner
  end

private

  def check_access_scope
    head :forbidden unless access_scope.include?(@current_api_token)
  end

  def access_scope
    ApiToken.all
  end
end
