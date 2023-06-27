# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant change training status", type: :feature do
  let(:cpd_lead_provider) { create(:cpd_lead_provider, :with_lead_provider, :with_npq_lead_provider) }

  before do
    given_i_am_logged_in_as_a_finance_user
    when_i_visit_the_finance_participant_drilldown_page
    then_i_see("Participant")
  end

  describe "NPQ" do
    let!(:participant_profile)     { create(:npq_participant_profile, npq_lead_provider: cpd_lead_provider.npq_lead_provider) }
    let!(:participant_declaration) { create(:npq_participant_declaration, participant_profile:, cpd_lead_provider:) }

    scenario "Change training status to deferred" do
      then_table_value_is(label: "Training status", value: "active")
      and_i_click_on("Change training status")
      and_i_click_on("Continue")

      expect(page).to have_css(".govuk-error-summary__body ul.govuk-error-summary__list li a[href='#finance-npq-change-training-status-form-training-status-field-error']", text: "Choose a valid training status")

      then_i_see("Change training status")
      and_i_see("Choose a different training status")
      when_i_choose("deferred")
      and_i_select("bereavement", "finance-npq-change-training-status-form-reason-field")
      and_i_click_on("Continue")
      then_i_see("Training status updated successfully")
      then_table_value_is(label: "Training status", value: "deferred")
    end
  end

  describe "ECF" do
    describe "EarlyCareerTeacher" do
      let!(:participant_profile)     { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
      let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }

      scenario "Change training status to deferred" do
        then_table_value_is(label: "Training status", value: "active")
        and_i_click_on("Change training status")
        and_i_click_on("Continue")

        expect(page).to have_css(".govuk-error-summary__body ul.govuk-error-summary__list li a[href='#finance-ecf-change-training-status-form-training-status-field-error']", text: "Choose a valid training status")

        then_i_see("Change training status")
        and_i_see("Choose a different training status")
        when_i_choose("deferred")
        and_i_select("bereavement", "finance-ecf-change-training-status-form-reason-field")
        and_i_click_on("Continue")
        then_i_see("Training status updated successfully")
        then_table_value_is(label: "Training status", value: "deferred")
      end
    end

    describe "Mentor" do
      let!(:participant_profile)     { create(:mentor, lead_provider: cpd_lead_provider.lead_provider) }
      let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, cpd_lead_provider:) }

      scenario "Change training status to deferred" do
        then_table_value_is(label: "Training status", value: "active")
        and_i_click_on("Change training status")
        then_i_see("Change training status")
        and_i_see("Choose a different training status")
        when_i_choose("deferred")
        and_i_select("bereavement", "finance-ecf-change-training-status-form-reason-field")
        and_i_click_on("Continue")
        then_i_see("Training status updated successfully")
        then_table_value_is(label: "Training status", value: "deferred")
      end
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

  def and_an_ect_user_with_profile_and_declarations
    ect_user
    ect_profile
    ect_declaration
  end
end
