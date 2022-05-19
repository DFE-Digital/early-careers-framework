# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Lead Providers Dashboard page", type: :feature, js: true, rutabaga: false do
  before do
    given_a_cohort_with_start_year_2021
  end

  scenario "Visiting the dashboard" do
    given_i_am_logged_in_as_a_lead_provider
    then_i_should_be_on_the_dashboard_page

    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Dashboard page"
  end

  scenario "Confirming your schools" do
    given_i_am_logged_in_as_a_lead_provider
    when_i_choose_to_confirm_my_schools
    then_i_am_on_the_report_schools_wizard_start_page
  end

  scenario "Checking your schools for 2021" do
    given_i_am_logged_in_as_a_lead_provider
    when_i_choose_to_check_my_schools_for_2021
    then_i_am_on_the_check_schools_for_2021_wizard_start_page
  end

private

  def given_a_cohort_with_start_year_2021
    create :cohort, start_year: 2021
  end

  def given_i_am_logged_in_as_a_lead_provider
    user = create :user,
                  :lead_provider,
                  full_name: "lead_provider"

    visit "/users/confirm_sign_in?login_token=#{user.login_token}"
    click_on "Continue"
  end

  def then_i_should_be_on_the_dashboard_page
    lead_provider_dashboard_page = Pages::LeadProviderDashboard.new
    lead_provider_dashboard_page.displayed?
  end

  def when_i_choose_to_confirm_my_schools
    lead_provider_dashboard_page = Pages::LeadProviderDashboard.new
    lead_provider_dashboard_page.start_confirm_your_schools_wizard
  end

  def when_i_choose_to_check_my_schools_for_2021
    lead_provider_dashboard_page = Pages::LeadProviderDashboard.new
    lead_provider_dashboard_page.check_schools_for_2021
  end

  def then_i_am_on_the_report_schools_wizard_start_page
    confirm_your_school_wizard = Pages::LeadProviderConfirmYourSchoolsWizard.new
    confirm_your_school_wizard.displayed?
  end

  def then_i_am_on_the_check_schools_for_2021_wizard_start_page
    check_schools_for_2021_wizard = Pages::LeadProviderSchoolsDashboard.new
    check_schools_for_2021_wizard.displayed?
  end
end
