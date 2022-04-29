# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Cookie policy page", type: :feature, js: true do
  # All ECF users need to be able to set and modify their cookie preferences

  scenario "Cookie policy is accessible" do
    given_i_am_on_the_cookie_policy_page

    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Cookie policy page"
  end

  scenario "Reading the cookie policy" do
    given_i_am_on_the_start_page
    when_i_view_the_cookie_policy
    then_i_am_on_the_cookie_policy_page
  end

  scenario "Returning from the cookie policy" do
    given_i_am_on_the_start_page
    and_i_view_the_cookie_policy
    when_i_go_back
    then_i_am_on_the_start_page
  end

  scenario "Default cookie preferences" do
    given_i_am_on_the_start_page
    when_i_view_the_cookie_policy
    then_cookie_consent_is_not_given
  end

  scenario "Consenting to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_give_cookie_consent

    then_cookie_preferences_have_changed
    and_cookie_consent_is_given
    and_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Cookie consent page"
  end

  scenario "Not consenting to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_revoke_cookie_consent

    then_cookie_preferences_have_changed
    and_cookie_consent_is_not_given
    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Cookie dissent page"
  end

  scenario "Changing consent to the cookie policy" do
    given_i_am_on_the_cookie_policy_page

    when_i_give_cookie_consent

    then_cookie_preferences_have_changed
    and_cookie_consent_is_given

    when_i_revoke_cookie_consent

    then_cookie_preferences_have_changed
    and_cookie_consent_is_not_given
  end

private

  def when_i_view_the_cookie_policy
    page_object = Pages::StartPage.loaded
    page_object.view_cookie_policy
  end
  alias_method :and_i_view_the_cookie_policy, :when_i_view_the_cookie_policy

  def when_i_go_back
    page_object = Pages::CookiePolicyPage.loaded
    page_object.go_back
  end

  def then_cookie_consent_is_not_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_not_given?
  end
  alias_method :and_cookie_consent_is_not_given, :then_cookie_consent_is_not_given

  def then_cookie_consent_is_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_given?
  end
  alias_method :and_cookie_consent_is_given, :then_cookie_consent_is_given

  def when_i_give_cookie_consent
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.give_consent
  end
  alias_method :and_i_give_cookie_consent, :when_i_give_cookie_consent

  def when_i_revoke_cookie_consent
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.revoke_consent
  end
  alias_method :and_i_revoke_cookie_consent, :when_i_revoke_cookie_consent

  def then_cookie_preferences_have_changed
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.preferences_have_changed?
  end
  alias_method :and_cookie_preferences_have_changed, :then_cookie_preferences_have_changed
end

RSpec.feature "Cookie banner without JavaScript", type: :feature, js: false do
  scenario "Cookie banner is visible" do
    given_i_am_on_the_start_page

    then_the_cookie_banner_is_displayed
  end

  scenario "Accepting cookies" do
    given_i_am_on_the_start_page

    when_i_accept_cookies

    then_i_am_on_the_cookie_policy_page
    and_cookie_preferences_have_changed
  end

  scenario "Rejecting cookies" do
    given_i_am_on_the_start_page

    when_i_reject_cookies

    then_i_am_on_the_cookie_policy_page
    and_cookie_preferences_have_changed
  end

  scenario "Viewing preferences after accepting cookies" do
    given_i_am_on_the_start_page
    and_i_accept_cookies

    when_i_am_on_the_cookie_policy_page

    then_cookie_consent_is_given
  end

  scenario "Viewing preferences after rejecting cookies" do
    given_i_am_on_the_start_page
    and_i_reject_cookies

    when_i_am_on_the_cookie_policy_page

    then_cookie_consent_is_not_given
  end

private

  def when_i_accept_cookies
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.accept
  end
  alias_method :and_i_accept_cookies, :when_i_accept_cookies

  def when_i_reject_cookies
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.reject
  end
  alias_method :and_i_reject_cookies, :when_i_reject_cookies

  def then_cookie_preferences_have_changed
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.preferences_have_changed?
  end
  alias_method :and_cookie_preferences_have_changed, :then_cookie_preferences_have_changed

  def then_cookie_consent_is_not_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_not_given?
  end
  alias_method :and_cookie_consent_is_not_given, :then_cookie_consent_is_not_given

  def then_cookie_consent_is_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_given?
  end
  alias_method :and_cookie_consent_is_given, :then_cookie_consent_is_given

  def then_the_cookie_banner_is_displayed
    page_object = Pages::StartPage.loaded
    expect(page_object.cookie_banner).to be_visible
  end
end

RSpec.feature "Cookie banner with JavaScript", type: :feature, js: true do
  scenario "Cookie banner is visible" do
    given_i_am_on_the_start_page

    then_the_cookie_banner_is_displayed
  end

  scenario "Accepting cookies" do
    given_i_am_on_the_start_page

    when_i_accept_cookies

    then_i_am_on_the_start_page
    and_cookie_preferences_have_changed
  end
  scenario "Rejecting cookies" do
    given_i_am_on_the_start_page

    when_i_reject_cookies

    then_i_am_on_the_start_page
    and_cookie_preferences_have_changed
  end

  scenario "Viewing preferences after accepting cookies" do
    given_i_am_on_the_start_page
    and_i_accept_cookies

    when_i_am_on_the_cookie_policy_page

    then_cookie_consent_is_given
  end

  scenario "Viewing preferences after rejecting cookies" do
    given_i_am_on_the_start_page
    and_i_reject_cookies

    when_i_am_on_the_cookie_policy_page

    then_cookie_consent_is_not_given
  end

  scenario "Hiding the cookie banner after accepting" do
    given_i_am_on_the_start_page
    and_i_accept_cookies

    when_i_hide_the_success_message

    then_the_cookie_banner_is_not_displayed
  end

  scenario "Hiding the cookie banner after rejecting" do
    given_i_am_on_the_start_page
    and_i_reject_cookies

    when_i_hide_the_success_message

    then_the_cookie_banner_is_not_displayed
  end

  scenario "Changing preferences after accepting" do
    given_i_am_on_the_start_page
    and_i_accept_cookies

    when_i_want_to_change_preferences

    then_i_am_on_the_cookie_policy_page
    and_cookie_consent_is_given
  end

  scenario "Changing preferences after rejecting" do
    given_i_am_on_the_start_page
    and_i_reject_cookies

    when_i_want_to_change_preferences

    then_i_am_on_the_cookie_policy_page
    and_cookie_consent_is_not_given
  end

private

  def when_i_accept_cookies
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.accept
  end
  alias_method :and_i_accept_cookies, :when_i_accept_cookies

  def when_i_reject_cookies
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.reject
  end
  alias_method :and_i_reject_cookies, :when_i_reject_cookies

  def when_i_hide_the_success_message
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.hide_success_message
  end

  def when_i_want_to_change_preferences
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.change_preferences
  end

  def then_cookie_preferences_have_changed
    page_object = Pages::StartPage.loaded
    page_object.cookie_banner.preferences_have_changed?
  end
  alias_method :and_cookie_preferences_have_changed, :then_cookie_preferences_have_changed

  def then_cookie_consent_is_not_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_not_given?
  end
  alias_method :and_cookie_consent_is_not_given, :then_cookie_consent_is_not_given

  def then_cookie_consent_is_given
    page_object = Pages::CookiePolicyPage.loaded
    page_object.cookie_consent_form.consent_given?
  end
  alias_method :and_cookie_consent_is_given, :then_cookie_consent_is_given

  def then_the_cookie_banner_is_not_displayed
    page_object = Pages::StartPage.loaded
    expect(page_object.cookie_banner).to_not be_visible
  end

  def then_the_cookie_banner_is_displayed
    page_object = Pages::StartPage.loaded
    expect(page_object.cookie_banner).to be_visible
  end
end
