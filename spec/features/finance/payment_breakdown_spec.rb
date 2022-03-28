# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", :with_default_schedules, type: :feature, js: true do
  include Finance::ECFPaymentsHelper

  let!(:lead_provider)    { create(:lead_provider, name: "Test provider", id: "cffd2237-c368-4044-8451-68e4a4f73369") }
  let(:cpd_lead_provider) { lead_provider.cpd_lead_provider }
  let!(:statement)        { create(:ecf_statement, cpd_lead_provider: cpd_lead_provider) }
  let!(:contract)         { create(:call_off_contract, lead_provider: lead_provider) }
  let(:school)            { create(:school) }
  let(:cohort)            { create(:cohort, :current) }
  let!(:school_cohort)    { create(:school_cohort, school: school, cohort: cohort) }
  let!(:partnership)      { create(:partnership, school: school_cohort.school, lead_provider: lead_provider, cohort: cohort) }
  let(:nov_statement)     { Finance::Statement::ECF.find_by!(name: "November 2021", cpd_lead_provider: cpd_lead_provider) }
  let(:jan_statement)     { Finance::Statement::ECF.find_by!(name: "January 2022", cpd_lead_provider: cpd_lead_provider) }
  let(:voided_declarations) do
    participant_profiles = create_list(:ect_participant_profile, 2, school_cohort: school_cohort, cohort: cohort, sparsity_uplift: true)
    participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    participant_profiles.map { |participant| create_voided_declarations_nov(participant) }
  end
  let(:participant_aggregator_nov) do
    Finance::ECF::ParticipantAggregator.new(
      statement: nov_statement,
      recorder: ParticipantDeclaration::ECF.where(state: %w[paid payable eligible]),
    )
  end
  let(:participant_aggregator_jan) do
    Finance::ECF::ParticipantAggregator.new(
      statement: jan_statement,
      recorder: ParticipantDeclaration::ECF.where(state: %w[paid payable eligible]),
    )
  end

  before { Importers::SeedStatements.new.call }

  scenario "Can get to ECF payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_multiple_declarations_are_submitted
    and_voided_payable_declarations_are_submitted
    and_breakdowns_are_calculated
    when_i_click_on_payment_breakdown_header
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named("Payment breakdown select programme")

    when_i_select_ecf
    when_i_click_the_submit_button
    then_the_page_should_be_accessible
    then_percy_should_be_sent_a_snapshot_named("Payment breakdown select ECF provider")

    when_i_select_a_provider
    when_i_click_the_submit_button
    then_i_should_see_correct_breakdown_summary
    then_i_should_see_the_correct_payment_summary
    then_i_should_see_the_correct_service_fees
    then_i_should_see_the_correct_output_fees
    then_i_should_see_the_correct_uplift_fee
    and_the_page_should_be_accessible

    when_i_click_on_view_contract_link
    then_the_page_should_be_accessible

    click_link("Back")
    then_the_page_should_be_accessible

    click_link("November 2021")
    click_link("View voided declarations")
    then_i_see_voided_declarations
    and_the_page_should_be_accessible
  end

private

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
    participant_profiles = create_list(:ect_participant_profile, 4, school_cohort: school_cohort, cohort: cohort, sparsity_uplift: true)
    participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    participant_profiles.map { |participant| create_start_declarations_nov(participant) }
  end

  def multiple_retained_declarations_are_submitted_nov_statement
    participant_profiles = create_list(:ect_participant_profile, 4, school_cohort: school_cohort, cohort: cohort)
    participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    participant_profiles.map { |participant| create_retained_declarations_nov(participant) }
  end

  def multiple_ineligible_declarations_are_submitted_jan_statement
    participant_profiles = create_list(:ect_participant_profile, 3, school_cohort: school_cohort, cohort: cohort)
    participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    participant_profiles.map { |participant| create_ineligible_declarations_jan(participant) }
  end

  def multiple_retained_declarations_are_submitted_jan_statement
    mentor_participant_profiles = create_list(:mentor_participant_profile, 5, school_cohort: school_cohort, cohort: cohort, sparsity_uplift: true)
    mentor_participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    mentor_participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    mentor_participant_profiles.map { |participant| create_retained_declarations_jan_mentor(participant) }
    participant_profiles = create_list(:ect_participant_profile, 6, school_cohort: school_cohort, cohort: cohort)
    participant_profiles.map { |participant| ParticipantProfileState.create!(participant_profile: participant) }
    participant_profiles.map { |participant| ECFParticipantEligibility.create!(participant_profile_id: participant.id).eligible_status! }
    participant_profiles.map { |participant| create_retained_declarations_jan_ect(participant) }
  end

  def and_multiple_declarations_are_submitted
    multiple_start_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_nov_statement
    multiple_retained_declarations_are_submitted_jan_statement
    multiple_ineligible_declarations_are_submitted_jan_statement
  end

  def and_voided_payable_declarations_are_submitted
    voided_declarations
  end

  def create_start_declarations_nov(participant)
    timestamp = participant.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Started::EarlyCareerTeacher.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-induction",
          declaration_date: (participant.schedule.milestones.first.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.first.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "started",
          evidence_held: "other",
        },
      )
      started_declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      started_declaration.make_eligible!
      started_declaration.make_payable!
      started_declaration.update!(
        statement: nov_statement,
      )
    end
  end

  def create_voided_declarations_nov(participant)
    timestamp = participant.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Started::EarlyCareerTeacher.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-induction",
          declaration_date: (participant.schedule.milestones.first.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.first.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "started",
          evidence_held: "other",
        },
      )
      declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      declaration.make_eligible!
      declaration.make_payable!
      declaration.make_voided!
      declaration.update!(
        statement: nov_statement,
      )
      declaration
    end
  end

  def create_retained_declarations_nov(participant)
    timestamp = participant.schedule.milestones.second.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Retained::EarlyCareerTeacher.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-induction",
          declaration_date: (participant.schedule.milestones.second.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.second.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "retained-1",
          evidence_held: "other",
        },
      )
      started_declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      started_declaration.make_eligible!
      started_declaration.make_payable!
      started_declaration.update!(
        statement: nov_statement,
      )
    end
  end

  def create_retained_declarations_jan_mentor(participant)
    timestamp = participant.schedule.milestones.second.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Retained::Mentor.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-mentor",
          declaration_date: (participant.schedule.milestones.second.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.second.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "retained-1",
          evidence_held: "other",
        },
      )
      retained_declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      retained_declaration.make_eligible!
      retained_declaration.make_payable!
      retained_declaration.update!(
        statement: jan_statement,
      )
    end
  end

  def create_retained_declarations_jan_ect(participant)
    timestamp = participant.schedule.milestones.second.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Retained::EarlyCareerTeacher.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-induction",
          declaration_date: (participant.schedule.milestones.second.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.second.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "retained-1",
          evidence_held: "other",
        },
      )
      retained_declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      retained_declaration.make_eligible!
      retained_declaration.update!(
        statement: jan_statement,
      )
    end
  end

  def create_ineligible_declarations_jan(participant)
    timestamp = participant.schedule.milestones.first.start_date + 1.day
    travel_to(timestamp) do
      serialized_started_declaration = RecordDeclarations::Started::EarlyCareerTeacher.call(
        params: {
          participant_id: participant.user.id,
          course_identifier: "ecf-induction",
          declaration_date: (participant.schedule.milestones.first.start_date + 1.day).rfc3339,
          created_at: participant.schedule.milestones.first.start_date + 1.day,
          cpd_lead_provider: lead_provider.cpd_lead_provider,
          declaration_type: "started",
          evidence_held: "other",
        },
      )
      declaration = ParticipantDeclaration.find(JSON.parse(serialized_started_declaration).dig("data", "id"))
      declaration.update!(
        state: "ineligible",
        statement: jan_statement,
      )
      declaration
    end
  end

  def nov_retained_breakdowns_are_calculated
    @nov_retained_1 = Finance::ECF::CalculationOrchestrator.new(
      statement: nov_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_nov,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :retained_1)
  end

  def nov_starts_breakdowns_are_calculated
    @nov_starts = Finance::ECF::CalculationOrchestrator.new(
      statement: nov_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_nov,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :started)
  end

  def jan_starts_breakdowns_are_calculated
    @jan_starts = Finance::ECF::CalculationOrchestrator.new(
      statement: jan_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_jan,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :started)
  end

  def jan_retained_breakdowns_are_calculated
    @jan_retained_1 = Finance::ECF::CalculationOrchestrator.new(
      statement: jan_statement,
      contract: lead_provider.call_off_contract,
      aggregator: participant_aggregator_jan,
      calculator: PaymentCalculator::ECF::PaymentCalculation,
    ).call(event_type: :retained_1)
  end

  def and_breakdowns_are_calculated
    nov_starts_breakdowns_are_calculated
    nov_retained_breakdowns_are_calculated
    jan_starts_breakdowns_are_calculated
    jan_retained_breakdowns_are_calculated
  end

  def then_i_should_see_correct_breakdown_summary
    expect(page).to have_css("h1.govuk-heading-xl", text: lead_provider.name)
    click_on "January 2022"

    within ".breakdown-summary" do
      expect(page).to have_content("Submission deadline")
      expect(page).to have_content(jan_statement.deadline_date.to_s(:govuk))
    end

    within ".breakdown-summary-recruitment" do
      expect(page).to have_content("Current ECTs")
      expect(page).to have_content(@jan_starts[:breakdown_summary][:ects] + @jan_retained_1[:breakdown_summary][:ects])
      expect(page).to have_content("Current Mentors")
      expect(page).to have_content(@jan_starts[:breakdown_summary][:mentors] + @jan_retained_1[:breakdown_summary][:mentors])
      expect(page).to have_content("Total")
      expect(page).to have_content(@jan_starts[:breakdown_summary][:participants] + @jan_retained_1[:breakdown_summary][:participants])
      expect(page).to have_content("Recruitment target")
      expect(page).to have_content(contract.recruitment_target)
    end
  end

  def then_i_should_see_the_correct_payment_summary
    within ".breakdown-summary-payment" do
      expect(page).to have_content("Service fee")
      expect(page).to have_content(contract.recruitment_target)
      expect(page).to have_content(number_to_pounds(service_fee_total))
      expect(page).to have_content("Output fee")
      expect(page).to have_content(number_of_declarations)
      expect(page).to have_content(output_payment_total)
      expect(page).to have_content("VAT")
      expect(page).to have_content(number_to_pounds(total_vat_breakdown))
      expect(page).to have_content("Total payment")
      expect(page).to have_content(number_to_pounds(total_payment_with_vat_breakdown))
    end
  end

  def then_i_should_see_the_correct_service_fees
    within ".service-fees-table" do
      expect(page).to have_content("Service fee")
      expect(page).to have_content(number_to_pounds(@jan_starts[:service_fees][0][:per_participant]))
      expect(page).to have_content(contract.recruitment_target)
      expect(page).to have_content(number_to_pounds(@jan_starts[:service_fees][0][:monthly]))
    end
  end

  def then_i_should_see_the_correct_output_fees
    first(".output-payments-table") do
      expect(page).to have_content("Output fee")
      expect(page).to have_content(number_to_pounds(@jan_starts[:output_payments][0][:per_participant]))
      expect(page).to have_content(@jan_starts[:output_payments][0][:participants])
      expect(page).to have_content(number_to_pounds(@jan_starts[:output_payments][0][:subtotal]))
    end
  end

  def then_i_should_see_the_correct_uplift_fee
    within(".other-fees-table") do
      expect(page).to have_content("Uplift fee")
      expect(page).to have_content(number_to_pounds(@jan_starts[:other_fees][:uplift][:per_participant]))
      expect(page).to have_content(@jan_starts[:other_fees][:uplift][:participants])
      expect(page).to have_content(number_to_pounds(@jan_starts[:other_fees][:uplift][:subtotal]))
    end
  end

  def number_of_declarations
    @jan_starts[:output_payments].map { |params| params[:participants] }.inject(&:+) + @jan_retained_1[:output_payments].map { |params| params[:participants] }.inject(&:+)
  end

  def service_fee_total
    @jan_starts[:service_fees].map { |params| params[:monthly] }.inject(&:+)
  end

  def output_payment_total
    @jan_starts[:output_payments].map { |params| params[:subtotal] }.inject(&:+) + @jan_retained_1[:output_payments].map { |params| params[:subtotal] }.inject(&:+)
  end

  def total_vat_breakdown
    total_vat_combined(@jan_starts, @jan_retained_1, lead_provider)
  end

  def total_payment_with_vat_breakdown
    total_payment_with_vat_combined(@jan_starts, @jan_retained_1, lead_provider)
  end

  def and_there_is_a_schedule
    create(:ecf_schedule)
  end

  def when_i_click_on_payment_breakdown_header
    find("h2", text: "Payment Breakdown").click
  end

  def when_i_select_ecf
    choose option: "ecf", allow_label_click: true
  end

  def when_i_select_a_provider
    choose option: "cffd2237-c368-4044-8451-68e4a4f73369", allow_label_click: true
  end

  def and_i_click_open_all_button
    find("button", text: "Open all").click
  end

  def when_i_click_on_view_contract_link
    find("a", text: I18n.t("finance.show_contract")).click
  end
end
