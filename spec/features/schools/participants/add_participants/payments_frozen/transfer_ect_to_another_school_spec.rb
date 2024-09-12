# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"
require_relative "./common_steps"

RSpec.describe "SIT transfers ECT to another school", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "when target cohort payments are frozen" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_there_is_another_school_that_has_chosen_fip_in_the_payments_frozen_cohort_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_signed_in_as_an_induction_coordinator_for_the_transfer_school
    and_i_am_transfering_an_ect_in_a_cohort_with_payments_frozen_between_schools
    and_i_click_on(Cohort.current.description)

    when_i_navigate_to_ect_dashboard
    when_i_click_to_add_a_new_ect
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "ECT"
    when_i_click_on_continue

    then_i_am_taken_to_the_what_we_need_from_you_page

    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_name
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    when_i_click_on_continue

    then_i_should_be_on_the_confirm_transfer_page
    when_i_complete_transfer_steps

    when_i_click_confirm_and_add
    then_i_see_confirmation_that_the_participant_has_been_added

    and_the_participant_has_been_transfered_to_another_school
    and_the_participant_has_been_added_to_the_active_registration_cohort
  end

  scenario "when an unfinished mentor is assigned" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_there_is_another_school_that_has_chosen_fip_in_the_payments_frozen_cohort_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_i_am_signed_in_as_an_induction_coordinator_for_the_transfer_school

    and_i_have_added_a_mentor_in_cohort(earliest_cohort, school: target_school)
    and_i_am_transfering_an_ect_in_a_cohort_with_payments_frozen_between_schools
    and_i_click_on(Cohort.current.description)

    when_i_navigate_to_ect_dashboard
    when_i_click_to_add_a_new_ect
    then_i_should_be_on_the_who_to_add_page

    when_i_select_to_add_a "ECT"
    when_i_click_on_continue

    then_i_am_taken_to_the_what_we_need_from_you_page

    when_i_click_on_continue
    then_i_am_taken_to_add_ect_name_page

    when_i_add_ect_name
    when_i_click_on_continue
    then_i_am_taken_to_add_teachers_trn_page

    when_i_add_the_trn
    when_i_click_on_continue
    then_i_am_taken_to_add_date_of_birth_page

    when_i_add_a_date_of_birth
    when_i_click_on_continue

    then_i_should_be_on_the_confirm_transfer_page
    when_i_click_on_confirm
    then_i_should_be_on_the_teacher_start_date_page

    when_i_add_a_valid_start_date
    when_i_click_on_continue
    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email(email: @participant_data[:email])
    when_i_click_on_continue
    then_i_am_taken_to_choose_mentor_page

    when_i_select("Cohort Mentor")
    when_i_click_on_continue
    when_i_choose_yes
    when_i_click_on_continue
    then_i_am_taken_to_check_details_page

    when_i_click_confirm_and_add
    then_i_see_confirmation_that_the_participant_has_been_added

    and_the_participant_has_been_transfered_to_another_school
    and_the_participant_has_been_added_to_the_active_registration_cohort
    and_the_mentor_has_been_added_to_the_active_registration_cohort
  end

  def and_i_am_transfering_an_ect_in_a_cohort_with_payments_frozen_between_schools
    # Setup here is for a participant at Fip School to be transferred to Target Fip School
    # They are currently in the earliest cohort, which has payments frozen.
    set_participant_data
    user = create(:user, full_name: @participant_data[:full_name], email: @participant_data[:email])

    teacher_profile = create(:teacher_profile, user:, trn: @participant_data[:trn])
    schedule = create(:ecf_schedule, cohort: earliest_cohort)
    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:ect_participant_profile, teacher_profile:,
                                 participant_identity:,
                                 schedule:, school_cohort: @school_cohort,
                                 induction_start_date: Date.new(earliest_cohort.start_year, 9, 1))

    create(:ecf_participant_validation_data, participant_profile:,
           full_name: "Sally Teacher", trn: @participant_data[:trn], date_of_birth: @participant_data[:date_of_birth])
    induction_programme = InductionProgramme.find_by(school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile:, induction_programme:)

    create(:ect_participant_declaration, participant_profile:, cpd_lead_provider:, state: :eligible)
    set_dqt_validation_result
  end

  def then_i_should_be_on_the_confirm_transfer_page
    expect(page).to have_selector("h1", text: "Confirm #{@participant_data[:full_name]} is moving from another school")
  end

  def then_i_should_be_on_the_teacher_start_date_page
    expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} moving to your school?")
  end

  def when_i_complete_transfer_steps
    click_on "Confirm"

    then_i_should_be_on_the_teacher_start_date_page
    when_i_add_a_valid_start_date
    when_i_click_on_continue

    then_i_am_taken_to_add_ect_or_mentor_email_page

    when_i_add_ect_or_mentor_email(email: @participant_data[:email])
    when_i_click_on_continue
    choose "Yes"
    click_on "Continue"
  end

  def when_i_add_a_valid_start_date
    legend = "When is #{@participant_data[:full_name]} moving to your school?"

    fill_in_date(legend, with: "#{Cohort.active_registration_cohort.start_year}-10-24")
  end

  def and_the_participant_has_been_transfered_to_another_school
    expect(school_transfer_induction_record.school_cohort.school).to eq(target_school)
  end

  def and_the_participant_has_been_added_to_the_active_registration_cohort
    expect(school_transfer_induction_record.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
  end

  def school_transfer_induction_record
    InductionRecord.find_by(school_transfer: true)
  end
end
