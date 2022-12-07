# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Add a school cohort appropriate body", type: :feature, js: true do
  context "When appropriate body setup was not done for the cohort" do
    scenario "The appropriate body can be added" do
      given_there_is_a_school_and_an_induction_coordinator
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page
      and_i_can_add_appropriate_body
    end
  end

  context "When appropriate body was not appointed during cohort setup" do
    let!(:appropriate_body) { create(:appropriate_body_national_organisation) }

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

  context "When appropriate body was appointed during cohort setup" do
    let!(:appropriate_body) { create(:appropriate_body_national_organisation) }

    scenario "The appropriate body can be changed" do
      given_there_is_a_school_and_an_induction_coordinator
      and_appropriate_body_is_appointed(appropriate_body)
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_manage_your_training_page
      and_i_can_change_appropriate_body
    end
  end

private

  def given_there_is_a_school_and_an_induction_coordinator
    @cohort = create(:cohort, :current)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")

    create_partnership(@school)
    create_induction_tutor(@school)
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

  def and_i_can_add_appropriate_body
    expect(page).to have_summary_row_action("Appropriate body", "Add")
  end

  def and_i_can_change_appropriate_body
    expect(page).to have_summary_row_action("Appropriate body", "Change")
  end

  def and_appropriate_body_is_appointed(appropriate_body)
    @school_cohort.update!(appropriate_body:)
  end

  def when_i_choose_appropriate_body(appropriate_body)
    when_i_click_on_summary_row_action("Appropriate body", "Add")
    choose "National organisation"
    click_on "Continue"
    choose appropriate_body.name
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
    and_i_click_on_summary_row_action("ECTs and mentors", "Manage")
    click_on "Sally Teacher"
  end

  def then_i_see_appropriate_body(appropriate_body)
    expect(page).to have_summary_row("Appropriate body", appropriate_body.name)
  end

  def when_i_go_back_to_manage_your_training_page
    click_on "Return to manage your training"
  end
end
