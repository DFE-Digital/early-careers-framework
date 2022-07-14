# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding ECT with appropriate body", type: :feature, js: true do
  let!(:cohort) { create :cohort, start_year: 2021 }
  let!(:school) { create :school, name: "Fip School" }
  let!(:appropriate_body) { create :appropriate_body_national_organisation }
  let!(:school_cohort) { create :school_cohort, school:, cohort: Cohort.next, induction_programme_choice: "full_induction_programme", appropriate_body: }
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:)
    school_cohort.update! default_induction_programme: induction_programme
    induction_programme
  end
  let!(:partnership) do
    create :partnership,
           school:,
           lead_provider: create(:lead_provider, name: "Big Provider Ltd"),
           delivery_partner: create(:delivery_partner, name: "Amazing Delivery Team"),
           cohort: Cohort.next,
           challenge_deadline: 2.weeks.ago
  end
  let!(:user) { create(:user, full_name: "Induction tutor") }
  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end
  let!(:induction_coordinator) do
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user: user)
    PrivacyPolicy.current.accept!(user)
    induction_coordinator_profile
  end
  let!(:schedule) { create :ecf_schedule }

  before do
    school_cohort.update! default_induction_programme: induction_programme
  end

  scenario "Appropriate body is confirmed and appears on the participant detail page" do
    sign_in_as user

    click_on "Add your early career teacher and mentor details"
    click_on "Continue"
    click_on "Add a new ECT"
    fill_in "schools_add_participant_form[full_name]", with: "George ECT"
    click_on "Continue"
    choose "No"
    click_on "Continue"
    fill_in "schools_add_participant_form[email]", with: "ect@email.gov.uk"
    click_on "Continue"
    fill_in "schools_add_participant_form[start_date(3i)]", with: "1"
    fill_in "schools_add_participant_form[start_date(2i)]", with: "1"
    fill_in "schools_add_participant_form[start_date(1i)]", with: Date.today.year + 1
    click_on "Continue"

    expect(page).to have_content("Is this the appropriate body for George ECT’s induction?")
    click_on "Confirm"

    expect(page).to have_content("Check your answers")
    expect(page).to have_summary_row("Appropriate body", appropriate_body.name)

    click_on "Confirm and add"
    click_on "View your ECTs and mentors"
    click_on "George ECT"
    expect(page).to have_summary_row("Appropriate body", appropriate_body.name)
  end
end
