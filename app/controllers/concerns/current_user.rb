# frozen_string_literal: true

module CurrentUser
  extend ActiveSupport::Concern

  prepended do
    helper_method :current_user
    helper_method :user_signed_in?
  end

  def current_user
    current_user_identity&.user
  end

  def user_signed_in?
    user_identity_signed_in?
  end

  def authenticate_user!
    authenticate_user_identity!
  end
end
