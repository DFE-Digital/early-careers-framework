# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show voided declarations" do
  let!(:statement) { create(:ecf_statement) }
  let(:cpd_lead_provider) { statement.cpd_lead_provider }
  let(:lead_provider) { cpd_lead_provider.lead_provider }
  let(:cohort) { statement.cohort }
  let!(:contract) { create(:call_off_contract, lead_provider:, version: statement.contract_version, cohort:) }
  let!(:mentor_contract) { create(:mentor_call_off_contract, lead_provider:, version: statement.contract_version, cohort:) }

  before do
    given_i_am_logged_in_as_a_finance_user
    and_multiple_declarations_exist
  end

  scenario "Voided declarations" do
    when_i_visit_the_ecf_financial_statements_page
    click_link("View voided declarations")

    then_i_see("Voided declarations")
    and_i_see_ect_declarations
    and_i_see_mentor_declarations
  end

  scenario "ECT voided declarations" do
    given_cohort_has_mentor_funding_enabled

    when_i_visit_the_ecf_financial_statements_page
    click_link("2 ECT voided declarations")

    then_i_see("ECT voided declarations")
    and_i_see_ect_declarations
    and_not_see_mentor_declarations
  end

  scenario "Mentor voided declarations" do
    given_cohort_has_mentor_funding_enabled

    when_i_visit_the_ecf_financial_statements_page
    click_link("2 Mentor voided declarations")

    then_i_see("Mentor voided declarations")
    and_i_see_mentor_declarations
    and_not_see_ect_declarations
  end

  def given_cohort_has_mentor_funding_enabled
    cohort.update!(mentor_funding: true)
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{statement.id}")
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see_ect_declarations
    @ect_declarations.each do |dec|
      expect(page).to have_content(dec.id)
    end
  end

  def and_not_see_ect_declarations
    @ect_declarations.each do |dec|
      expect(page).to_not have_content(dec.id)
    end
  end

  def and_i_see_mentor_declarations
    @mentor_declarations.each do |dec|
      expect(page).to have_content(dec.id)
    end
  end

  def and_not_see_mentor_declarations
    @mentor_declarations.each do |dec|
      expect(page).to_not have_content(dec.id)
    end
  end

  def and_multiple_declarations_exist
    @ect_declarations = []
    @mentor_declarations = []

    2.times do
      declaration = create(:ect_participant_declaration, :voided, cpd_lead_provider:, cohort:)
      declaration.statement_line_items.create!(statement:, state: declaration.state)
      @ect_declarations << declaration
    end

    2.times do
      declaration = create(:mentor_participant_declaration, :voided, cpd_lead_provider:, cohort:)
      declaration.statement_line_items.create!(statement:, state: declaration.state)
      @mentor_declarations << declaration
    end
  end
end
