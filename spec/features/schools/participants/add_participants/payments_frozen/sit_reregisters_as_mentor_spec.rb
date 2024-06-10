# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"
require_relative "./common_steps"

RSpec.describe "SIT adding mentor", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "Induction tutor adds themself as mentor using their own email address" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen

    when_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on(Cohort.current.description)
    then_i_am_taken_to_fip_induction_dashboard

    when_i_navigate_to_mentors_dashboard
    when_i_click_to_add_a_new_mentor
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "Mentor"
    and_i_click_on_continue
    then_i_am_taken_to_the_what_we_need_from_mentor_page

    when_i_click_on_continue
    then_i_am_taken_to_add_mentor_full_name_page

    when_i_add_mentor_name(full_name: @induction_coordinator_profile.user.full_name)
    and_i_click_on_continue
    then_i_am_taken_to_add_sits_trn_page

    when_i_add_the_trn(full_name: @induction_coordinator_profile.user.full_name)
    and_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page(full_name: @induction_coordinator_profile.user.full_name)

    when_i_add_sits_date_of_birth
    and_i_click_on_continue
    then_i_am_taken_to_add_sits_email_page

    when_i_add_sits_email
    and_i_click_on_continue
    then_i_am_taken_to_are_you_sure_page

    when_i_click_on_confirm
    then_i_am_taken_to_choose_mentor_partnership_page(full_name: @induction_coordinator_profile.full_name)

    when_i_choose_current_providers
    and_i_click_on_continue
    then_i_am_taken_to_check_answers_page

    when_i_click_confirm_and_add
    then_i_am_taken_to_sit_mentor_added_confirmation_page

    and_the_mentor_has_been_added_to_the_active_registration_cohort
  end
end
