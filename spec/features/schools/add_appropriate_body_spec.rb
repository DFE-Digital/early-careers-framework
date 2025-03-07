# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add a school cohort appropriate body", type: :feature, js: true,
               travel_to: Time.zone.local(2023, 6, 5, 16, 15, 0) do
  context "When appropriate body setup was not done for the cohort" do
    scenario "The appropriate body can be added" do
      given_there_is_a_school_and_an_induction_coordinator
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page
      and_i_can_add_appropriate_body
    end
  end

  context "When appropriate body was not appointed during cohort setup" do
    let!(:appropriate_body) { create(:appropriate_body_teaching_school_hub) }

    before do
      create(:appropriate_body_local_authority, name: "Educational Success Partners (ESP)")
      create(:appropriate_body_national_organisation, name: "Independent Schools Teacher Induction Panel (IStip)")
    end

    context "For any GIAS code" do
      scenario "The appropriate body can be added and set for all ECTs" do
        given_there_is_a_school_and_an_induction_coordinator
        and_i_have_added_an_ect
        and_i_am_signed_in_as_an_induction_coordinator
        then_i_am_on_the_manage_your_training_page

        when_i_choose_appropriate_body(appropriate_body)
        then_i_see_the_confirmation_page

        when_i_go_back_to_manage_your_training_page
        then_i_see_appropriate_body(appropriate_body)

        when_i_go_to_the_teacher_profile_page
        then_i_see_appropriate_body(appropriate_body)
      end
    end

    context "For british schools overseas (GIAS 37)" do
      scenario "The appropriate body can be added and set for all ECTs" do
        given_there_is_a_school_and_an_induction_coordinator
        and_school_gias_code_is(37)
        and_i_have_added_an_ect
        and_i_am_signed_in_as_an_induction_coordinator
        then_i_am_on_the_manage_your_training_page

        when_i_choose_teaching_school_hub(appropriate_body)
        then_i_see_the_confirmation_page

        when_i_go_back_to_manage_your_training_page
        then_i_see_appropriate_body(appropriate_body)

        when_i_go_to_the_teacher_profile_page
        then_i_see_appropriate_body(appropriate_body)
      end
    end

    context "For independent schools (GIAS 10)" do
      scenario "The appropriate body can be added and set for all ECTs" do
        given_there_is_a_school_and_an_induction_coordinator
        and_school_gias_code_is(10)
        and_i_have_added_an_ect
        and_i_am_signed_in_as_an_induction_coordinator
        then_i_am_on_the_manage_your_training_page

        when_i_choose_teaching_school_hub(appropriate_body)
        then_i_see_the_confirmation_page

        when_i_go_back_to_manage_your_training_page
        then_i_see_appropriate_body(appropriate_body)

        when_i_go_to_the_teacher_profile_page
        then_i_see_appropriate_body(appropriate_body)
      end
    end

    context "For independent schools (GIAS 11)" do
      scenario "The appropriate body can be added and set for all ECTs" do
        given_there_is_a_school_and_an_induction_coordinator
        and_school_gias_code_is(11)
        and_i_have_added_an_ect
        and_i_am_signed_in_as_an_induction_coordinator
        then_i_am_on_the_manage_your_training_page

        when_i_choose_teaching_school_hub(appropriate_body)
        then_i_see_the_confirmation_page

        when_i_go_back_to_manage_your_training_page
        then_i_see_appropriate_body(appropriate_body)

        when_i_go_to_the_teacher_profile_page
        then_i_see_appropriate_body(appropriate_body)
      end
    end
  end

  context "When appropriate body was appointed during cohort setup" do
    let!(:appropriate_body) { create(:appropriate_body_teaching_school_hub) }

    scenario "The appropriate body can be changed" do
      given_there_is_a_school_and_an_induction_coordinator
      and_appropriate_body_is_appointed(appropriate_body)
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page
      and_i_can_change_appropriate_body
    end
  end

  context "From 2023 the local authority appropriate bodies can't be selected anymore" do
    scenario "A local authorities appropriate body can't be added" do
      given_there_is_a_school_and_an_induction_coordinator
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page

      when_i_click_on_add_appropriate_body
      then_i_cant_select_local_authorities
    end
  end

  context "When an appropriate body is disabled" do
    before do
      create(:appropriate_body_teaching_school_hub, name: "Disabled AB", disable_from_year: 2023)
      create(:appropriate_body_teaching_school_hub, name: "Enabled AB")
    end

    scenario "It can't be selected" do
      given_there_is_a_school_and_an_induction_coordinator
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page

      when_i_click_on_add_appropriate_body
      then_autocomplete_does_not_allow "appropriate-body-selection-form-body-id-field", value: "Disabled AB"
    end
  end

  context "When attempting an unsupported confirmation type on an appropriate body", exceptions_app: true do
    let!(:appropriate_body) { create(:appropriate_body_teaching_school_hub) }

    scenario "It raises an error" do
      given_there_is_a_school_and_an_induction_coordinator
      and_i_have_added_an_ect
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page

      visit confirm_schools_cohort_path(school_id: @school.slug, cohort_id: @cohort.start_year, confirmation_type: "unsupported_confirmation_type")

      expect(page).to have_content("Page not found")
    end
  end

private

  def given_there_is_a_school_and_an_induction_coordinator
    @cohort = Cohort.find_by(start_year: 2023)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")

    create_partnership(@school)
    create_induction_tutor(@school)
  end

  def given_the_school_is_a_british_school_overseas
    @school.update(school_type_code: 37)
  end

  def given_the_school_is_an_independent_school
    @school.update(school_type_code: [10, 11].sample)
  end

  def create_induction_tutor(*schools)
    user = create(:user, full_name: "Induction Coordinator", email: "ic@example.com")
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools:, user:)
  end

  def create_partnership(school)
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    create(:partnership, school:, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
  end

  def and_i_am_signed_in_as_an_induction_coordinator
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def then_i_am_on_the_manage_your_training_page
    expect(page).to have_content("Manage your training")
  end

  def then_i_cant_select_local_authorities
    expect(page).to_not have_text("Local authority")
  end

  def and_i_can_add_appropriate_body
    expect(page).to have_summary_row_action("Appropriate body", "Add appropriate body")
  end

  def and_i_can_change_appropriate_body
    expect(page).to have_summary_row_action("Appropriate body", "Change appropriate body")
  end

  def and_appropriate_body_is_appointed(appropriate_body)
    @school_cohort.update!(appropriate_body:)
  end

  def when_i_click_on_add_appropriate_body
    when_i_click_on_summary_row_action("Appropriate body", "Add appropriate body")
  end

  def when_i_click_on_change_appropriate_body
    when_i_click_on_summary_row_action("Appropriate body", "Change")
  end

  def when_i_choose_appropriate_body(appropriate_body)
    when_i_click_on_add_appropriate_body
    when_i_fill_in_autocomplete "appropriate-body-selection-form-body-id-field", with: appropriate_body.name
    click_on "Continue"
  end

  def when_i_choose_teaching_school_hub(appropriate_body)
    when_i_click_on_add_appropriate_body
    choose "Teaching school hub"
    when_i_fill_in_autocomplete "appropriate-body-selection-form-body-id-field", with: appropriate_body.name
    click_on "Continue"
  end

  def when_i_choose_to_change_appropriate_body_to(appropriate_body)
    when_i_click_on_change_appropriate_body
    click_on "Confirm and continue"
    choose appropriate_body.name
    # choose "Teaching school hub"
    # when_i_fill_in_autocomplete "appropriate-body-selection-form-body-id-field", with: appropriate_body.name
    click_on "Continue"
  end

  def then_i_see_the_confirmation_page
    expect(page).to have_content("Appropriate body reported")
  end

  def and_i_have_added_an_ect
    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user:)
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile:, school_cohort: @school_cohort)
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort, partnership: nil)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def when_i_go_to_the_teacher_profile_page
    click_on "Early career teachers"
    click_on "Sally Teacher"
  end

  def then_i_see_appropriate_body(appropriate_body)
    expect(page).to have_summary_row("Appropriate body", appropriate_body.name)
  end

  def when_i_go_back_to_manage_your_training_page
    click_on "Return to manage your training"
  end

  def and_school_gias_code_is(code)
    @school.update!(school_type_code: code)
  end

  def and_i_choose_teaching_school_hub
    choose "Teaching school hub"
  end

  def then_i_see_the_enabled_appropriate_body
    expect(page).to have_content("Enabled AB")
  end

  def and_i_dont_see_the_disabled_appropriate_body
    expect(page).to_not have_content("Disabled AB")
  end
end
