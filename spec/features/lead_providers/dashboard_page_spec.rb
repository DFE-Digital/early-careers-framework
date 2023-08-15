# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Lead Provider Dashboard", type: :feature, js: true, rutabaga: false do
  let(:email_address) { "test-lead-provider@example.com" }
  let(:lead_provider_name) { "Test Lead Provider" }

  let!(:cohort) { Cohort.find_by start_year: 2021 }
  let!(:cohort_next) { Cohort.find_by start_year: 2022 }
  let!(:ecf_lead_provider) do
    ecf_lead_provider = create(:lead_provider, name: lead_provider_name)
    create :cpd_lead_provider, lead_provider: ecf_lead_provider, name: lead_provider_name
    user = create(:user, full_name: "#{lead_provider_name}'s Manager", email: email_address)
    create :lead_provider_profile, user:, lead_provider: ecf_lead_provider
    ecf_lead_provider
  end

  before do
    allow(Cohort).to receive(:current).and_return(cohort)
    allow(Cohort).to receive(:next).and_return(cohort_next)
  end

  scenario "Lead provider dashboard is accessible" do
    given_i_sign_in_as_the_user_with_the_email email_address
    and_i_confirm_lead_provider_name_on_the_lead_provider_dashboard lead_provider_name

    then_the_page_is_accessible
  end

  scenario "Visiting the Lead provider dashboard" do
    given_i_sign_in_as_the_user_with_the_email email_address
    and_i_am_on_the_lead_provider_dashboard

    then_i_am_on_the_lead_provider_dashboard
  end

  scenario "Confirming schools" do
    travel_to cohort.registration_start_date + 1.day

    given_i_sign_in_as_the_user_with_the_email email_address
    and_i_am_on_the_lead_provider_dashboard
    and_i_do_not_see_next_cohort_schools_confirmation

    when_i_confirm_schools_from_the_lead_provider_dashboard

    then_i_am_on_the_confirm_schools_wizard
  end

  scenario "Checking schools" do
    given_i_sign_in_as_the_user_with_the_email email_address

    when_i_check_schools_from_the_lead_provider_dashboard

    then_i_am_on_the_check_schools_page
  end

  def and_i_do_not_see_next_cohort_schools_confirmation
    expect(page).not_to have_content("Confirm your schools for the 2022 to 2023 academic year")
  end
end
