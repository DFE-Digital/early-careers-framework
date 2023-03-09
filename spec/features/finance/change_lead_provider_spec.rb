# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant change lead provider", :with_default_schedules, type: :feature do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }

  describe "NPQ" do
    let(:participant_profile)     { create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
    let(:participant_declaration) { create(:npq_participant_declaration, :submitted, participant_profile:, cpd_lead_provider:) }
    let(:npq_lead_provider) { create(:npq_lead_provider) }

    scenario "No declarations" do
      given_i_am_logged_in_as_a_finance_user
      when_i_visit_the_finance_participant_drilldown_page
      then_i_see("ParticipantProfile::NPQ")

      then_i_should_not_see_change_lead_provider_link
    end

    scenario "Select empty lead provider" do
      given_i_am_logged_in_as_a_finance_user
      and_a_declaration_exists
      and_a_npq_lead_provider_exists
      when_i_visit_the_finance_participant_drilldown_page
      then_i_see("ParticipantProfile::NPQ")

      then_i_should_see_change_lead_provider_link
      then_table_value_is(label: "Lead provider", value: participant_profile.npq_application.npq_lead_provider.name)
      and_i_click_on("Change lead provider")
      and_i_click_on("Continue")

      then_i_should_see_validation_error
    end

    scenario "Change lead provider" do
      given_i_am_logged_in_as_a_finance_user
      and_a_declaration_exists
      and_a_npq_lead_provider_exists
      when_i_visit_the_finance_participant_drilldown_page
      then_i_see("ParticipantProfile::NPQ")

      then_i_should_see_change_lead_provider_link
      then_table_value_is(label: "Lead provider", value: participant_profile.npq_application.npq_lead_provider.name)
      and_i_click_on("Change lead provider")
      then_i_see("Change lead provider")
      and_i_select(npq_lead_provider.name, "finance-npq-change-lead-provider-form-lead-provider-id-field")
      and_i_click_on("Continue")

      then_i_see("Check your answers before saving this change")
      and_i_see(participant_profile.npq_application.npq_lead_provider.name)
      and_i_see(npq_lead_provider.name)
      and_i_click_on("Save and continue")

      then_i_see("New lead provider assigned")
      then_i_see("The new lead provider has been successfully assigned to this participant.")
      then_table_value_is(label: "Lead provider", value: npq_lead_provider.name)
    end
  end

  def when_i_visit_the_finance_participant_drilldown_page
    visit("/finance/participants/#{participant_profile.user_id}")
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  def then_i_see(string)
    expect(page).to have_content(string)
  end

  def and_i_see(string)
    then_i_see(string)
  end

  def when_i_fill_in(selector, with:)
    page.fill_in selector, with:
  end

  def when_i_choose(text)
    page.choose text
  end

  def and_i_select(option, dropdown)
    page.select option, from: dropdown
  end

  def then_table_value_is(label:, value:)
    table_values =
      page.all("dl.govuk-summary-list .govuk-summary-list__row").each_with_object({}.compare_by_identity) do |row, sum|
        key = row.find(".govuk-summary-list__key").text.to_s.strip
        val = row.find(".govuk-summary-list__value").text.to_s.strip
        if key.present? && key == label
          sum[key] = val
        end
      end
    expect(table_values).to include({ label => value })
  end

  def and_a_declaration_exists
    participant_declaration
  end

  def and_a_npq_lead_provider_exists
    npq_lead_provider
    cohort = participant_profile.npq_application.cohort
    create(:npq_leadership_course, identifier: "npq-senior-leadership")
    create(:npq_contract, :npq_senior_leadership, cohort:, npq_lead_provider:)
  end

  def then_i_should_not_see_change_lead_provider_link
    expect(page).to_not have_content("Change lead provider")
  end

  def then_i_should_see_change_lead_provider_link
    expect(page).to have_content("Change lead provider")
  end

  def then_i_should_see_validation_error
    expect(page).to have_css(".govuk-error-summary__body ul.govuk-error-summary__list li a[href='#finance-npq-change-lead-provider-form-lead-provider-id-field-error']", text: "Select a valid lead provider")
  end
end
