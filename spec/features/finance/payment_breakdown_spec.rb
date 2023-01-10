# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", :with_default_schedules, type: :feature, js: true do
  include FinanceHelper
  include ActionView::Helpers::NumberHelper

  let!(:lead_provider)         { create(:lead_provider, name: "Test provider", id: "cffd2237-c368-4044-8451-68e4a4f73369") }
  let(:cpd_lead_provider)      { lead_provider.cpd_lead_provider }
  let!(:contract)              { create(:call_off_contract, lead_provider:, version: "0.0.1", cohort: Cohort.current) }
  let(:current_start_year)     { Cohort.current.start_year }
  let(:next_start_year)        { Cohort.next.start_year }
  let(:voided_declarations)    { create_list(:ect_participant_declaration, 2, :eligible, :voided, cpd_lead_provider:) }
  let(:participant_aggregator_nov) do
    Finance::ECF::ParticipantAggregator.new(
      statement: november_statement,
      recorder: ParticipantDeclaration::ECF.where(state: %w[paid payable eligible]),
    )
  end
  let(:participant_aggregator_jan) do
    Finance::ECF::ParticipantAggregator.new(
      statement: january_statement,
      recorder: ParticipantDeclaration::ECF.where(state: %w[paid payable eligible]),
    )
  end

  let!(:january_statement)  { create(:ecf_statement, name: "January #{next_start_year}", deadline_date: Date.new(next_start_year, 1, 31), cpd_lead_provider:, contract_version: contract.version) }
  let!(:november_statement) { create(:ecf_statement, name: "November #{current_start_year}", deadline_date: Date.new(current_start_year, 11, 30), cpd_lead_provider:, contract_version: contract.version) }

  let(:jan_starts_breakdowns) do
    Finance::ECF::CalculationOrchestrator.new(
      statement: january_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_jan,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :started)
  end

  let(:jan_retained_breakdowns) do
    Finance::ECF::CalculationOrchestrator.new(
      statement: january_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_jan,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :retained_1)
  end
  scenario "Can get to ECF payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_multiple_declarations_are_submitted
    and_voided_payable_declarations_are_submitted
    when_i_click_on_payment_breakdown_header
    then_the_page_should_be_accessible

    when_i_select_ecf
    and_i_click_the_continue_button
    then_the_page_should_be_accessible

    when_i_select_a_provider
    and_i_click_the_continue_button
    then_i_should_see_correct_breakdown_summary
    then_i_should_see_the_correct_payment_summary
    then_i_should_see_the_correct_output_fees
    then_i_should_see_the_correct_uplift_fee
    and_the_page_should_be_accessible

    when_i_click_on_view_contract_link
    then_i_see_contract_information

    select("November #{current_start_year}", from: "statement-field")
    click_button("View")

    expect(page)
      .to have_link("Download declarations (CSV)", href: finance_ecf_statement_assurance_report_path(november_statement, format: :csv))

    then_i_should_see_the_total_voided
    click_link("View voided declarations")
    then_i_see_voided_declarations
    and_the_page_should_be_accessible
  end

private

  def then_i_should_see_the_total_voided
    expect(page.find("strong", text: "Total voided")).to have_sibling("div", text: voided_declarations.size)
  end

  def then_i_see_voided_declarations
    within first("table tbody") do
      voided_declarations.each do |participant_declaration|
        declaration_id_cell =  page.find("tr td", text: participant_declaration.id)
        expect(declaration_id_cell).to have_sibling("td", text: participant_declaration.user_id)
        expect(declaration_id_cell).to have_sibling("td", text: participant_declaration.declaration_type)
        expect(declaration_id_cell).to have_sibling("td", text: participant_declaration.course_identifier)
      end
    end
  end

  def multiple_start_declarations_are_submitted_nov_statement
    travel_to november_statement.deadline_date do
      create_list(:ect_participant_declaration, 4, cpd_lead_provider:)
    end
  end

  def multiple_retained_declarations_are_submitted_nov_statement
    travel_to november_statement.deadline_date do
      create_list(:ect_participant_declaration,
                  4,
                  :eligible,
                  declaration_type: "retained-1",
                  cpd_lead_provider:)
    end
  end

  def multiple_ineligible_declarations_are_submitted_jan_statement
    travel_to january_statement.deadline_date do
      create_list(:ect_participant_declaration, 3, :ineligible, cpd_lead_provider:)
    end
  end

  def multiple_retained_declarations_are_submitted_jan_statement
    travel_to january_statement.deadline_date do
      create_list(:mentor_participant_declaration, 5, :eligible, uplifts: [:sparsity_uplift], declaration_type: "retained-1", cpd_lead_provider:)
      create_list(:ect_participant_declaration,    6, :eligible, uplifts: [:sparsity_uplift], declaration_type: "retained-1", cpd_lead_provider:)
    end
  end

  def and_multiple_declarations_are_submitted
    multiple_start_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_jan_statement
    multiple_ineligible_declarations_are_submitted_jan_statement
  end

  def and_voided_payable_declarations_are_submitted
    travel_to(november_statement.deadline_date) { voided_declarations }
  end

  def create_start_declarations_nov(participant)
    timestamp = participant.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      s = RecordDeclaration.new(
        participant_id: participant.user.id,
        course_identifier: "ecf-induction",
        declaration_date: (participant.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        declaration_type: "started",
        evidence_held: "other",
      )

      s.call
        .tap(&:make_eligible!)
        .tap(&:make_payable!)
    end
  end

  def create_voided_declarations_nov(participant)
    timestamp = participant.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      RecordDeclaration.new(
        participant_id: participant.user.id,
        course_identifier: "ecf-induction",
        declaration_date: (participant.schedule.milestones.first.start_date + 1.day).rfc3339,
        cpd_lead_provider: lead_provider.cpd_lead_provider,
        declaration_type: "started",
        evidence_held: "other",
      ).call
        .tap(&:make_eligible!)
        .tap(&:make_payable!)
        .tap(&:make_voided!)
        .tap do |declaration|
        declaration.statement_line_items.first.update!(statement: nov_statement, state: declaration.state)
      end
    end
  end

  def then_i_should_see_correct_breakdown_summary
    expect(page).to have_css(".govuk-caption-l", text: lead_provider.name)
    select("January #{next_start_year}", from: "statement-field")
    click_button("View")

    within ".finance-panel__summary" do
      expect(page).to have_content("Milestone cut off date")
      expect(page).to have_content(january_statement.deadline_date.to_s(:govuk))
    end
  end

  def then_i_should_see_the_correct_payment_summary
    within ".finance-panel__summary" do
      expect(page).to have_content(number_to_pounds(total_payment_with_vat_breakdown))

      expect(page).to have_content("Output payment")
      expect(page).to have_content(number_with_delimiter(output_payment_total))

      expect(page).to have_content("Service fee")
      expect(page).to have_content(number_to_pounds(service_fee_total))

      expect(page).to have_content("VAT")
      expect(page).to have_content(number_to_pounds(total_vat_breakdown))
    end
  end

  def then_i_should_see_the_correct_output_fees
    expect(page).to have_content("Output payments")
    expect(page).to have_content(number_to_pounds(jan_starts_breakdowns[:output_payments][0][:per_participant]))
    expect(page).to have_content(jan_starts_breakdowns[:output_payments][0][:participants])
    expect(page).to have_content(number_to_pounds(jan_starts_breakdowns[:output_payments][0][:subtotal]))
  end

  def then_i_should_see_the_correct_uplift_fee
    expect(page).to have_content("Uplift fee")
    expect(page).to have_content(number_to_pounds(jan_starts_breakdowns[:other_fees][:uplift][:per_participant]))
    expect(page).to have_content(jan_starts_breakdowns[:other_fees][:uplift][:participants])
    expect(page).to have_content(number_to_pounds(jan_starts_breakdowns[:other_fees][:uplift][:subtotal]))
  end

  def number_of_declarations
    jan_starts_breakdowns[:output_payments].map { |params| params[:participants] }.inject(&:+) + jan_retained_breakdowns[:output_payments].map { |params| params[:participants] }.inject(&:+)
  end

  def service_fee_total
    jan_starts_breakdowns[:service_fees].map { |params| params[:monthly] }.inject(&:+)
  end

  def output_payment_total
    jan_starts_breakdowns[:output_payments].map { |params| params[:subtotal] }.inject(&:+) + jan_retained_breakdowns[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
  end

  def total_vat_breakdown
    total_vat_combined(jan_starts_breakdowns, jan_retained_breakdowns, lead_provider)
  end

  def total_payment_with_vat_breakdown
    total_payment_with_vat_combined(jan_starts_breakdowns, jan_retained_breakdowns, lead_provider)
  end

  def total_payment_with_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
    total_payment_combined(breakdown_started, breakdown_retained_1) + total_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
  end

  def total_vat_combined(breakdown_started, breakdown_retained_1, lead_provider)
    total_payment_combined(breakdown_started, breakdown_retained_1) * (lead_provider.vat_chargeable ? 0.2 : 0.0)
  end

  def total_payment_combined(breakdown_started, breakdown_retained_1)
    service_fee = breakdown_started[:service_fees].map { |params| params[:monthly] }.sum
    output_payment = breakdown_started[:output_payments].map { |params| params[:subtotal] }.sum
    other_fees = breakdown_started[:other_fees].values.map { |other_fee| other_fee[:subtotal] }.sum
    retained_output_payment = breakdown_retained_1[:output_payments].map { |params| params[:subtotal] }.sum

    service_fee + output_payment + other_fees + retained_output_payment
  end

  def and_there_is_a_schedule
    create(:ecf_schedule)
  end

  def when_i_click_on_payment_breakdown_header
    click_on "View financial statements"
  end

  def when_i_select_ecf
    choose option: "ecf", allow_label_click: true
  end

  def when_i_select_a_provider
    choose option: "cffd2237-c368-4044-8451-68e4a4f73369", allow_label_click: true
  end

  def when_i_click_on_view_contract_link
    find("summary", text: I18n.t("finance.contract_information")).click
  end

  def then_i_see_contract_information
    expect(page).to have_content("Recruitment target #{contract.recruitment_target}")
  end
end
