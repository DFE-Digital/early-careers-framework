# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Lead Provider Dashboard", type: :feature, js: true, rutabaga: false do
  let(:email_address) { "test-lead-provider@example.com" }
  let(:lead_provider_name) { "Test Lead Provider" }
  let(:school_name) { "Fip School 1" }
  let(:school) { create(:school, name: school_name) }

  let!(:cohort) { Cohort.find_by start_year: 2021 }
  let!(:cohort_next) { Cohort.find_by start_year: 2022 }
  let!(:ecf_lead_provider) do
    ecf_lead_provider = create(:lead_provider, name: lead_provider_name)
    create :cpd_lead_provider, lead_provider: ecf_lead_provider, name: lead_provider_name
    user = create(:user, full_name: "#{lead_provider_name}'s Manager", email: email_address)
    create :lead_provider_profile, user:, lead_provider: ecf_lead_provider
    ecf_lead_provider
  end
  let(:delivery_partner) { create(:delivery_partner, name: "Ace Delivery Partner") }
  let(:current_cohort) { Cohort.current || create(:cohort, :current) }

  def and_i_confirm_lead_provider_name_on_the_lead_provider_dashboard(lead_provider_name)
    page.find("h1").has_content? lead_provider_name
  end

  def and_i_am_on_the_lead_provider_dashboard
    expect(page).to have_current_path "/dashboard"
    expect(page).to have_title "Manage training for early career teachers"
  end

  def then_i_am_on_the_confirm_schools_wizard
    expect(page).to have_current_path "/lead-providers/report-schools/start?cohort=2021"
    expect(page).to have_title "Manage training for early career teachers"
  end

  def then_i_am_on_the_lead_provider_dashboard
    expect(page).to have_current_path "/dashboard"
    expect(page).to have_title "Manage training for early career teachers"
  end

  def when_i_confirm_schools_from_the_lead_provider_dashboard
    click_on "Confirm your schools for the 2021 to 2022 academic year"
  end

  def and_a_school_has_been_already_confirmed_for_the_current_cohort
    school_cohort = create(:school_cohort, school:, cohort: current_cohort, induction_programme_choice: "full_induction_programme")
    partnership = create(:partnership, school:, lead_provider: ecf_lead_provider, delivery_partner:, cohort: current_cohort)
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
    school_cohort.update!(default_induction_programme: induction_programme)
  end

  def given_lead_provider_with_pupil_premiums_schools
    start_year = current_cohort.start_year
    schools = [
      create(:school, pupil_premiums: [build(:pupil_premium, :uplift, start_year:)], name: "Big School", urn: 700_001),
      create(:school, pupil_premiums: [build(:pupil_premium, :sparse, start_year:)], name: "Middle School", urn: 700_002),
      create(:school, pupil_premiums: [build(:pupil_premium, :uplift, :sparse, start_year:)], name: "Small School", urn: 700_003),
    ]

    schools.each_with_index do |school, index|
      create(:partnership, school:, lead_provider: ecf_lead_provider, delivery_partner:, cohort: current_cohort)
      create(:user, :induction_coordinator, schools: [schools[index]], email: "induction.tutor#{index + 1}@example.com")
    end
  end

  def then_i_should_see(text)
    and_i_should_see text
  end

  def and_i_should_see(text)
    expect(page).to have_content(text)
  end

  def and_i_should_not_see_the_table_with_the_results
    expect(page).to_not have_selector("table th")
  end

  def and_i_should_see_a_table_with_column_number(number)
    expect(page).to have_selector("table th", count: number)
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
    and_a_school_has_been_already_confirmed_for_the_current_cohort

    when_i_visit_the_schools_page
    then_i_should_see "Your schools"
    and_i_should_see "Confirm more schools"
    and_i_should_see "Download schools for"
    and_i_should_see "2021 cohort"
    and_i_should_see "2022 cohort"
    and_i_should_see "School recruited"
    and_i_should_see_a_table_with_column_number 5
    and_i_should_see school_name
    and_the_page_is_accessible
  end

  scenario "Searching my list of schools" do
    given_i_sign_in_as_the_user_with_the_email email_address
    and_a_school_has_been_already_confirmed_for_the_current_cohort

    when_i_visit_the_schools_page

    when_i_type_the_school_urn_in_the_search_bar
    and_click_search
    then_i_should_see school_name
    and_i_should_see school.urn
    and_i_should_see "Ace Delivery Partner"
    and_i_should_see_a_table_with_column_number 5

    when_i_type_an_invalid_search_term
    and_click_search
    then_i_should_see "There are no matching results"
    and_i_should_not_see_the_table_with_the_results
  end

  scenario "Viewing schools with pupil premiums" do
    given_lead_provider_with_pupil_premiums_schools
    and_i_sign_in_as_the_user_with_the_email email_address

    when_i_visit_the_schools_page
    and_i_click_on "Big School"
    then_i_should_see "Big School"
    and_i_should_see "#{Cohort.current.start_year} participants"
    and_i_should_see "700001"
    and_i_should_see "Ace Delivery Partner"
    and_i_should_see "Pupil premium above 40%"
    and_i_should_see "induction.tutor1@example.com"
    and_the_page_is_accessible

    when_i_visit_the_schools_page
    and_i_click_on "Middle School"
    then_i_should_see "Middle School"
    and_i_should_see "#{Cohort.current.start_year} participants"
    and_i_should_see "700002"
    and_i_should_see "Ace Delivery Partner"
    and_i_should_see "Remote school"
    and_i_should_see "induction.tutor2@example.com"

    when_i_visit_the_schools_page
    and_i_click_on "Small School"
    then_i_should_see "Small School"
    and_i_should_see "#{Cohort.current.start_year} participants"
    and_i_should_see "700003"
    and_i_should_see "Ace Delivery Partner"
    and_i_should_see "Pupil premium above 40% and Remote school"
    and_i_should_see "induction.tutor3@example.com"
  end

  def when_i_click_on(string)
    page.click_on(string)
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_visit_the_schools_page
    @schools_page = Pages::CheckSchoolsPage.load
    expect(@schools_page).to be_displayed
  end

  def and_i_do_not_see_next_cohort_schools_confirmation
    expect(page).not_to have_content("Confirm your schools for the 2022 to 2023 academic year")
  end

  def when_i_type_the_school_urn_in_the_search_bar
    when_i_fill_in "query", with: school.urn
  end

  def and_click_search
    @schools_page.search
  end

  def when_i_type_an_invalid_search_term
    when_i_fill_in "query", with: "invalid"
  end
end
