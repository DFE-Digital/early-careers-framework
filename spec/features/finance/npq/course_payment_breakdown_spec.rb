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

  scenario "Can get to NPQ payment breakdown page for a provider", :js do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_npq_provider_with_contracts
    and_those_courses_have_submitted_declations
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider
    then_i_should_have_the_correct_payment_breakdown_per_npq_lead_provider
    when_i_click_on(npq_leading_teaching_contract)

    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_teaching_contract)
    then_i_should_see_correct_service_fee_payment_breakdown(npq_leading_teaching_contract)
    then_i_should_see_correct_output_payment_breakdown(npq_leading_teaching_contract)
    when_i_click "Back"

    when_i_click_on(npq_leading_behaviour_culture_contract)
    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_behaviour_culture_contract)
    then_i_should_see_correct_service_fee_payment_breakdown(npq_leading_behaviour_culture_contract)
    then_i_should_see_correct_output_payment_breakdown(npq_leading_behaviour_culture_contract)
    when_i_click "Back"

    when_i_click_on(npq_leading_teaching_development_contract)
    then_i_should_see_correct_breakdown_summary(cpd_lead_provider, npq_leading_teaching_development_contract)
    then_i_should_see_correct_service_fee_payment_breakdown(npq_leading_teaching_development_contract)
    then_i_should_see_correct_output_payment_breakdown(npq_leading_teaching_development_contract)
  end

private

  def create_accepted_application(user, npq_course, npq_lead_provider)
    npq_application = NPQ::BuildApplication.call(
      npq_application_params: attributes_for(:npq_application),
      npq_course_id: npq_course.id,
      npq_lead_provider_id: npq_lead_provider.id,
      user_id: user.id,
    )
    npq_application.save!
    NPQ::Accept.call(npq_application: npq_application)
    npq_application
  end

  def create_started_declarations(npq_application)
    RecordDeclarations::Started::NPQ.call(
      params: {
        participant_id: npq_application.user.id,
        course_identifier: npq_application.npq_course.identifier,
        declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
        declaration_type: RecordDeclarations::NPQ::STARTED,
      },
    )
  end

  def create_started_declarations(npq_application)
    RecordDeclarations::Started::NPQ.call(
      params: {
        participant_id: npq_application.user.id,
        course_identifier: npq_application.npq_course.identifier,
        declaration_date: (npq_application.profile.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
        declaration_type: RecordDeclarations::NPQ::STARTED,
      },
    )
  end

  def and_those_courses_have_submitted_declations
    [npq_course_leading_teaching, npq_course_leading_behaviour_culture, npq_course_leading_teaching_development].each do |npq_course|
      create_list(:user, 2)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }

      create_list(:user, 3)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }

      create_list(:user, 4)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map(&JSON.method(:parse))
        .map { |deserialised_participant_declaration| ParticipantDeclaration::NPQ.find(deserialised_participant_declaration.dig("data", "id")) }
        .each(&:make_eligible!)

      create_list(:user, 5)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map(&JSON.method(:parse))
        .map { |deserialised_participant_declaration| ParticipantDeclaration::NPQ.find(deserialised_participant_declaration.dig("data", "id")) }
        .map { |participant_declaration| participant_declaration.make_eligible! && participant_declaration }
        .each(&:make_payable!)
    end
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
      .to have_sibling("dd.govuk-summary-list__value", text: Finance::Invoice.find_by_name("current").deadline_date.to_s(:govuk))

    expect(page.find("dt.govuk-summary-list__key", text: "Recruitment target"))
      .to have_sibling("dd.govuk-summary-list__value", text: npq_contract.recruitment_target)

    expect(page.find("dt.govuk-summary-list__key", text: "Current participants"))
      .to have_sibling("dd.govuk-summary-list__value", text: ParticipantDeclaration::NPQ.neither_paid_nor_voided_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)

    expected_total_paid = ParticipantDeclaration::NPQ
                            .eligible_or_payable_for_lead_provider_and_course(cpd_lead_provider, npq_contract.course_identifier)
                            .count

    expect(page.find("dt.govuk-summary-list__key", text: "Total paid"))
      .to have_sibling("dd.govuk-summary-list__value", text: expected_total_paid)

    expect(page.find("dt.govuk-summary-list__key", text: "Total not paid"))
      .to have_sibling("dd.govuk-summary-list__value", text: ParticipantDeclaration::NPQ.submitted_for_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)
  end

  def then_i_should_see_correct_service_fee_payment_breakdown(npq_contract)
    within "table.govuk-table tbody tr.govuk-table__row:nth-child(1)" do
      expected_per_participant_portion = npq_contract.per_participant * npq_contract.service_fee_percentage / (100 * npq_contract.service_fee_installments)

      expect(page.find("td:nth-child(1)", text: "Service fee"))
        .to have_sibling("td", text: number_to_pounds(expected_per_participant_portion))

      expect(page.find("td:nth-child(1)", text: "Service fee"))
        .to have_sibling("td", text: number_to_pounds(npq_contract.recruitment_target * expected_per_participant_portion))
    end
  end

  def then_i_should_see_correct_output_payment_breakdown(npq_contract)
    within "table.govuk-table tbody tr.govuk-table__row:nth-child(2)" do
      expected_per_participant_portion = (npq_contract.per_participant * npq_contract.output_payment_percentage) / (100 * npq_contract.number_of_payment_periods)

      expect(page.find("td:nth-child(1)", text: "Output fee"))
        .to have_sibling("td", text: number_to_pounds(expected_per_participant_portion))

      expected_output_fee = expected_per_participant_portion * \
        ParticipantDeclaration::NPQ
          .eligible_or_payable_for_lead_provider_and_course(
            npq_contract.npq_lead_provider.cpd_lead_provider, npq_contract.course_identifier
          ).count

      expect(page.find("td:nth-child(1)", text: "Output fee"))
        .to have_sibling("td", text: number_to_pounds(expected_output_fee))
    end
  end
end
