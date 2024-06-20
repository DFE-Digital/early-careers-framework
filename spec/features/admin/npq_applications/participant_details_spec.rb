# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Admin NPQ participant details", js: true, rutabaga: false do
  before do
    PaperTrail.config.enabled = true
  end

  after do
    PaperTrail.config.enabled = false
  end

  let(:npq_course) { create(:npq_leadership_course, identifier: "npq-senior-leadership") }
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_npq_lead_provider) }
  let(:npq_lead_provider) { cpd_lead_provider.npq_lead_provider }

  scenario "Show participant details for an NPQ participant (funded place)",
           with_feature_flags: { npq_capping: "active" } do
    given_there_is_an_npq_participant
    and_i_am_signed_in_as_an_admin

    when_i_visit_the_npq_applications_participants
    when_i_display_an_npq_participant

    then_i_can_see_the_participant_funded_place_attribute
  end

private

  def when_i_visit_the_npq_applications_participants
    click_on "Participants"
    select "NPQ", from: "Filter by type"
    click_on "Search"
  end

  def when_i_display_an_npq_participant
    click_on @npq_participant_profile.user.full_name
  end

  def given_there_is_an_npq_participant
    statement = create(:npq_statement, :next_output_fee, cpd_lead_provider: npq_lead_provider.cpd_lead_provider, cohort: Cohort.current)
    create(:npq_contract, npq_lead_provider:, cohort: statement.cohort, course_identifier: npq_course.identifier, version: statement.contract_version, funding_cap: 10)
    npq_application = create(:npq_application, :accepted, :eligible_for_funding, funded_place: false, npq_course:, npq_lead_provider:, cohort: statement.cohort)

    @npq_participant_profile = npq_application.profile
  end

  def then_i_can_see_the_participant_funded_place_attribute
    expect(page).to have_selector(".govuk-summary-list__row--no-actions", text: /Funded place.*?No/)
  end
end
