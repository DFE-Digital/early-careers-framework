# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", type: :feature, js: true do
  scenario "Can get to ECF payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_ecf_provider_with_contract
    and_there_is_a_schedule
    and_there_is_a_statement
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Finance dashboard")

    when_i_click_on_payment_breakdown_header
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown select programme")

    when_i_select_ecf
    when_i_click_the_submit_button
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown select ECF provider")

    when_i_select_a_provider
    when_i_click_the_submit_button
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown for an ECF provider (eligible)")

    when_i_click_on_view_contract_link
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Contract breakdown for an ECF provider")

    when_i_click_on("Back")
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown for an ECF provider (latest)")
  end

private

  def when_i_click_on(string)
    page.click_link(string)
  end

  def and_i_click_on(string)
    when_i_click_on(string)
  end

  def and_there_is_a_schedule
    create(:ecf_schedule)
  end

  def and_there_is_ecf_provider_with_contract
    @ecf_lead_provider = create(:lead_provider, :contract, name: "Test provider", id: "cffd2237-c368-4044-8451-68e4a4f73369")
  end

  def and_there_is_a_statement
    @cpd_lead_provider = create(:cpd_lead_provider, lead_provider: @ecf_lead_provider)
    Finance::Statement::ECF.create!(
      name: "November 2021",
      deadline_date: Date.new(2021, 11, 30),
      payment_date: Date.new(2021, 11, 30),
      cpd_lead_provider: @cpd_lead_provider,
    )
    Finance::Statement::ECF.create!(
      name: "January 2022",
      deadline_date: Date.new(2022, 0o1, 31),
      payment_date: Date.new(2022, 0o1, 31),
      cpd_lead_provider: @cpd_lead_provider,
    )
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
