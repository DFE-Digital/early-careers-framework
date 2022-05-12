# frozen_string_literal: true

require "rails_helper"

class ChallengePartnershipScenario
  attr_reader :number,
              :sit_email_address,
              :school_name,
              :school_slug,
              :partnership_challenge_token

  def initialize(num)
    @number = num

    @sit_email_address = "test-sit-#{num}@example.com"

    @school_name = "Test school #{num}"
    @school_slug = "111111-test-school-#{num}"

    @partnership_challenge_token = "abc123_#{num}"
  end
end

RSpec.feature "Reporting an error with a partnership", type: :feature, js: true, rutabaga: false do
  before do
    given_a_cohort_with_start_year 2021
    given_a_privacy_policy_has_been_published
  end

  describe "when using an email link" do
    scenario "Can see challenge options from an email link" do
      @scenario = ChallengePartnershipScenario.new(1)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_page_with_token @scenario.partnership_challenge_token
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge options"
    end

    scenario "Can challenge a partnership from an email link" do
      @scenario = ChallengePartnershipScenario.new(2)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token
      and_i_am_on_the_report_incorrect_partnership_page_with_token @scenario.partnership_challenge_token

      when_i_report_a_mistake_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge success"
    end

    scenario "Cannot challenge a partnership twice from an email link" do
      @scenario = ChallengePartnershipScenario.new(3)

      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_already_challenged_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "already challenged"
    end

    scenario "Cannot challenge an expired challenge from an email link" do
      @scenario = ChallengePartnershipScenario.new(4)

      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token

      when_i_use_the_report_incorrect_partnership_token @scenario.partnership_challenge_token

      then_i_am_on_the_report_incorrect_partnership_link_expired_page
      and_the_page_is_accessible
      and_percy_is_sent_a_snapshot_named "challenge link expired"
    end
  end

  describe "when the school has chosen a FIP programme" do
    scenario "Can challenge a partnership from the school page" do
      @scenario = ChallengePartnershipScenario.new(5)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      when_i_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      @scenario = ChallengePartnershipScenario.new(6)

      given_a_fip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page
      and_i_report_school_partnership_has_been_confirmed_incorrectly_from_school_partnerships_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      @scenario = ChallengePartnershipScenario.new(7)

      given_a_fip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
    end

    scenario "Cannot challenge an expired challenge" do
      @scenario = ChallengePartnershipScenario.new(8)

      given_a_fip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      then_i_confirm_cannot_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
    end
  end

  describe "when the school has chosen a CIP programme" do
    scenario "Can challenge a partnership from the school page" do
      @scenario = ChallengePartnershipScenario.new(9)

      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      when_i_report_school_has_been_confirmed_incorrectly_from_school_dashboard_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Can challenge a partnership by entering the partnerships URL" do
      @scenario = ChallengePartnershipScenario.new(10)

      given_a_cip_school_with_a_partnership_that_can_be_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page
      and_i_report_school_partnership_has_been_confirmed_incorrectly_from_school_partnerships_page
      and_i_report_an_unrecognised_provider_from_report_incorrect_partnership_page

      then_i_am_on_the_report_incorrect_partnership_success_page
    end

    scenario "Cannot challenge a partnership twice" do
      @scenario = ChallengePartnershipScenario.new(11)

      given_a_cip_school_with_a_partnership_that_has_previously_been_challenged @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

      when_i_view_programme_details_from_school_dashboard_page
      and_i_enter_partnership_details_url_from_school_cohorts_page

      then_i_cannot_report_school_partnership_has_been_confirmed_incorrectly
    end

    scenario "Cannot challenge an expired challenge" do
      @scenario = ChallengePartnershipScenario.new(12)

      given_a_cip_school_with_a_partnership_that_has_an_expired_challenge @scenario.sit_email_address, @scenario.school_name, @scenario.school_slug, @scenario.partnership_challenge_token
      and_i_authenticate_as_the_user_with_the_email @scenario.sit_email_address

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
