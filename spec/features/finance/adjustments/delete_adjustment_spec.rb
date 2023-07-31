# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Delete adjustment from statement", :js do
  scenario "Delete adjustment" do
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

    when_i_click_delete_on_adjustment
    then_i_see("Are you sure you want to remove the '#{@adjustment1.payment_type}' adjustment?")
    and_i_click_on("Confirm and continue")

    then_i_see("Change or remove an adjustment")
    and_deleted_adjustment_should_not_exist
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

  def and_additional_adjustments_exist
    @adjustment1 = create :adjustment, statement: @statement, payment_type: "Big amount", amount: 999.99
    @adjustment2 = create :adjustment, statement: @statement, payment_type: "Negative amount", amount: -500.0
    @adjustment3 = create :adjustment, statement: @statement, payment_type: "Another amount", amount: 300.0
  end

  def and_a_call_off_contract_exists
    create(:call_off_contract, lead_provider: @statement.lead_provider, version: @statement.contract_version, cohort: Cohort.current)
  end

  def when_i_click_delete_on_adjustment
    within(".govuk-table .govuk-table__body .govuk-table__row:nth-child(1)") do
      click_on("Remove")
    end
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    expect(page).to have_content(string)
  end

  def when_i_click_on_change_or_remove_adjustment_link
    click_on("Change or remove adjustment")
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def and_deleted_adjustment_should_not_exist
    expect(page).to_not have_content(@adjustment1.payment_type)
    expect(Finance::Adjustment.count).to eql(2)
    expect(Finance::Adjustment.where(payment_type: @adjustment1.payment_type).count).to eql(0)
  end
end
