# frozen_string_literal: true

module UserHelper
  def given_i_am_logged_in_as_an_admin
    create(:user, :admin, login_token: "test-token")
    visit "/users/confirm_sign_in?login_token=test-token"
    click_button "Continue"
  end

  def sign_in_as(user)
    token = "test-token-#{Time.zone.now.to_f}"
    user.update!(login_token: token, login_token_valid_until: 1.hour.from_now)
    visit users_confirm_sign_in_path(login_token: token)
    click_button "Continue"
  end

  alias_method :and_i_am_signed_in_as_an_admin, :given_i_am_logged_in_as_an_admin
end
