# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", with_feature_flags: { change_of_circumstances: "active" }, js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    set_sit_data
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    then_i_am_taken_to_fip_induction_dashboard
    set_dqt_validation_result
  end

  scenario "Induction tutor can add themselves as a mentor and validates" do
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page

    when_i_click_on_add_myself_as_mentor
    then_i_am_taken_to_are_you_sure_page
    then_the_page_should_be_accessible

    when_i_click_on_check_what_each_role_needs_to_do
    then_i_am_taken_to_roles_page

    when_i_click_on_back
    then_i_am_taken_to_are_you_sure_page

    when_i_click_on_confirm
    then_i_am_taken_to_add_your_trn_page
    when_i_add_my_trn
    click_on "Continue"

    then_i_am_taken_to_add_your_dob_page
    when_i_add_my_date_of_birth
    click_on "Continue"

    then_i_am_taken_to_check_details_page
    when_i_click_confirm_and_add
    then_i_am_taken_to_yourself_as_mentor_confirmation_page

    sign_out
    when_i_sign_back_in
    then_i_am_taken_to_fip_induction_dashboard
    then_the_page_should_be_accessible
  end
end
