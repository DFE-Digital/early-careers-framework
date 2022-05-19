# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Reporting an error with a partnership", type: :feature, js: true, rutabaga: false do
  let!(:cohort) { create :cohort, start_year: 2021 }

  let!(:privacy_policy) do
    create :privacy_policy
    PrivacyPolicy::Publish.call
  end

  describe "when using an email link" do
    scenario "Can see challenge options from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_page_with_token "abc1234"
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge options"
    end

    scenario "Can challenge a partnership from an email link" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_use_the_report_incorrect_partnership_token "abc1234"
      and_i_am_on_the_report_incorrect_partnership_page_with_token "abc1234"

      when_i_report_a_mistake_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge success"
    end

    scenario "Cannot challenge a partnership twice from an email link" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_already_challenged_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "already challenged"
    end

    scenario "Cannot challenge an expired challenge from an email link" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge "test-sit@example.com", "Test school", "111111-test-school", "abc1234"

      when_i_use_the_report_incorrect_partnership_token "abc1234"

      then_i_am_on_the_report_incorrect_partnership_link_expired_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge link expired"
    end
  end

  describe "when the school has chosen a FIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      given_a_fip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page
      and_i_report_school_partnership_has_been_confirmed_incorrectly_from_school_partnerships_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
    end

    scenario "Cannot challenge an expired challenge" do
      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
    end
  end

  describe "when the school has chosen a CIP programme" do
    scenario "Can challenge a partnership from the school page" do
      given_a_cip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      given_a_cip_school_with_a_partnership_that_can_be_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page
      and_i_report_school_partnership_has_been_confirmed_incorrectly_from_school_partnerships_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      given_a_cip_school_with_a_partnership_that_has_previously_been_challenged "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page

      then_i_cannot_report_school_partnership_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      given_a_cip_school_with_a_partnership_that_has_an_expired_challenge "test-sit@example.com", "Test school", "111111-test-school", "abc1234"
      and_i_authenticate_as_the_user_with_the_email "test-sit@example.com"

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page

      then_i_cannot_report_school_partnership_has_been_confirmed_incorrectly
    end
  end

private

  def given_i_use_the_report_incorrect_partnership_token(challenge_token)
    Pages::ReportIncorrectPartnershipPage.load_from_email challenge_token
  end
  alias_method :when_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token
  alias_method :and_i_use_the_report_incorrect_partnership_token, :given_i_use_the_report_incorrect_partnership_token

  def then_i_cannot_report_school_has_been_confirmed_incorrectly
    page_object = Pages::SchoolDashboardPage.loaded
    expect(page_object).to_not be_able_to_report_school_has_been_confirmed_incorrectly
  end

  def then_i_cannot_report_school_partnership_has_been_confirmed_incorrectly
    page_object = Pages::SchoolPartnershipsPage.loaded
    expect(page_object).to_not be_able_to_report_school_partnership_has_been_confirmed_incorrectly
  end
end
