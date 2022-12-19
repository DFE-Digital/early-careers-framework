# frozen_string_literal: true

require "rails_helper"

RSpec.feature "NPQ Course payment breakdown", :with_default_schedules, type: :feature, js: true do
  include FinanceHelper

  let(:cohort) { Cohort[2021] || create(:cohort, start_year: 2021) }

  let!(:npq_leadership_schedule) { create(:npq_leadership_schedule, cohort:) }
  let!(:npq_specialist_schedule) { create(:npq_specialist_schedule, cohort:) }

  let(:cpd_lead_provider) { create(:cpd_lead_provider, name: "Lead Provider") }
  let(:npq_lead_provider) { create(:npq_lead_provider, cpd_lead_provider:, name: "NPQ Lead Provider") }

  let!(:npq_leading_teaching_contract) { create(:npq_contract, :npq_leading_teaching, npq_lead_provider:, npq_course: npq_course_leading_teaching, cohort:) }
  let!(:npq_leading_behaviour_culture_contract) { create(:npq_contract, :npq_leading_behaviour_culture, npq_lead_provider:, npq_course: npq_course_leading_behaviour_culture, cohort:) }
  let!(:npq_leading_teaching_development_contract) { create(:npq_contract, :npq_leading_teaching_development, npq_lead_provider:, npq_course: npq_course_leading_teaching_development, cohort:) }

  let(:npq_course_leading_teaching) { create(:npq_course, identifier: "npq-leading-teaching", name: "Leading Teaching") }
  let(:npq_course_leading_behaviour_culture) { create(:npq_course, identifier: "npq-leading-behaviour-culture", name: "Leading Behaviour Culture") }
  let(:npq_course_leading_teaching_development) { create(:npq_course, identifier: "npq-leading-teaching-development", name: "Leading Teaching Development") }

  let!(:statement) do
    create(
      :npq_statement,
      name: "January 2022",
      deadline_date: Date.new(2022, 1, 31),
      payment_date: Date.new(2022, 2, 16),
      cpd_lead_provider:,
      contract_version: npq_leading_teaching_contract.version,
      cohort:,
    )
  end

  let(:cohort_2022) { Cohort[2022] }

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

    expect(page)
      .to have_link("Download declarations (CSV)", href: finance_npq_statement_assurance_report_path(statement, format: :csv))

    when_i_click_on_view_within_statement_summary
    then_i_see_voided_declarations
    when_i_click "Back"
    when_i_click_on_view_contract
    then_i_see_contract_information
    and_the_page_should_be_accessible
  end

  scenario "Duplicate NPQ contract with cohort 2022" do
    given_i_am_logged_in_as_a_finance_user
    and_those_courses_have_submitted_declarations
    and_a_duplicate_npq_contract_exists
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider

    then_we_should_not_see_duplicate_courses
  end

  context "Targeted delivery funding" do
    let(:cohort) { Cohort[2022] || create(:cohort, start_year: 2022) }

    scenario "see payment breakdown with targeted delivery funding" do
      given_i_am_logged_in_as_a_finance_user
      and_those_courses_have_submitted_declarations
      and_there_are_targeted_delivery_funding_declarations
      when_i_visit_the_payment_breakdown_page
      and_choose_to_see_npq_payment_breakdown
      and_i_select_an_npq_lead_provider

      then_i_should_see_correct_statement_summary
      then_i_should_see_correct_course_summary
      then_i_should_see_correct_output_payment_breakdown
      then_i_should_see_correct_service_fee_payment_breakdown_below_targeted_delivery_funding
      then_i_should_see_correct_targeted_delivery_funding_breakdown
      then_i_should_see_the_correct_total_including_targeted_delivery_funding
      and_the_page_should_be_accessible
    end
  end

  def and_a_duplicate_npq_contract_exists
    contract1 = statement.npq_lead_provider.npq_contracts.first
    statement.npq_lead_provider.npq_contracts.create!(
      cohort: cohort_2022,
      version: contract1.version,
      recruitment_target: contract1.recruitment_target,
      course_identifier: contract1.course_identifier,
      service_fee_installments: contract1.service_fee_installments,
      service_fee_percentage: contract1.service_fee_percentage,
      per_participant: contract1.per_participant,
      number_of_payment_periods: contract1.number_of_payment_periods,
      output_payment_percentage: contract1.output_payment_percentage,
      monthly_service_fee: contract1.monthly_service_fee,
    )
  end

  def then_we_should_not_see_duplicate_courses
    course_titles = page.all("section.app-application__card h2").map(&:text)
    expect(course_titles.count).to eql(course_titles.uniq.count)
  end

  def create_accepted_application(user, npq_course, npq_lead_provider)
    Identity::Create.call(user:, origin: :npq)
    npq_application = NPQ::BuildApplication.call(
      npq_application_params: attributes_for(:npq_application, cohort: cohort.start_year),
      npq_course_id: npq_course.id,
      npq_lead_provider_id: npq_lead_provider.id,
      user_id: user.id,
    )
    npq_application.save!
    NPQ::Application::Accept.new(npq_application:).call
    npq_application
  end

  def create_started_declarations(npq_application)
    timestamp = npq_application.profile.schedule.milestones.order(start_date: :asc).first.start_date + 1.day
    travel_to(timestamp) do
      RecordDeclaration.new(
        participant_id: npq_application.participant_identity.external_identifier,
        course_identifier: npq_application.npq_course.identifier,
        declaration_date: timestamp.rfc3339,
        cpd_lead_provider: npq_application.npq_lead_provider.cpd_lead_provider,
        declaration_type: "started",
      ).call
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
        .each(&:make_eligible!)

      create_list(:user, 1)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .each(&:make_voided!)

      create_list(:user, 2)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .each(&:make_ineligible!)

      create_list(:user, 5)
        .map { |user| create_accepted_application(user, npq_course, npq_lead_provider) }
        .map { |npq_application| create_started_declarations(npq_application) }
        .map { |participant_declaration| participant_declaration.tap(&:make_eligible!) }
        .each(&:make_payable!)
    end

    ParticipantDeclaration::NPQ
      .where(state: %w[ineligible voided eligible payable])
      .each do |declaration|
        Finance::StatementLineItem.create(
          statement: declaration.cpd_lead_provider.npq_lead_provider.statements.first,
          participant_declaration: declaration,
          state: declaration.state,
        )
      end
  end

  def and_there_are_targeted_delivery_funding_declarations
    user = create(:user)
    npq_application = create_accepted_application(user, npq_course_leading_behaviour_culture, npq_lead_provider)
    npq_application.eligible_for_funding = true
    npq_application.targeted_delivery_funding_eligibility = true
    npq_application.save!
    participant_declaration = create_started_declarations(npq_application)
    participant_declaration.make_eligible!
    participant_declaration.make_payable!
    @targeted_delivery_funding_declarations_count = 1
  end

  def then_i_should_see_correct_statement_summary
    then_i_should_see_correct_overall_payments
    then_i_should_see_correct_cut_off_date
    then_i_should_see_correct_overall_declarations
  end

  def then_i_should_see_correct_overall_payments
    within(".app-application__panel__summary") do
      expect(page).to have_content("Output payment\n#{number_to_pounds total_output_payment}")
      expect(page).to have_content("Service fee\n#{number_to_pounds total_service_fees_monthly}")
      expect(page).to have_content("VAT\n#{number_to_pounds overall_vat}")
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
      expect(page).to have_css("tr:nth-child(1) td:nth-child(3)", text: number_to_pounds(162))
      expect(page).to have_css("tr:nth-child(1) td:nth-child(4)", text: number_to_pounds(total_declarations(npq_leading_behaviour_culture_contract) * 162.0))
    end
  end

  def when_i_visit_the_payment_breakdown_page
    click_on "View financial statements"
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
      expect(page).to have_css("tr:nth-child(2) td:nth-child(3)", text: number_to_pounds(17.05))
      expect(page).to have_css("tr:nth-child(2) td:nth-child(4)", text: number_to_pounds(1_227.79))
    end
  end

  def then_i_should_see_correct_service_fee_payment_breakdown_below_targeted_delivery_funding
    within first(".app-application__card") do
      expect(page).to have_css("tr:nth-child(3) td:nth-child(1)", text: "Service fee")
      expect(page).to have_css("tr:nth-child(3) td:nth-child(2)", text: npq_leading_behaviour_culture_contract.recruitment_target)
      expect(page).to have_css("tr:nth-child(3) td:nth-child(3)", text: number_to_pounds(17.05))
      expect(page).to have_css("tr:nth-child(3) td:nth-child(4)", text: number_to_pounds(1_227.79))
    end
  end

  def then_i_should_see_correct_targeted_delivery_funding_breakdown
    within first(".app-application__card") do
      expect(page).to have_css("tr:nth-child(2) td:nth-child(1)", text: "Targeted delivery funding")
      expect(page).to have_css("tr:nth-child(2) td:nth-child(2)", text: 1)
      expect(page).to have_css("tr:nth-child(2) td:nth-child(3)", text: number_to_pounds(100.0))
      expect(page).to have_css("tr:nth-child(2) td:nth-child(4)", text: number_to_pounds(100.0))
    end
  end

  def then_i_should_see_the_correct_total
    within first(".app-application__card") do
      expect(page).to have_content("Course total")
      expect(page).to have_content(number_to_pounds(1_458 + 1_227.79))
    end
  end

  def then_i_should_see_the_correct_total_including_targeted_delivery_funding
    within first(".app-application__card") do
      expect(page).to have_content("Course total")
      expect(page).to have_content(number_to_pounds(1_620 + 100 + 1_227.79))
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
    statement
      .participant_declarations
      .for_course_identifier(npq_leading_behaviour_culture_contract.course_identifier)
      .paid_payable_or_eligible
      .group(:declaration_type)
      .count
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
    contracts.map { |contract| PaymentCalculator::NPQ::OutputPayment.call(contract:, total_participants: statement_declarations_per_contract(contract)) }
  end

  def service_fees_per_contract
    contracts.map { |contract| PaymentCalculator::NPQ::ServiceFees.call(contract:) }.compact
  end

  def total_service_fees_monthly
    service_fees_per_contract.sum { |service_fee| service_fee[:monthly] }
  end

  def total_output_payment
    output_payment_per_contract.sum { |output_payment| output_payment[:subtotal] }
  end

  def total_targeted_delivery_funding
    @targeted_delivery_funding_declarations_count.to_i * contracts.first.targeted_delivery_funding_per_participant
  end

  def total_payment
    total_service_fees_monthly + total_output_payment + total_targeted_delivery_funding
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
      .where(state: %w[eligible payable paid])
      .for_course_identifier(contract.course_identifier)
      .unique_id
      .count
  end

  def total_starts
    statement
      .billable_statement_line_items
      .joins(:participant_declaration)
      .where(participant_declarations: { declaration_type: "started" })
      .count
  end

  def statement_declarations
    statement.billable_participant_declarations
  end

  def total_retained
    statement
      .billable_statement_line_items
      .joins(:participant_declaration)
      .where(participant_declarations: { declaration_type: %w[retained-1 retained-2] })
      .count
  end

  def total_completed
    statement
      .billable_statement_line_items
      .joins(:participant_declaration)
      .where(participant_declarations: { declaration_type: "completed" })
      .count
  end

  def total_voided
    voided_declarations.count
  end

  def voided_declarations
    statement.participant_declarations.voided.unique_id
  end

  def total_declarations(contract)
    statement
      .billable_statement_line_items
      .joins(:participant_declaration)
      .where(participant_declaration: { course_identifier: contract.course_identifier })
      .count
  end
end
