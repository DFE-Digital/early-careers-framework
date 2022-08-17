# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Finance users participant change training status", type: :feature do
  before do
    given_i_am_logged_in_as_a_finance_user
    when_i_visit_the_finance_participant_drilldown_page
    then_i_see("Participant")
  end

  describe "NPQ" do
    let!(:participant_profile) { create(:npq_participant_profile, :with_participant_profile_state, training_status: "active") }
    let!(:user) { participant_profile.user }
    let!(:participant_declaration) { create(:npq_participant_declaration, participant_profile:, user:) }

    scenario "Change training status to deferred" do
      then_table_value_is(label: "Training status", value: "active")
      and_i_click_on("Change training status")
      then_i_see("Change training status")
      and_i_see("Choose a different training status")
      when_i_choose("deferred")
      and_i_select("bereavement", "finance-change-training-status-form-reason-field")
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
    let!(:induction_record) { create(:induction_record, participant_profile:, induction_programme:) }

    describe "EarlyCareerTeacher" do
      let!(:participant_profile) { create(:ect_participant_profile, training_status: "active") }
      let!(:user) { participant_profile.user }
      let!(:participant_declaration) { create(:ect_participant_declaration, participant_profile:, user:) }

      scenario "Change training status to deferred" do
        then_table_value_is(label: "Training status", value: "active")
        and_i_click_on("Change training status")
        then_i_see("Change training status")
        and_i_see("Choose a different training status")
        when_i_choose("deferred")
        and_i_select("bereavement", "finance-change-training-status-form-reason-field")
        and_i_click_on("Continue")
        then_i_see("Training status updated successfully")
        then_table_value_is(label: "Training status", value: "deferred")
      end
    end

    describe "Mentor" do
      let!(:participant_profile) { create(:mentor_participant_profile, training_status: "active") }
      let!(:user) { participant_profile.user }
      let!(:participant_declaration) { create(:mentor_participant_declaration, participant_profile:, user:) }

      scenario "Change training status to deferred" do
        then_table_value_is(label: "Training status", value: "active")
        and_i_click_on("Change training status")
        then_i_see("Change training status")
        and_i_see("Choose a different training status")
        when_i_choose("deferred")
        and_i_select("bereavement", "finance-change-training-status-form-reason-field")
        and_i_click_on("Continue")
        then_i_see("Training status updated successfully")
        then_table_value_is(label: "Training status", value: "deferred")
      end
    end
  end

  def when_i_visit_the_finance_participant_drilldown_page
    visit("/finance/participants/#{user.id}")
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
