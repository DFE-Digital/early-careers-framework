# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Adding ECT with appropriate body", type: :feature, js: true do
  include DQTHelper

  let!(:cohort) { Cohort.current || create(:cohort, start_year: 2022) }
  let!(:school) { create :school, name: "Fip School" }
  let!(:appropriate_body) { create :appropriate_body_national_organisation }
  let!(:school_cohort) { create :school_cohort, school:, cohort:, induction_programme_choice: "full_induction_programme", appropriate_body: }
  let!(:partnership) do
    create :partnership,
           school:,
           lead_provider: create(:lead_provider, name: "Big Provider Ltd"),
           delivery_partner: create(:delivery_partner, name: "Amazing Delivery Team"),
           cohort:,
           challenge_deadline: 2.weeks.ago
  end
  let!(:induction_programme) do
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership:)
    school_cohort.update! default_induction_programme: induction_programme
    induction_programme
  end
  let!(:user) { create(:user, full_name: "Induction tutor") }
  let!(:privacy_policy) do
    privacy_policy = create(:privacy_policy)
    PrivacyPolicy::Publish.call
    privacy_policy
  end
  let!(:induction_coordinator) do
    induction_coordinator_profile = create(:induction_coordinator_profile, schools: [school_cohort.school], user:)
    PrivacyPolicy.current.accept!(user)
    induction_coordinator_profile
  end
  let!(:schedule) { create :ecf_schedule }

  let(:ect_dob) { "1990-11-22" }

  before do
    school_cohort.update! default_induction_programme: induction_programme
  end

  scenario "Appropriate body is confirmed and appears on the participant detail page" do
    inside_auto_assignment_window(cohort:) do
      sign_in

      when_i_go_to_add_new_ect_page
      and_i_go_through_the_who_do_you_want_to_add_page
      and_i_go_through_the_what_we_need_from_you_page

      and_i_fill_in_all_info
      then_i_am_taken_to_the_confirm_appropriate_body_page

      when_i_click_on_confirm
      then_i_am_taken_to_the_confirmation_page
      and_i_see_the_appropriate_body(appropriate_body)

      when_i_check_the_ect_details
      then_i_see_the_school_appropriate_body
    end
  end

  scenario "Appropriate body for ECT is not confirmed and a different one is selected" do
    inside_auto_assignment_window(cohort:) do
      ect_appropriate_body = create(:appropriate_body_teaching_school_hub)

      sign_in

      when_i_go_to_add_new_ect_page
      and_i_go_through_the_who_do_you_want_to_add_page
      and_i_go_through_the_what_we_need_from_you_page

      and_i_fill_in_all_info
      then_i_am_taken_to_the_confirm_appropriate_body_page

      when_i_choose_a_different_appropriate_body(ect_appropriate_body)
      then_i_am_taken_to_the_confirmation_page
      and_i_see_the_appropriate_body(ect_appropriate_body)

      when_i_check_the_ect_details
      then_i_see_the_appropriate_body(ect_appropriate_body)
    end
  end

  scenario "Appropriate body is confirmed and then changed in the confirm page" do
    inside_auto_assignment_window(cohort:) do
      ect_appropriate_body = create(:appropriate_body_teaching_school_hub)

      sign_in

      when_i_go_to_add_new_ect_page
      and_i_go_through_the_who_do_you_want_to_add_page
      and_i_go_through_the_what_we_need_from_you_page

      and_i_fill_in_all_info
      then_i_am_taken_to_the_confirm_appropriate_body_page

      when_i_click_on_confirm
      then_i_am_taken_to_the_confirmation_page
      and_i_see_the_school_appropriate_body

      when_i_click_on_change_appropriate_body_link
      and_i_choose_a_different_appropriate_body(ect_appropriate_body)

      then_i_am_taken_to_the_confirmation_page
      and_i_see_the_appropriate_body(ect_appropriate_body)

      when_i_check_the_ect_details
      then_i_see_the_appropriate_body(ect_appropriate_body)
    end
  end

private

  def sign_in
    sign_in_as user
  end

  def when_i_go_to_add_new_ect_page
    click_on "Early career teachers"
    click_on "Add ECT"
  end

  def and_i_go_through_the_who_do_you_want_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
    choose "ECT"
    click_on "Continue"
  end

  def and_i_go_through_the_what_we_need_from_you_page
    expect(page).to have_selector("h1", text: "What we need to know about this ECT")
    click_on "Continue"
  end

  def and_i_fill_in_all_info
    allow(DQTRecordCheck).to receive(:call).and_return(
      DQTRecordCheck::CheckResult.new(
        valid_dqt_response(participant_data),
        true,
        true,
        true,
        false,
        3,
      ),
    )

    fill_in "add_participant_wizard[full_name]", with: participant_data[:full_name]
    click_on "Continue"
    fill_in "add_participant_wizard[trn]", with: participant_data[:trn]
    click_on "Continue"
    fill_in_date("What’s George ECT’s date of birth?", with: ect_dob)
    click_on "Continue"
    fill_in "add_participant_wizard[email]", with: "ect@email.gov.uk"
    click_on "Continue"
  end

  def participant_data
    {
      full_name: "George ECT",
      trn: "5234457",
      date_of_birth: Date.parse(ect_dob),
    }
  end

  def then_i_am_taken_to_the_confirm_appropriate_body_page
    expect(page).to have_content("Is this the appropriate body for George ECT’s induction?")
  end

  def then_i_am_taken_to_the_confirmation_page
    expect(page).to have_content("Check your answers")
  end

  def and_i_see_the_school_appropriate_body
    and_i_see_the_appropriate_body(appropriate_body)
  end

  alias_method :then_i_see_the_school_appropriate_body, :and_i_see_the_school_appropriate_body

  def when_i_check_the_ect_details
    click_on "Confirm and add"

    click_on "View your ECTs"
    click_on "George ECT"
  end

  def when_i_choose_a_different_appropriate_body(ect_appropriate_body)
    click_on "They have a different appropriate body"
    and_i_fill_in_autocomplete "appropriate-body-selection-form-body-id-field", with: ect_appropriate_body.name
    click_on "Continue"
  end
  alias_method :and_i_choose_a_different_appropriate_body, :when_i_choose_a_different_appropriate_body

  def and_i_see_the_appropriate_body(ect_appropriate_body)
    expect(page).to have_summary_row("Appropriate body", ect_appropriate_body.name)
  end

  alias_method :then_i_see_the_appropriate_body, :and_i_see_the_appropriate_body

  def when_i_click_on_confirm
    click_on "Confirm"
  end

  def when_i_click_on_change_appropriate_body_link
    when_i_click_on_summary_row_action("Appropriate body", "Change")
  end
end
