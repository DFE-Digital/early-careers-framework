# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Cookie policy page", type: :feature, js: true do
  # All ECF users need to be able to set and modify their cookie preferences

  scenario "Cookie policy is accessible" do
    given_i_am_on_the_cookie_policy_page

    then_the_page_is_accessible
  end

  scenario "Reading the cookie policy" do
    given_i_am_on_the_start_page
    when_i_view_cookie_policy_from_the_start_page
    then_i_am_on_the_cookie_policy_page
  end

  scenario "Returning from the cookie policy" do
    given_i_am_on_the_start_page
    when_i_view_cookie_policy_from_the_start_page
    when_i_go_back_from_the_cookie_policy_page
    then_i_am_on_the_start_page
  end

  scenario "Default cookie preferences" do
    given_i_am_on_the_start_page
    when_i_view_cookie_policy_from_the_start_page
    then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
  end

  scenario "Consenting to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_give_cookie_consent_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
    and_the_page_is_accessible
  end

  scenario "Not consenting to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_revoke_cookie_consent_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
    then_the_page_is_accessible
  end

  scenario "Changing consent to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_give_cookie_consent_on_the_cookie_policy_page
    and_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
    and_i_revoke_cookie_consent_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
  end
end

RSpec.feature "Cookie banner without JavaScript", type: :feature, js: false do
  scenario "Cookie banner is visible" do
    given_i_am_on_the_start_page

    then_i_confirm_cookie_banner_displayed_on_the_start_page
  end

  scenario "Accepting cookies" do
    given_i_am_on_the_start_page

    when_i_accept_cookies_on_the_start_page

    then_i_am_on_the_cookie_policy_page
    and_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
  end

  scenario "Rejecting cookies" do
    given_i_am_on_the_start_page

    when_i_reject_cookies_on_the_start_page

    then_i_am_on_the_cookie_policy_page
    and_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
  end

  scenario "Viewing preferences after accepting cookies" do
    given_i_am_on_the_start_page

    when_i_accept_cookies_on_the_start_page
    and_i_am_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
  end

  scenario "Viewing preferences after rejecting cookies" do
    given_i_am_on_the_start_page

    when_i_reject_cookies_on_the_start_page
    and_i_am_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
  end
end

RSpec.feature "Cookie banner with JavaScript", type: :feature, js: true do
  scenario "Cookie banner is visible" do
    given_i_am_on_the_start_page

    then_i_confirm_cookie_banner_displayed_on_the_start_page
  end

  scenario "Accepting cookies" do
    given_i_am_on_the_start_page

    when_i_accept_cookies_on_the_start_page

    then_i_am_on_the_start_page
    and_i_confirm_cookie_preferences_accepted_on_the_start_page
  end
  scenario "Rejecting cookies" do
    given_i_am_on_the_start_page

    when_i_reject_cookies_on_the_start_page

    then_i_am_on_the_start_page
    and_i_confirm_cookie_preferences_rejected_on_the_start_page
  end

  scenario "Viewing preferences after accepting cookies" do
    given_i_am_on_the_start_page
    and_i_accept_cookies_on_the_start_page

    when_i_am_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
  end

  scenario "Viewing preferences after rejecting cookies" do
    given_i_am_on_the_start_page
    and_i_reject_cookies_on_the_start_page

    when_i_am_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
  end

  scenario "Hiding the cookie banner after accepting" do
    given_i_am_on_the_start_page
    and_i_accept_cookies_on_the_start_page

    when_i_hide_success_message_on_the_start_page

    then_i_confirm_cookie_banner_not_displayed_on_the_start_page
  end

  scenario "Hiding the cookie banner after rejecting" do
    given_i_am_on_the_start_page
    and_i_reject_cookies_on_the_start_page

    when_i_hide_success_message_on_the_start_page

    then_i_confirm_cookie_banner_not_displayed_on_the_start_page
  end

  scenario "Changing preferences after accepting" do
    given_i_am_on_the_start_page
    and_i_accept_cookies_on_the_start_page

    when_i_am_on_the_cookie_policy_page
    and_i_revoke_cookie_consent_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_not_given_on_the_cookie_policy_page
  end

  scenario "Changing preferences after rejecting" do
    given_i_am_on_the_start_page
    and_i_reject_cookies_on_the_start_page

    when_i_am_on_the_cookie_policy_page
    and_i_give_cookie_consent_on_the_cookie_policy_page

    then_i_confirm_cookie_consent_is_given_on_the_cookie_policy_page
  end
end
