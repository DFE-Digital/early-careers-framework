# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Create adjustment for statement", :js do
  scenario "Add new adjustment" do
    given_i_am_logged_in_as_a_finance_user
    and_an_ecf_statement_exists
    when_i_visit_the_ecf_financial_statements_page
    then_i_see("Early career framework (ECF)")
    when_i_click_on_add_adjustment_link

    then_i_see("What is the name of the adjustment")
    and_i_fill_in("finance-adjustment-payment-type-field", with: "Test Payment")
    and_i_click_on("Continue")

    then_i_see("How much is the payment?")
    and_i_fill_in("finance-adjustment-amount-field", with: "999.99")
    and_i_click_on("Continue")

    then_i_see("Check your answers")
    and_i_see("Test Payment")
    and_i_see("£999.99")
    and_i_click_on("Confirm and continue")

    then_i_see("You have added an adjustment")
    and_i_see("Test Payment")
    and_i_see("£999.99")
    and_i_choose("Yes")
    and_i_click_on("Continue")

    then_i_see("What is the name of the adjustment")
    and_an_adjustment_is_created
  end

  scenario "When statement is payable or paid" do
    given_i_am_logged_in_as_a_finance_user
    and_a_closed_ecf_statement_exists

    when_i_visit_the_ecf_financial_statements_page
    then_i_see("Early career framework (ECF)")
    and_i_should_not_see_adjustment_links

    when_i_visit_new_adjustment_page_directly
    then_i_am_redirected_back_to_financial_statements_page
  end

  scenario "When statement has false output_fee" do
    given_i_am_logged_in_as_a_finance_user
    and_an_ecf_statement_with_false_output_fees_exists

    when_i_visit_the_ecf_financial_statements_page
    then_i_see("Early career framework (ECF)")
    and_i_should_not_see_adjustment_links

    when_i_visit_new_adjustment_page_directly
    then_i_am_redirected_back_to_financial_statements_page
  end

  def when_i_visit_the_ecf_financial_statements_page
    visit("/finance/ecf/payment_breakdowns/#{@statement.lead_provider.id}/statements/#{@statement.id}")
  end

  def when_i_visit_new_adjustment_page_directly
    visit("/finance/statements/#{@statement.id}/adjustments/new")
  end

  def and_an_ecf_statement_exists
    @statement = create :ecf_statement
    and_a_call_off_contract_exists
  end

  def and_an_ecf_statement_with_false_output_fees_exists
    @statement = create :ecf_statement, output_fee: false
    and_a_call_off_contract_exists
  end

  def and_a_closed_ecf_statement_exists
    @statement = create :ecf_paid_statement
    and_a_call_off_contract_exists
  end

  def and_a_call_off_contract_exists
    create(:call_off_contract, lead_provider: @statement.lead_provider, version: @statement.contract_version, cohort: Cohort.current)
  end

  def then_i_am_redirected_back_to_financial_statements_page
    then_i_see("Early career framework (ECF)")
  end

  def and_an_adjustment_is_created
    adjustment = Finance::Adjustment.first
    expect(adjustment.statement).to eql(@statement)
    expect(adjustment.payment_type).to eql("Test Payment")
    expect(adjustment.amount).to eql(999.99)
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    expect(page).to have_content(string)
  end

  def when_i_click_on_add_adjustment_link
    click_on("Add adjustment")
  end

  def and_i_fill_in(selector, with:)
    page.fill_in selector, with:
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def and_i_choose(string)
    page.choose(string)
  end

  def and_i_should_not_see_adjustment_links
    expect(page).to_not have_link("Add adjustment")
    expect(page).to_not have_link("Change or remove adjustment")
  end
end
