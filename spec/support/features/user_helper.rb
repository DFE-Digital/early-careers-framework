# frozen_string_literal: true

module UserHelper
  def given_i_authenticate_as_a_sit_with_the_email(email_address)
    sit_user = User.find_by(email: email_address)
    sign_in_as sit_user
  end
  alias_method :and_i_authenticate_as_a_sit_with_the_email, :given_i_authenticate_as_a_sit_with_the_email

  def given_i_authenticate_as_an_admin
    create(:user, :admin, login_token: "test-admin-token-#{Time.zone.now.to_f}")
    visit "/users/confirm_sign_in?login_token=test-token"
    click_button "Continue"
  end
  alias_method :and_i_authenticate_as_an_admin, :given_i_authenticate_as_an_admin

  def given_i_authenticate_as_a_finance_user
    create(:user, :finance, login_token: "test-finance-token-#{Time.zone.now.to_f}")
    visit "/users/confirm_sign_in?login_token=test-token"
    click_button "Continue"
  end
  alias_method :and_i_authenticate_as_a_finance_user, :given_i_authenticate_as_a_finance_user

  def sign_in_as(user)
    token = "test-user-token-#{Time.zone.now.to_f}"
    user.update!(login_token: token, login_token_valid_until: 1.hour.from_now)
    visit users_confirm_sign_in_path(login_token: token)
    click_button "Continue"
  end

  def sign_out
    visit "/users/sign_out"
  end
end
