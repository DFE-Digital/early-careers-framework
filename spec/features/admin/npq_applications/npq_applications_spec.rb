# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ application details", js: true, rutabaga: false do
  before do
    PaperTrail.config.enabled = true
  end

  after do
    PaperTrail.config.enabled = false
  end

  scenario "Show applications details (funded place)",
           with_feature_flags: { npq_capping: "active" } do
    create :npq_application, :edge_case, funded_place: true

    and_i_am_signed_in_as_an_admin

    when_i_visit_the_npq_applications_section
    when_i_display_an_npq_application

    then_i_can_see_the_application_details
  end

private

  def when_i_visit_the_npq_applications_section
    click_on "NPQ"
    click_on "Applications"
  end

  def when_i_display_an_npq_application
    click_on "View"
  end

  def then_i_can_see_the_application_details
    expect(page).to have_selector(".govuk-summary-list__row--no-actions", text: /Funded place.*?Yes/)
  end
end
