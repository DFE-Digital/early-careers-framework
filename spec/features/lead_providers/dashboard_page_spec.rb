# frozen_string_literal: true

require "rails_helper"

class LeadProviderDashboardScenario
  attr_reader :number,
              :email_address,
              :full_name

  def initialize(num)
    @number = num

    @email_address = "test-lead-provider-#{num}@example.com"
    @full_name = "Test Lead Provider #{num}"
  end
end

RSpec.feature "Lead Provider Dashboard", type: :feature, js: true, rutabaga: false do
  before do
    given_a_cohort_with_start_year 2021
  end

  scenario "Lead provider dashboard is accessible" do
    @scenario = LeadProviderDashboardScenario.new(1)

    given_a_lead_provider @scenario.email_address, @scenario.full_name
    and_i_authenticate_as_the_user_with_the_email @scenario.email_address

    when_i_am_on_the_lead_provider_dashboard

    then_the_page_is_accessible
    and_percy_is_sent_a_snapshot_named "Lead Provider Dashboard"
  end

  scenario "Visiting the Lead provider dashboard" do
    @scenario = LeadProviderDashboardScenario.new(2)

    given_a_lead_provider @scenario.email_address, @scenario.full_name

    when_i_authenticate_as_the_user_with_the_email @scenario.email_address

    then_i_am_on_the_lead_provider_dashboard
  end

  scenario "Confirming schools" do
    @scenario = LeadProviderDashboardScenario.new(3)

    given_a_lead_provider @scenario.email_address, @scenario.full_name
    and_i_authenticate_as_the_user_with_the_email @scenario.email_address

    when_i_confirm_my_schools_with_lead_provider_name @scenario.full_name

    then_i_am_on_the_confirm_schools_wizard
  end

  scenario "Checking schools" do
    @scenario = LeadProviderDashboardScenario.new(4)

    given_a_lead_provider @scenario.email_address, @scenario.full_name
    and_i_authenticate_as_the_user_with_the_email @scenario.email_address

    when_i_check_my_schools_with_lead_provider_name @scenario.full_name

    then_i_am_on_the_check_schools_page
  end

private

  def given_a_cohort_with_start_year(year)
    Cohort.find_or_create_by! start_year: year
  end

  def given_a_lead_provider(email_address, lead_provider_name)
    user = create :user,
                  full_name: lead_provider_name,
                  email: email_address

    ecf_lead_provider = create :lead_provider,
                               name: lead_provider_name

    create :cpd_lead_provider,
           lead_provider: ecf_lead_provider,
           name: lead_provider_name

    create :lead_provider_profile,
           user: user,
           lead_provider: ecf_lead_provider
  end

  def when_i_confirm_my_schools_with_lead_provider_name(full_name)
    page_object = Pages::LeadProviderDashboard.loaded
    expect(page_object).to have_primary_heading(text: full_name)

    page_object.confirm_schools
  end

  def when_i_check_my_schools_with_lead_provider_name(full_name)
    page_object = Pages::LeadProviderDashboard.loaded
    expect(page_object).to have_primary_heading(text: full_name)

    page_object.check_schools
  end
end
