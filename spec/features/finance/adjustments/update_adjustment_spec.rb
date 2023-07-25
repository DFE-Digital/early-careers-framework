# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Update adjustment for statement", :js do
  scenario "Change adjustment" do
    given_i_am_logged_in_as_a_finance_user
    and_an_ecf_statement_exists
    and_additional_adjustments_exist

    when_i_visit_the_ecf_financial_statements_page
    then_i_see("Early career framework (ECF)")
    when_i_click_on_change_or_remove_adjustment_link

    then_i_see("Change or remove an adjustment")
    and_i_see(@adjustment1.payment_type)
    and_i_see(@adjustment2.payment_type)
    and_i_see(@adjustment3.payment_type)

    when_i_click_change_adjustment

    then_i_see("Change or remove an adjustment")
    and_i_see("Check your answers")
    and_i_see("Big amount")
    and_i_see("£999.99")

    when_i_click_change_payment_type
    then_i_see("What is the name of the adjustment")
    and_i_fill_in("finance-adjustment-payment-type-field", with: "Really big amount")
    and_i_click_on("Continue")

    then_i_see("Change or remove an adjustment")
    and_i_see("Check your answers")
    and_i_see("Really big amount")
    and_i_see("£999.99")

    when_i_click_change_amount

    then_i_see("How much is the payment?")
    and_i_fill_in("finance-adjustment-amount-field", with: "10000.0")
    and_i_click_on("Continue")

    then_i_see("Change or remove an adjustment")
    and_i_see("Check your answers")
    and_i_see("Really big amount")
    and_i_see("£10,000.00")

    and_i_click_on("Confirm and continue")

    then_i_see("Change or remove an adjustment")
    and_adjustment_should_have_been_updated
    and_i_see("Really big amount")
    and_i_see("£10,000.00")
    and_i_see(@adjustment2.payment_type)
    and_i_see(@adjustment3.payment_type)
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{@statement.lead_provider.id}/statements/#{@statement.id}")
  end

  def and_an_ecf_statement_exists
    @statement = create :ecf_statement
    and_a_call_off_contract_exists
  end

  def and_a_call_off_contract_exists
    create(:call_off_contract, lead_provider: @statement.lead_provider, version: @statement.contract_version, cohort: Cohort.current)
  end

  def and_additional_adjustments_exist
    @adjustment1 = create :adjustment, statement: @statement, payment_type: "Big amount", amount: 999.99
    @adjustment2 = create :adjustment, statement: @statement, payment_type: "Negative amount", amount: -500.0
    @adjustment3 = create :adjustment, statement: @statement, payment_type: "Another amount", amount: 300.0
  end

  def when_i_click_on_change_or_remove_adjustment_link
    click_on("Change or remove adjustment")
  end

  def when_i_click_change_adjustment
    within(".govuk-table .govuk-table__body .govuk-table__row:nth-child(1)") do
      click_on("Change")
    end
  end

  def when_i_click_change_payment_type
    within(".govuk-table .govuk-table__body .govuk-table__row:nth-child(1)") do
      click_on("Change")
    end
  end

  def when_i_click_change_amount
    within(".govuk-table .govuk-table__body .govuk-table__row:nth-child(2)") do
      click_on("Change")
    end
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_fill_in(selector, with:)
    page.fill_in selector, with:
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def and_adjustment_should_have_been_updated
    @adjustment1.reload
    expect(@adjustment1.payment_type).to eql("Really big amount")
    expect(@adjustment1.amount).to eql(10_000.0)
    expect(Finance::Adjustment.count).to eql(3)
  end
end
