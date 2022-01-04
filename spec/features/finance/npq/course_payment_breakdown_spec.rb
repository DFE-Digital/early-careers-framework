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
  let(:invoice) { Finance::Invoice.find_by_name("current") }

  scenario "see a payment breakdown per NPQ course and a payment breakdown of each individual NPQ courses for each provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_npq_provider_with_contracts
    and_those_courses_have_submitted_declations
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider
    then_i_should_have_the_correct_payment_breakdown_per_npq_lead_provider

    [npq_leading_teaching_contract, npq_leading_behaviour_culture_contract, npq_leading_teaching_development_contract].each do |npq_contract|
      when_i_click_on(npq_contract)
      # then_i_should_see_correct_breakdown_summary(npq_contract.npq_lead_provider.cpd_lead_provider, npq_contract)
      then_i_should_see_correct_service_fee_payment_breakdown(npq_contract)
      # then_i_should_see_correct_output_payment_breakdown(npq_contract)
      # then_i_should_see_the_correct_total(npq_contract)
      when_i_click "Back"
    end
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
    timestamp = npq_application.profile.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      RecordDeclarations::Started::NPQ.call(
        params: {
          participant_id: npq_application.user.id,
          course_identifier: npq_application.npq_course.identifier,
          declaration_date: timestamp.rfc3339,
          cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
          declaration_type: RecordDeclarations::NPQ::STARTED,
        },
      )
    end
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

  def expected_current_particpant_count(npq_contract)
    ParticipantDeclaration::NPQ.neither_paid_nor_voided_lead_provider_and_course(npq_contract.npq_lead_provider, npq_contract.course_identifier).count
  end

  def expected_total_paid(npq_contract)
    ParticipantDeclaration::NPQ
      .eligible_or_payable_for_lead_provider_and_course(npq_contract.npq_lead_provider.cpd_lead_provider, npq_contract.course_identifier)
      .count
  end

  def then_i_should_see_correct_breakdown_summary(npq_lead_provider, npq_contract)
    expect(page).to have_css("h2.govuk-heading-l", text: NPQCourse.find_by!(identifier: npq_contract.course_identifier).name)

    within("[data-test='npq-references']") do
      expect(page).to have_content("Submission deadline")
      expect(page).to have_content(invoice.deadline_date.to_s(:govuk))
    end

    within("[data-test='npq-total-paid']") do
      expect(page).to have_content("Recruitment target")
      expect(page).to have_content(npq_contract.recruitment_target)
      expect(page).to have_content("Current participants")
      expect(page).to have_content(ParticipantDeclaration::NPQ.neither_paid_nor_voided_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)
      expect(page).to have_content("Total paid")
      expect(page).to have_content(expected_total_paid(npq_contract))
      expect(page).to have_content("Total not paid")
      expect(page).to have_content(ParticipantDeclaration::NPQ.submitted_for_lead_provider_and_course(npq_lead_provider, npq_contract.course_identifier).count)
    end
  end

  def expected_service_fee_portion_per_participant(npq_contract)
    npq_contract.per_participant * npq_contract.service_fee_percentage / (100 * npq_contract.service_fee_installments)
  end

  def expected_service_fee_payment(npq_contract)
    npq_contract.recruitment_target * expected_service_fee_portion_per_participant(npq_contract)
  end

  def then_i_should_see_correct_service_fee_payment_breakdown(npq_contract)
    within("[data-test='npq-payment-type']") do
      expect(page).to have_content("Service fee")
      expect(page).to have_content(number_to_pounds(expected_service_fee_portion_per_participant(npq_contract)))
      expect(page).to have_content(npq_contract.recruitment_target)
      expect(page).to have_content(number_to_pounds(expected_service_fee_payment(npq_contract)))
    end
  end

  def expected_per_participant_output_payment_portion(npq_contract)
    (npq_contract.per_participant * npq_contract.output_payment_percentage) / (100 * npq_contract.number_of_payment_periods)
  end

  def eligible_and_payable_participant_count(npq_contract)
    ParticipantDeclaration::NPQ
      .eligible_or_payable_for_lead_provider_and_course(
        npq_contract.npq_lead_provider.cpd_lead_provider, npq_contract.course_identifier
      ).count
  end

  def expected_output_fee_payment(npq_contract)
    expected_per_participant_output_payment_portion(npq_contract) * eligible_and_payable_participant_count(npq_contract)
  end

  def then_i_should_see_correct_output_payment_breakdown(npq_contract)
    within("[data-test='npq-payment-type']") do
      expect(page).to have_content("Output fee")
      expect(page).to have_content(number_to_pounds(expected_per_participant_output_payment_portion(npq_contract)))
      expect(page).to have_content(expected_total_paid(npq_contract))
      expect(page).to have_content(number_to_pounds(expected_output_fee_payment(npq_contract)))
      expect(page).to have_content(eligible_and_payable_participant_count(npq_contract))
    end
  end

  def then_i_should_see_the_correct_total(npq_contract)
    within("[data-test='npq-payment-type']") do
      expected_service_fee_payment = expected_service_fee_payment(npq_contract)
      expected_output_fee_payment  = expected_output_fee_payment(npq_contract)
      expected_total               = expected_service_fee_payment + expected_output_fee_payment

      expect(page).to have_content("Total payment")
      expect(page).to have_content(number_to_pounds(expected_total))
    end
  end
end
