# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant change training status", :with_default_schedules, type: :feature do
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

      # trigger invalid form submission
      and_i_click_on("Continue")

      # check that a readable error message is displayed
      expect(page).to have_css(".govuk-error-summary__body ul.govuk-error-summary__list li a[href='#finance-npq-change-training-status-form-training-status-field-error']", text: "something meaningful at the moment it is 'is not included in the list'")

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
    let(:school_cohort) { participant_profile.school_cohort }
    let!(:partnership) do
      create(
        :partnership,
        school: school_cohort.school,
        cohort: school_cohort.cohort,
        challenged_at: nil,
        challenge_reason: nil,
        pending: false,
      )
    end
    let(:induction_programme) { create(:induction_programme, partnership:, school_cohort:) }

    describe "EarlyCareerTeacher" do
      let!(:participant_profile)     { create(:ect, lead_provider: cpd_lead_provider.lead_provider) }
      let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:) }

      before do
        Induction::Enrol.call(participant_profile:, induction_programme:)
      end

      scenario "Change training status to deferred" do
        then_table_value_is(label: "Training status", value: "active")
        and_i_click_on("Change training status")

        # trigger invalid form submission
        and_i_click_on("Continue")

        # check that a readable error message is displayed
        expect(page).to have_css(".govuk-error-summary__body ul.govuk-error-summary__list li a[href='#finance-ecf-change-training-status-form-training-status-field-error']", text: "something meaningful at the moment it is 'is not included in the list'")

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

      before do
        Induction::Enrol.call(participant_profile:, induction_programme:)
      end

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
      page.all("dl.govuk-summary-list .govuk-summary-list__row").each_with_object({}) do |row, sum|
        key = row.find(".govuk-summary-list__key").text.to_s.strip
        val = row.find(".govuk-summary-list__value").text.to_s.strip
        if key.present?
          sum[key] = val
        end
      end
    expect(table_values[label]).to eql(value)
  end

  def and_an_ect_user_with_profile_and_declarations
    ect_user
    ect_profile
    ect_declaration
  end
end
