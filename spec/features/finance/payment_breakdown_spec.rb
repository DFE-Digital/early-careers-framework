# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users payment breakdowns", type: :feature, js: true do
  scenario "Can get to ECF payment breakdown page for a provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_ecf_provider_with_contract
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Finance dashboard")

    when_i_click_on_payment_breakdown_header
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown select programme")

    when_i_select_ecf
    and_i_click_the_submit_button
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown select ECF provider")

    when_i_select_a_provider
    and_i_click_the_submit_button
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Payment breakdown for an ECF provider")

    when_i_click_on_view_contract_button
    then_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named("Contract breakdown for an ECF provider")
  end

private

  def and_there_is_ecf_provider_with_contract
    create(:lead_provider, :contract, name: "Test provider", id: "cffd2237-c368-4044-8451-68e4a4f73369")
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

  def when_i_click_on_view_contract_button
    find("a", text: "View contract information").click
  end
end
