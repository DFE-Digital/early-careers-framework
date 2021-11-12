# frozen_string_literal: true

require "rails_helper"

RSpec.feature "NPQ Course payment breakdown", :with_default_schedules do
  include FinanceHelper
  let(:cpd_lead_provider)                         { create(:cpd_lead_provider) }
  let(:npq_lead_provider)                         { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider) }
  let(:npq_leading_teaching_contract)             { create(:npq_contract, :npq_leading_teaching, npq_lead_provider: npq_lead_provider) }
  let(:npq_leading_behaviour_culture_contract)    { create(:npq_contract, :npq_leading_behaviour_culture, npq_lead_provider: npq_lead_provider) }
  let(:npq_leading_teaching_development_contract) { create(:npq_contract, :npq_leading_teaching_development, npq_lead_provider: npq_lead_provider) }
  let(:npq_course_leading_teaching)               { create(:npq_course, identifier: npq_leading_teaching_contract.course_identifier) }
  let(:npq_course_leading_behaviour_culture)      { create(:npq_course, identifier: npq_leading_behaviour_culture_contract.course_identifier) }
  let(:npq_course_leading_teaching_development)   { create(:npq_course, identifier: npq_leading_teaching_development_contract.course_identifier) }
  let(:breakdowns) do
    Finance::NPQ::CalculationOverviewOrchestrator.call(
      cpd_lead_provider: cpd_lead_provider,
      event_type: :started,
    )
  end

  before { Finance::Schedule.all }

  scenario "Can get to NPQ payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_npq_provider_with_contracts
    and_those_courses_have_submitted_declations
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider
    then_i_should_have_the_correct_payment_breakdown_per_npq_lead_provider
    when_i_click_on(npq_leading_teaching_contract)
    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_teaching_contract)
    then_i_should_see_correct_payment_breakdown(cpd_lead_provider, npq_leading_teaching_contract)
    when_i_click "Back"
    when_i_click_on(npq_leading_behaviour_culture_contract)
    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_behaviour_culture_contract)
    when_i_click "Back"
    when_i_click_on(npq_leading_teaching_development_contract)
    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_teaching_development_contract)
  end

private

  def and_those_courses_have_submitted_declations
    create_list(:user, 4, :with_started_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching)
    create_list(:user, 4, :with_started_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_behaviour_culture)
    create_list(:user, 4, :with_started_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching_development)

    create_list(:user, 3, :with_eligible_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching)
    create_list(:user, 3, :with_eligible_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_behaviour_culture)
    create_list(:user, 3, :with_eligible_npq_declaration, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching_development)

    create_list(:user, 2, :with_payable_npq_declarations, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching)
    create_list(:user, 2, :with_payable_npq_declarations, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_behaviour_culture)
    create_list(:user, 2, :with_payable_npq_declarations, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching_development)
  end

  def and_there_is_npq_provider_with_contracts
    npq_leading_teaching_contract
    npq_leading_behaviour_culture_contract
    npq_leading_teaching_development_contract
  end

  def when_i_visit_the_payment_breakdown_page
    click_on "Payment Breakdown"
  end

  def and_choose_to_see_npq_payment_breakdown
    choose "NPQ payments"
    click_on "Continue"
  end

  def and_i_select_an_npq_lead_provider
    choose npq_lead_provider.name
    click_on "Continue"
  end

  def then_i_should_have_the_correct_payment_breakdown_per_npq_lead_provider
    within "main .govuk-grid-column-two-thirds table:nth-child(3)" do
      expect(page)
        .to have_css("tbody tr.govuk-table__row:nth-child(1) a[href='#{finance_npq_lead_provider_course_path(npq_lead_provider, id: npq_leading_teaching_contract.course_identifier)}']")
      expect(page)
        .to have_css("tbody tr.govuk-table__row:nth-child(2) a[href='#{finance_npq_lead_provider_course_path(npq_lead_provider, id: npq_leading_behaviour_culture_contract.course_identifier)}']")
      expect(page)
        .to have_css("tbody tr.govuk-table__row:nth-child(3) a[href='#{finance_npq_lead_provider_course_path(npq_lead_provider, id: npq_leading_teaching_development_contract.course_identifier)}']")
    end
  end

  def when_i_click_on(npq_contract)
    click_on I18n.t(npq_contract.course_identifier, scope: %i[courses npq])
  end

  def then_i_should_see_correct_breakdown_summary(npq_lead_provider, npq_contract)
    expect(page).to have_css("h2.govuk-heading-l", text: NPQCourse.find_by!(identifier: npq_contract.course_identifier).name)

    expect(page.find("dt.govuk-summary-list__key", text: "Submission deadline"))
      .to have_sibling("dd.govuk-summary-list__value", text: cutoff_date)

    expect(page.find("dt.govuk-summary-list__key", text: "Recruitment target"))
      .to have_sibling("dd.govuk-summary-list__value", text: npq_contract.recruitment_target)

    expect(page.find("dt.govuk-summary-list__key", text: "Current participants"))
      .to have_sibling("dd.govuk-summary-list__value", text: ParticipantDeclaration::NPQ.for_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)

    expect(page.find("dt.govuk-summary-list__key", text: "Total paid"))
      .to have_sibling("dd.govuk-summary-list__value", text: ParticipantDeclaration::NPQ.eligible_and_payable_for_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)

    expect(page.find("dt.govuk-summary-list__key", text: "Total not paid"))
      .to have_sibling("dd.govuk-summary-list__value", text: ParticipantDeclaration::NPQ.submitted_for_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)
  end

  def then_i_should_see_correct_payment_breakdown
    expect(page)
      .to have_css("table.govuk-table tbody tr.govuk-table__row:nth-child(1) td:nth-child(1)", text: "Service fee")
  end
end
