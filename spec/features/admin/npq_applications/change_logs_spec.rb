# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ Application change logs", js: true, rutabaga: false do
  before do
    PaperTrail.config.enabled = true
  end

  after do
    PaperTrail.config.enabled = false
  end

  scenario "Show a change log for an Applicant (Edge cases section)" do
    given_there_is_an_npq_application
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_edge_cases
    when_i_select_the_first_applicant
    when_i_mark_the_applicant_as_eligible
    when_i_see_the_applicant_change_log

    then_i_can_see_a_change_log_on_eligible_attribute
  end

  scenario "Show a change log for an Applicant (API - first version)" do
    given_there_is_an_npq_application_via_api
    and_i_am_signed_in_as_an_admin

    when_i_visit the_npq_applications_edge_cases
    when_i_select_the_first_applicant
    when_i_mark_the_applicant_as_eligible
    when_i_see_the_applicant_change_log

    expect(page).to have_content("Changed from", count: 2)
    expect(page).to have_content("Updated by", count: 1)
  end

private

  def given_there_is_an_npq_application
    application = create :npq_application, :edge_case

    allow(User).to receive(:find).and_return(application.user)
  end

  def given_there_is_an_npq_application_via_api
    application = create :npq_application, :edge_case
    application.versions.first.update!(whodunnit: NPQRegistrationApiToken.new.owner)

    allow(User).to receive(:find).and_return(application.user)
  end

  def the_npq_applications_edge_cases
    admin_npq_applications_edge_cases_path
  end

  def when_i_select_the_first_applicant
    first_applicant = page.find("table td.applicant-name a", match: :first)
    first_applicant.click
  end

  def when_i_mark_the_applicant_as_eligible
    within(".govuk-summary-list__row", text: "Eligible for funding") do
      click_link "Edit"
    end
    choose "Yes"
    click_on "Continue"
  end

  def when_i_see_the_applicant_change_log
    click_on "View change log"
  end

  def then_i_can_see_a_change_log_on_eligible_attribute
    expect(page).to have_selector("table.govuk-table:first-of-type tbody tr", text: /Eligible.*?No.*?Yes/)
  end
end
