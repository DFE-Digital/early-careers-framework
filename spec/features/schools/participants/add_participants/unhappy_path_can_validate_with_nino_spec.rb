# frozen_string_literal: true

require "rails_helper"
require_relative "../../training_dashboard/manage_training_steps"

RSpec.describe "Add participants", js: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
    and_i_have_added_an_ect
    and_i_have_added_a_mentor
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on(@cohort.description)
    then_i_am_taken_to_fip_induction_dashboard
    set_dqt_validation_with_nino
  end

  scenario "Induction tutor can add new ECT participant when dqt returns a match with nino" do
    when_i_navigate_to_participants_dashboard
    and_i_choose_to_add_an_ect_or_mentor_on_the_school_participants_dashboard_page
    and_i_choose_to_add_a_new_ect_on_the_school_add_participant_wizard

    when_i_add_full_name_to_the_school_add_participant_wizard @participant_data[:full_name]
    and_i_add_teacher_reference_number_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:trn]
    and_i_add_date_of_birth_to_the_school_add_participant_wizard @participant_data[:date_of_birth]
    and_i_confirm_details_and_continue_on_the_school_add_participant_wizard
    and_i_add_nino_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:nino]
    and_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", @participant_data[:email]
    and_i_choose_a_mentor_on_the_school_add_participant_wizard @participant_profile_mentor.full_name
    and_i_confirm_and_add_on_the_school_add_participant_wizard

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_on_the_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "ECT"
  end

  scenario "Induction tutor can add new mentor participant when dqt returns a match with nino" do
    when_i_navigate_to_participants_dashboard
    and_i_choose_to_add_an_ect_or_mentor_on_the_school_participants_dashboard_page
    and_i_choose_to_add_a_new_mentor_on_the_school_add_participant_wizard

    when_i_add_mentor_full_name_to_the_school_add_participant_wizard @participant_data[:full_name]
    and_i_add_teacher_reference_number_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:trn]
    and_i_add_date_of_birth_to_the_school_add_participant_wizard @participant_data[:date_of_birth]
    and_i_confirm_details_and_continue_on_the_school_add_participant_wizard
    and_i_add_nino_to_the_school_add_participant_wizard @participant_data[:full_name], @participant_data[:nino]
    and_i_add_email_address_to_the_school_add_participant_wizard "Sally Teacher", @participant_data[:email]
    and_i_confirm_and_add_on_the_school_add_participant_wizard

    then_i_am_on_the_school_add_participant_completed_page
    and_i_confirm_has_full_name_on_the_school_add_participant_completed_page @participant_data[:full_name]
    and_i_confirm_has_participant_type_on_the_school_add_participant_completed_page "Mentor"
  end
end
