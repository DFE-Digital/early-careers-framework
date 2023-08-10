# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ Application change logs", rutabaga: false do
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
    when_i_select_application_for "Gilda Marks Jr."
    when_i_mark_the_applicant_as_eligible
    when_i_see_the_applicant_change_log

    then_i_can_see_a_change_log_on_eligible_attribute
  end

private

  def given_there_is_an_npq_application
    create(:npq_application)
  end

  def the_npq_applications_edge_cases
    admin_npq_applications_edge_cases_path
  end

  def when_i_select_application_for(applicant_name)
    click_on applicant_name
  end

  def when_i_mark_the_applicant_as_eligible
    within(".govuk-summary-list__row", text: "Eligible for funding") do
      click_link "edit"
    end

    choose "Yes"
    click_on "Continue"
  end

  def when_i_see_the_applicant_change_log
    click_on "View change log"
  end

  def then_i_can_see_a_change_log_on_eligible_attribute
    expect(page).to have_selector("table.govuk-table:first-of-type tbody tr", text: /Eligible.*?false.*?true/)
  end
end
