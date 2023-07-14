# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show ECF statement", :js do
  let(:statement) { create :ecf_statement }
  let(:lead_provider) { statement.lead_provider }
  let!(:contract) { create(:call_off_contract, lead_provider:, version: statement.contract_version, cohort: Cohort.current) }

  scenario "Statement includes additional adjustments" do
    given_i_am_logged_in_as_a_finance_user
    and_multiple_additional_adjustments_exist

    when_i_visit_the_ecf_financial_statements_page

    then_i_see("Early career framework (ECF)")
    and_i_see_additional_adjustments_table
    and_i_see_additional_adjustments_total
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{lead_provider.id}/statements/#{statement.id}")
  end

  def and_multiple_additional_adjustments_exist
    create :adjustment, statement:, payment_type: "Big amount", amount: 999.99
    create :adjustment, statement:, payment_type: "Negative amount", amount: -500.0
    create :adjustment, statement:, payment_type: "Another amount", amount: 300.0
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see_additional_adjustments_table
    expect(page).to have_content("Additional adjustments")
    expect(page).to have_content("Big amount")
    expect(page).to have_content("Negative amount")
    expect(page).to have_content("Another amount")
  end

  def and_i_see_additional_adjustments_total
    expect(page).to have_css(".finance-panel .finance-panel__summary__total-payment-breakdown p:nth-child(5)", text: "Additional adjustments\n£799.99")
  end
end
