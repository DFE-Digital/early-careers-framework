# frozen_string_literal: true

require "rails_helper"

RSpec.feature "NPQ Course payment breakdown", :with_default_schedules, type: :feature, js: true do
  include FinanceHelper

  let(:npq_leadership_schedule) { create(:npq_leadership_schedule) }
  let(:npq_specialist_schedule) { create(:npq_specialist_schedule) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Lead Provider") }
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider: cpd_lead_provider, name: "NPQ Lead Provider") }

  let(:npq_leading_teaching_contract) { create(:npq_contract, :npq_leading_teaching, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching) }
  let(:npq_leading_behaviour_culture_contract) { create(:npq_contract, :npq_leading_behaviour_culture, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_behaviour_culture) }
  let(:npq_leading_teaching_development_contract) { create(:npq_contract, :npq_leading_teaching_development, npq_lead_provider: npq_lead_provider, npq_course: npq_course_leading_teaching_development) }

  let(:npq_course_leading_teaching) { create(:npq_course, identifier: "npq-leading-teaching", name: "Leading Teaching") }
  let(:npq_course_leading_behaviour_culture) { create(:npq_course, identifier: "npq-leading-behaviour-culture", name: "Leading Behaviour Culture") }
  let(:npq_course_leading_teaching_development) { create(:npq_course, identifier: "npq-leading-teaching-development", name: "Leading Teaching Development") }

  let!(:statement) do
    create(
      :npq_statement,
      name: "January 2022",
      deadline_date: Date.new(2022, 1, 31),
      payment_date: Date.new(2022, 2, 16),
      cpd_lead_provider: cpd_lead_provider,
      contract_version: npq_leading_teaching_contract.version,
    )
  end

  scenario "see a payment breakdown per NPQ course and a payment breakdown of each individual NPQ courses for each provider" do
    given_i_am_logged_in_as_a_finance_user
    and_those_courses_have_submitted_declarations
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider

    then_i_should_see_correct_statement_summary
    then_i_should_see_correct_course_summary
    then_i_should_see_correct_output_payment_breakdown
    then_i_should_see_correct_service_fee_payment_breakdown
    then_i_should_see_the_correct_total
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Course overview per lead provider")

    when_i_click_on_view_within_statement_summary
    then_i_see_voided_declarations
    when_i_click "Back"
    when_i_click_on_view_contract
    then_i_see_contract_information
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Contract information per NPQ lead provider")
  end

  def create_accepted_application(user, npq_course, npq_lead_provider)
    Identity::Create.call(user: user, origin: :npq)
    npq_application = NPQ::BuildApplication.call(
      npq_application_params: attributes_for(:npq_application, cohort: 2021),
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
          participant_id: npq_application.participant_identity.external_identifier,
          course_identifier: npq_application.npq_course.identifier,
          declaration_date: timestamp.rfc3339,
          cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
          declaration_type: "started",
        },
      )
    end
  end

  def and_those_courses_have_submitted_declarations
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

      create_list(:user, 1)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map(&JSON.method(:parse))
        .map { |deserialised_participant_declaration| ParticipantDeclaration::NPQ.find(deserialised_participant_declaration.dig("data", "id")) }
        .each(&:make_voided!)

      create_list(:user, 2)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map(&JSON.method(:parse))
        .map { |deserialised_participant_declaration| ParticipantDeclaration::NPQ.find(deserialised_participant_declaration.dig("data", "id")) }
        .each(&:make_ineligible!)

      create_list(:user, 5)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map(&JSON.method(:parse))
        .map { |deserialised_participant_declaration| ParticipantDeclaration::NPQ.find(deserialised_participant_declaration.dig("data", "id")) }
        .map { |participant_declaration| participant_declaration.make_eligible! && participant_declaration }
        .each(&:make_payable!)
    end

    ParticipantDeclaration::NPQ
      .where(state: %w[ineligible voided], cpd_lead_provider: cpd_lead_provider)
      .update_all(statement_id: statement.id) # voided payable
    ParticipantDeclaration::NPQ
      .where(state: %w[eligible payable], cpd_lead_provider: cpd_lead_provider)
      .update_all(statement_id: statement.id)
  end

  def then_i_should_see_correct_statement_summary
    then_i_should_see_correct_overall_payments
    then_i_should_see_correct_cut_off_date
    then_i_should_see_correct_overall_declarations
  end

  def then_i_should_see_correct_overall_payments
    within(".app-application__panel__summary") do
      expect(page).to have_content("Output payment #{number_to_pounds total_output_payment}")
      expect(page).to have_content("Service fee #{number_to_pounds total_service_fees_monthly}")
      expect(page).to have_content("VAT #{number_to_pounds overall_vat}")
    end
  end

  def then_i_should_see_correct_cut_off_date
    within(".app-application__panel__summary") do
      expect(page).to have_content(statement.deadline_date.to_s(:govuk))
    end
  end

  def then_i_should_see_correct_overall_declarations
    within(".app-application__panel__summary") do
      expect(page).to have_content("Total starts")
      expect(page).to have_content(total_starts)
      expect(page).to have_content("Total retained")
      expect(page).to have_content(total_retained)
      expect(page).to have_content("Total completed")
      expect(page).to have_content(total_completed)
      expect(page).to have_content("Total voids")
      expect(page).to have_content(total_voided)
    end
  end

  def then_i_should_see_correct_output_payment_breakdown
    within first(".app-application__card") do
      expect(page).to have_css("tr:nth-child(1) td:nth-child(1)", text: "Output payment")
      expect(page).to have_css("tr:nth-child(1) td:nth-child(2)", text: total_declarations(npq_leading_behaviour_culture_contract))
      expect(page).to have_css("tr:nth-child(1) td:nth-child(3)", text: number_to_pounds(160))
      expect(page).to have_css("tr:nth-child(1) td:nth-child(4)", text: number_to_pounds(1440))
    end
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

  def then_i_should_see_correct_course_summary
    within first(".app-application-card__header") do
      expect(page).to have_content("Started")
      expect(page).to have_content(total_participants_for(npq_specialist_schedule.milestones.first))
      expect(page).to have_content("Total declarations")
      expect(page).to have_content(total_declarations(npq_leading_behaviour_culture_contract))
    end
  end

  def when_i_click_on_view_within_statement_summary
    within(".app-application__panel__summary") do
      when_i_click_on("View")
    end
  end

  def then_i_see_voided_declarations
    first("table") do
      expect(page).to have_css("tr", count: 4) # headers + (3 * 1) # 1 for each of the 3 courses
    end
  end

  def then_i_should_see_correct_service_fee_payment_breakdown
    within first(".app-application__card") do
      expect(page).to have_css("tr:nth-child(2) td:nth-child(1)", text: "Service fee")
      expect(page).to have_css("tr:nth-child(2) td:nth-child(2)", text: npq_leading_behaviour_culture_contract.recruitment_target)
      expect(page).to have_css("tr:nth-child(2) td:nth-child(3)", text: number_to_pounds(16.84))
      expect(page).to have_css("tr:nth-child(2) td:nth-child(4)", text: number_to_pounds(1_212.63))
    end
  end

  def then_i_should_see_the_correct_total
    within first(".app-application__card") do
      expect(page).to have_content("Course total")
      expect(page).to have_content(number_to_pounds(2_652.63))
    end
  end

  def when_i_click_on(string)
    click_link_or_button string
  end

  def when_i_click_on_view_contract
    find("span", text: "Contract Information").click
  end

  def then_i_see_contract_information
    within first(".govuk-details__text") do
      expect(page).to have_content(npq_course_leading_teaching.identifier)
      expect(page).to have_content(npq_leading_teaching_contract.recruitment_target)
    end
  end

  def participants_per_declaration_type
    statement.participant_declarations.for_course_identifier(npq_leading_behaviour_culture_contract.course_identifier).paid_payable_or_eligible.group(:declaration_type).count
  end

  def total_participants_for(milestone)
    participants_per_declaration_type.fetch(milestone.declaration_type, 0)
  end

  def output_payment
    PaymentCalculator::NPQ::OutputPayment.call(contract: npq_leading_behaviour_culture_contract, total_participants: total_declarations(npq_leading_behaviour_culture_contract))
  end

  def service_fees
    PaymentCalculator::NPQ::ServiceFees.call(contract: npq_leading_behaviour_culture_contract)
  end

  def contracts
    npq_lead_provider.npq_contracts
  end

  def output_payment_per_contract
    contracts.map { |contract| PaymentCalculator::NPQ::OutputPayment.call(contract: contract, total_participants: statement_declarations_per_contract(contract)) }
  end

  def service_fees_per_contract
    contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract: contract) }.compact
  end

  def total_service_fees_monthly
    service_fees_per_contract.sum { |service_fee| service_fee[:monthly] }
  end

  def total_output_payment
    output_payment_per_contract.sum { |output_payment| output_payment[:subtotal] }
  end

  def total_payment
    total_service_fees_monthly + total_output_payment
  end

  def overall_vat
    total_payment * (npq_lead_provider.vat_chargeable ? 0.2 : 0.0)
  end

  def overall_total
    total_payment + overall_vat
  end

  def statement_declarations_per_contract(contract)
    statement
      .participant_declarations
      .for_course_identifier(contract.course_identifier)
      .unique_id
      .count
  end

  def total_starts
    statement_declarations.started.count
  end

  def statement_declarations
    statement.participant_declarations
  end

  def total_retained
    statement_declarations.retained.count
  end

  def total_completed
    statement_declarations.completed.count
  end

  def total_voided
    voided_declarations.count
  end

  def voided_declarations
    statement.voided_participant_declarations.unique_id
  end

  def total_declarations(contract)
    statement
      .participant_declarations
      .for_course_identifier(contract.course_identifier)
      .unique_id
      .count
  end
end
