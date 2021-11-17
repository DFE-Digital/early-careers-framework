# frozen_string_literal: true

module SchoolAccessTokenConsumer
  extend ActiveSupport::Concern

  included do
    before_action :store_token
  end

private

  def store_token
    session[:access_token] = params[:token] if params[:token]
  end

  def access_token
    @access_token ||= SchoolAccessToken.find_by(token: session[:access_token])
  end

  def require_access_token!(action)
    return if access_token.permits?(action)

    raise Pundit::NotAuthorizedError, "Access token does not permit #{action}"
  end

  # def record_nomination_email_opened
  #   NominationEmail
  #     .where(token: nomination_email.token, opened_at: nil)
  #     .update_all(opened_at: Time.zone.now)
  # end
end
