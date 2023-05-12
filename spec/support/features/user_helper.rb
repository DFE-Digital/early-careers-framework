# frozen_string_literal: true

module UserHelper
  def given_i_sign_in_as_the_user_with_the_full_name(full_name)
    user = User.find_by(full_name:)
    sign_in_as user
  end
  alias_method :and_i_sign_in_as_the_user_with_the_full_name, :given_i_sign_in_as_the_user_with_the_full_name
  alias_method :when_i_sign_in_as_the_user_with_the_full_name, :given_i_sign_in_as_the_user_with_the_full_name

  def given_i_sign_in_as_the_user_with_the_email(email_address)
    user = User.find_by(email: email_address)
    sign_in_as user
  end
  alias_method :and_i_sign_in_as_the_user_with_the_email, :given_i_sign_in_as_the_user_with_the_email
  alias_method :when_i_sign_in_as_the_user_with_the_email, :given_i_sign_in_as_the_user_with_the_email

  def given_i_sign_in_as_an_admin_user
    token = "test-admin-token-#{Time.zone.now.to_f}"

    @logged_in_admin_user = create :user,
                                   :admin,
                                   login_token: token

    visit users_confirm_sign_in_path(login_token: token)
    click_button "Continue"
  end
  alias_method :and_i_sign_in_as_an_admin_user, :given_i_sign_in_as_an_admin_user
  alias_method :when_i_sign_in_as_an_admin_user, :given_i_sign_in_as_an_admin_user
  alias_method :given_i_am_logged_in_as_an_admin_user, :given_i_sign_in_as_an_admin_user
  alias_method :and_i_am_signed_in_as_an_admin, :given_i_sign_in_as_an_admin_user

  def given_i_sign_in_as_a_super_user_admin
    @logged_in_admin_user = FactoryBot.create(:admin_profile, super_user: true).user

    visit users_confirm_sign_in_path(login_token: @logged_in_admin_user.login_token)
    click_button "Continue"
  end

  def given_i_sign_in_as_a_finance_user
    token = "test-finance-token-#{Time.zone.now.to_f}"
    create :user,
           :finance,
           login_token: token

    visit users_confirm_sign_in_path(login_token: token)
    click_button "Continue"
  end
  alias_method :and_i_sign_in_as_a_finance_user, :given_i_sign_in_as_a_finance_user
  alias_method :when_i_sign_in_as_a_finance_user, :given_i_sign_in_as_a_finance_user
  alias_method :given_i_am_logged_in_as_a_finance_user, :given_i_sign_in_as_a_finance_user

  def sign_in_as(user)
    token = "test-user-token-#{Time.zone.now.to_f}"
    user.update! login_token: token,
                 login_token_valid_until: 12.hours.from_now

    visit users_confirm_sign_in_path(login_token: token)
    click_button "Continue"
  end

  def sign_out
    visit "/users/sign_out"
  end
end
