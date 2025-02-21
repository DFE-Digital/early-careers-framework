# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", type: :feature, js: true do
  include FinanceHelper
  include ActionView::Helpers::NumberHelper

  let!(:lead_provider) { create(:lead_provider, name: "Test provider", id: "cffd2237-c368-4044-8451-68e4a4f73369") }
  let(:cpd_lead_provider) { lead_provider.cpd_lead_provider }
  let!(:contract) { create(:call_off_contract, lead_provider:, version: "0.0.1", cohort: Cohort.current) }
  let!(:mentor_contract) { create(:mentor_call_off_contract, lead_provider:, version: "0.0.1", cohort: Cohort.current) }
  let(:current_start_year) { Cohort.current.start_year }
  let(:next_start_year) { Cohort.next.start_year }
  let(:voided_declarations) { create_list(:ect_participant_declaration, 2, :eligible, :voided, cpd_lead_provider:) }
  let(:clawed_back_declarations) { create_list(:ect_participant_declaration, 3, :eligible, cpd_lead_provider:).each(&:clawed_back!) }

  let!(:january_statement) { create(:ecf_statement, name: "January #{next_start_year}", deadline_date: Date.new(next_start_year, 1, 31), cpd_lead_provider:, contract_version: contract.version) }
  let!(:november_statement) { create(:ecf_statement, name: "November #{current_start_year}", deadline_date: Date.new(current_start_year, 11, 30), cpd_lead_provider:, contract_version: contract.version) }

  let(:jan_statement_calculator) { Finance::ECF::StatementCalculator.new(statement: january_statement) }
  let(:nov_statement_ect_calculator) { Finance::ECF::ECT::StatementCalculator.new(statement: november_statement) }
  let(:nov_statement_mentor_calculator) { Finance::ECF::Mentor::StatementCalculator.new(statement: november_statement) }

  scenario "Can get to ECF payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_a_schedule
    and_multiple_declarations_are_submitted
    and_voided_payable_declarations_are_submitted
    and_clawed_back_declarations_exist
    when_i_click_on_payment_breakdown_header
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

    then_i_should_see_the_total_extended
    then_i_should_see_the_total_voided
    then_i_should_see_the_total_clawed_back
    click_link("View voided declarations")
    then_i_see_voided_declarations
    and_the_page_should_be_accessible
  end

  scenario "Mentor funding payment breakdown page" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_a_schedule
    and_multiple_declarations_are_submitted
    and_multiple_started_declarations_exists
    and_multiple_clawback_declarations_exists
    and_voided_payable_declarations_are_submitted
    and_cohort_has_mentor_funding_enabled
    and_additional_adjustments_exist

    when_i_visit_the_ecf_financial_statements_page
    then_i_should_see_mentor_funding_breakdown_summary
    then_i_should_see_mentor_funding_output_payments
    then_i_should_see_mentor_funding_clawbacks
    then_i_should_see_mentor_funding_adjustments

    when_i_click_on_view_mentor_funding_contract_link
    then_i_see_mentor_funding_contract_information
  end

private

  def then_i_should_see_the_total_voided
    expect(page.find("strong", text: "Total voided")).to have_sibling("div", text: voided_declarations.size)
  end

  def then_i_should_see_the_total_clawed_back
    expect(page.find("strong", text: "Total clawed back")).to have_sibling("div", text: clawed_back_declarations.size)
  end

  def then_i_should_see_the_total_extended
    extended_declarations = ParticipantDeclaration.extended
    expect(page.find("strong", text: "Total extended")).to have_sibling("div", text: extended_declarations.count)
    expect(page).to have_content("Extended")
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

  def multiple_extended_declarations_are_submitted_nov_statement
    travel_to(november_statement.deadline_date) do
      create_list(:mentor_participant_declaration, 3, :extended, cpd_lead_provider:)
      create_list(:ect_participant_declaration, 4, :extended, cpd_lead_provider:)
    end
  end

  def and_multiple_declarations_are_submitted
    multiple_start_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_jan_statement
    multiple_ineligible_declarations_are_submitted_jan_statement
    multiple_extended_declarations_are_submitted_nov_statement
  end

  def and_multiple_started_declarations_exists
    travel_to(november_statement.deadline_date) do
      create_list(:ect_participant_declaration, 2, :eligible, declaration_type: "started", cpd_lead_provider:)
      create_list(:mentor_participant_declaration, 2, :eligible, declaration_type: "started", cpd_lead_provider:)
    end
  end

  def and_multiple_clawback_declarations_exists
    declarations = create_list(
      :ect_participant_declaration, 2,
      :eligible,
      cpd_lead_provider:,
      declaration_type: "started",
      state: "awaiting_clawback",
      cohort: Cohort.current
    )
    declarations += create_list(
      :mentor_participant_declaration, 2,
      :eligible,
      cpd_lead_provider:,
      declaration_type: "started",
      state: "awaiting_clawback",
      cohort: Cohort.current
    )

    declarations.each do |dec|
      item = Finance::StatementLineItem.find_or_initialize_by(statement: november_statement, participant_declaration: dec)
      item.update!(state: dec.state)
    end
  end

  def and_voided_payable_declarations_are_submitted
    travel_to(november_statement.deadline_date) { voided_declarations }
  end

  def and_clawed_back_declarations_exist
    travel_to(november_statement.deadline_date) { clawed_back_declarations }
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
      expect(page).to have_content(january_statement.deadline_date.to_fs(:govuk))
    end
  end

  def then_i_should_see_mentor_funding_breakdown_summary
    expect(page).to have_css(".govuk-caption-l", text: lead_provider.name)

    within ".finance-panel__dates" do
      expect(page).to have_content("Milestone cut off date")
      expect(page).to have_content(november_statement.deadline_date.to_fs(:govuk))

      expect(page).to have_content("Payment date")
      expect(page).to have_content(november_statement.payment_date.to_fs(:govuk))
    end

    within ".finance-panel__summary__total-payment-breakdown h4" do
      total = nov_statement_ect_calculator.total(with_vat: true) +
        nov_statement_mentor_calculator.total(with_vat: true)
      expect(page).to have_content(number_to_pounds(total))
    end

    breakdown = page.all(".finance-panel__summary__total-payment-breakdown p").map do |row|
      val = row.find("span").text.strip
      key = row.text.gsub(val, "").strip
      [key, val]
    end

    expect(breakdown[0]).to eq([
      "ECTs output payment",
      number_to_pounds(nov_statement_ect_calculator.output_fee),
    ])

    expect(breakdown[1]).to eq([
      "Mentors output payment",
      number_to_pounds(nov_statement_mentor_calculator.output_fee),
    ])

    expect(breakdown[2]).to eq([
      "Service fee",
      number_to_pounds(service_fee_total),
    ])

    expect(breakdown[3]).to eq([
      "ECT clawbacks",
      number_to_pounds(-nov_statement_ect_calculator.clawback_deductions),
    ])

    expect(breakdown[4]).to eq([
      "Mentor clawbacks",
      number_to_pounds(-nov_statement_mentor_calculator.clawback_deductions),
    ])

    expect(breakdown[5]).to eq([
      "Additional adjustments",
      number_to_pounds(nov_statement_ect_calculator.additional_adjustments_total),
    ])

    vat = nov_statement_ect_calculator.vat + nov_statement_mentor_calculator.vat
    expect(breakdown[6]).to eq([
      "VAT",
      number_to_pounds(vat),
    ])

    counts = page.all(".finance-panel__summary__counts .govuk-table tr").map do |row|
      row.all("th, td").map { |v| v.text.strip.to_s.split.first }
    end

    expect(counts[1]).to eq(%w[ECTs 2 4 0 4 2])
    expect(counts[2]).to eq(["Mentors", "2", "-", "0", "-", "0"])
  end

  def then_i_should_see_mentor_funding_output_payments
    title = page.all(".finance-panel__output-payments .govuk-table")[0].find("caption").text
    expect(title).to eq("Early career teacher (ECT) output payments")

    ect_outputs = page.all(".finance-panel__output-payments .govuk-table")[0].all("tr").map do |row|
      row.all("th, td").map { |v| v.text.strip }
    end

    expect(ect_outputs[1]).to eq(["Starts", "2", "0", "0", ""])
    expect(ect_outputs[2]).to eq(["Fee per ECT", "£119.40", "£117.48", "£115.92", "£238.80"])

    title = page.all(".finance-panel__output-payments .govuk-table")[1].find("caption").text
    expect(title).to eq("Mentor output payments")

    mentor_outputs = page.all(".finance-panel__output-payments .govuk-table")[1].all("tr").map do |row|
      row.all("th, td").map { |v| v.text.strip }
    end

    expect(mentor_outputs[1]).to eq(["Starts", "2", ""])
    expect(mentor_outputs[2]).to eq(["Fee per mentor", "£500.00", "£1,000.00"])
  end

  def then_i_should_see_mentor_funding_clawbacks
    title = page.all(".finance-panel__clawbacks .govuk-table")[0].find("caption").text
    expect(title).to eq("ECT clawbacks")

    ect = page.all(".finance-panel__clawbacks .govuk-table")[0].all("tr").map do |row|
      row.all("th, td").map { |v| v.text.strip }
    end

    expect(ect[1]).to eq(["Clawback for Started (Band: A)", "2", "-£119.40", "-£238.80"])

    title = page.all(".finance-panel__clawbacks .govuk-table")[1].find("caption").text
    expect(title).to eq("Mentor clawbacks")

    mentor = page.all(".finance-panel__clawbacks .govuk-table")[1].all("tr").map do |row|
      row.all("th, td").map { |v| v.text.strip }
    end

    expect(mentor[1]).to eq(["Clawback for Started", "2", "-£500.00", "-£1,000.00"])
  end

  def then_i_should_see_mentor_funding_adjustments
    within ".finance-panel__adjustments" do
      expect(page).to have_content("Additional adjustments")
      expect(page).to have_content("Big amount")
      expect(page).to have_content("Another amount")
    end
  end

  def then_i_should_see_the_correct_payment_summary
    within ".finance-panel__summary" do
      expect(page).to have_content(number_to_pounds(total_payment_with_vat))

      expect(page).to have_content("Output payment")
      expect(page).to have_content(number_to_pounds(output_payment_total))

      expect(page).to have_content("Service fee")
      expect(page).to have_content(number_to_pounds(service_fee_total))

      expect(page).to have_content("VAT")
      expect(page).to have_content(number_to_pounds(total_vat))
    end
  end

  def then_i_should_see_the_correct_output_fees
    expect(page).to have_content("Output payments")
    expect(page).to have_content(number_to_pounds(jan_statement_calculator.additions_for_started))
    expect(page).to have_content(jan_statement_calculator.started_count)
    expect(page).to have_content(number_to_pounds(jan_statement_calculator.output_fee))

    expect(page).to_not have_content("Extended")
  end

  def then_i_should_see_the_correct_uplift_fee
    expect(page).to have_content("Uplift fee")
    expect(page).to have_content(number_to_pounds(jan_statement_calculator.uplift_additions_count))
    expect(page).to have_content(number_to_pounds(jan_statement_calculator.uplift_fee_per_declaration))
    expect(page).to have_content(number_to_pounds(jan_statement_calculator.uplift_additions_count * jan_statement_calculator.uplift_fee_per_declaration))
  end

  def service_fee_total
    jan_statement_calculator.service_fee
  end

  def output_payment_total
    jan_statement_calculator.output_fee
  end

  def total_vat
    jan_statement_calculator.vat
  end

  def total_payment_with_vat
    jan_statement_calculator.total(with_vat: true)
  end

  def and_there_is_a_schedule
    create(:ecf_schedule)
    create(:ecf_extended_schedule)
  end

  def when_i_click_on_payment_breakdown_header
    click_on "View financial statements"
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{november_statement.id}")
  end

  def when_i_select_a_provider
    choose option: "cffd2237-c368-4044-8451-68e4a4f73369", allow_label_click: true
  end

  def when_i_click_on_view_contract_link
    find("summary", text: I18n.t("finance.contract_information")).click
  end

  def when_i_click_on_view_mentor_funding_contract_link
    find("summary", text: I18n.t("finance.statements.contracts.ect_mentor.link_text")).click
  end

  def then_i_see_contract_information
    expect(page).to have_content("Recruitment target #{contract.recruitment_target}")
  end

  def then_i_see_mentor_funding_contract_information
    within "details.contract-information" do
      expect(page).to have_content("ECTs recruitment target #{contract.recruitment_target}")
      expect(page).to have_content("Mentors recruitment target #{contract.recruitment_target}")
    end
  end

  def and_cohort_has_mentor_funding_enabled
    Cohort.current.update!(mentor_funding: true)
  end

  def and_additional_adjustments_exist
    create :adjustment, statement: november_statement, payment_type: "Big amount", amount: 999.99
    create :adjustment, statement: november_statement, payment_type: "Another amount", amount: 300.0
  end
end
