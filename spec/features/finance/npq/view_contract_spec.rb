# frozen_string_literal: true

require "rails_helper"

RSpec.feature "NPQ view contract", :with_default_schedules do
  include FinanceHelper

  scenario "see the contract information for all courses of an NPQ lead provider" do
    given_i_am_logged_in_as_a_finance_user
    and_there_is_an_npq_lead_provider_with_contracts
    when_i_visit_the_payment_breakdown_page
    and_choose_to_see_npq_payment_breakdown
    and_i_select_an_npq_lead_provider
    and_i_click_on_view_contract
    then_i_see_contract_information_for_each_course
  end

  def and_there_is_an_npq_lead_provider_with_contracts
    @npq_leading_teaching = create(:npq_course, identifier: "npq-leading-teaching")
    @npq_leading_behaviour_culture = create(:npq_course, identifier: "npq-leading-behaviour-culture")
    @npq_schedule = create(:npq_leadership_schedule)
    @npq_specialist_schedule = create(:npq_specialist_schedule)

    @npq_lt = create(:npq_contract, :npq_leading_teaching)
    @npq_lead_provider = @npq_lt.npq_lead_provider
    @npq_lbc = create(:npq_contract, :npq_leading_behaviour_culture, npq_lead_provider: @npq_lead_provider)

    create(
      :npq_statement,
      name: "January 2022",
      deadline_date: Date.new(2022, 1, 31),
      payment_date: Date.new(2022, 2, 16),
      cpd_lead_provider: @npq_lead_provider.cpd_lead_provider,
      contract_version: @npq_lt.version,
    )
  end

  def when_i_visit_the_payment_breakdown_page
    click_on "View financial statements"
  end

  def and_choose_to_see_npq_payment_breakdown
    choose "NPQ payments"
    click_on "Continue"
  end

  def and_i_select_an_npq_lead_provider
    choose @npq_lead_provider.name
    click_on "Continue"
  end

  def and_i_click_on_view_contract
    find("span", text: "Contract Information").click
  end

  def then_i_see_contract_information_for_each_course
    within first(".govuk-details__text") do
      expect(page).to have_content("npq-leading-teaching")
      expect(page).to have_content(@npq_lt.recruitment_target)
      expect(page).to have_content(number_to_pounds(@npq_lt.per_participant))
      expect(page).to have_content("npq-leading-behaviour-culture")
      expect(page).to have_content(@npq_lbc.recruitment_target)
      expect(page).to have_content(number_to_pounds(@npq_lbc.per_participant))
    end
  end
end
