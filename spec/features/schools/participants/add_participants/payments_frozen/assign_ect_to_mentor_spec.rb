# frozen_string_literal: true

require "rails_helper"
require_relative "../../../training_dashboard/manage_training_steps"
require_relative "./common_steps"

RSpec.describe "SIT assigns a mentor to an ECT", js: true, mid_cohort: true do
  include ManageTrainingSteps

  scenario "when payments are frozen for cohort" do
    given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
    and_the_earliest_cohort_has_payments_frozen
    and_there_is_an_ect_in_the_active_registration_cohort
    and_there_is_a_mentor_in_the_earliest_cohort
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click_on(Cohort.current.description)

    when_i_navigate_to_ect_dashboard
    and_i_assign_the_ect_a_mentor
    then_i_see_confirmation_that_the_mentor_has_been_assigned

    and_the_mentor_has_been_assigned_to_the_active_registration_cohort
  end

  def and_there_is_an_ect_in_the_active_registration_cohort
    set_participant_data
    user = create(:user, full_name: @participant_data[:full_name], email: @participant_data[:email])

    teacher_profile = create(:teacher_profile, user:, trn: @participant_data[:trn])
    schedule = create(:ecf_schedule, cohort: active_registration_cohort)
    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:ect_participant_profile, teacher_profile:,
                                 participant_identity:,
                                 schedule:, school_cohort: @school_cohort,
                                 induction_start_date: Date.new(active_registration_cohort.start_year, 9, 1),
                                 induction_completion_date: Date.new(active_registration_cohort.start_year + 1, 9, 1))
    # FIXME: This factory fails validation on participant_id, despite this being present on participant identity.
    # Stubbing the eligibility check to return the participant_profile for now.
    # create(:ect_participant_declaration, participant_profile:, declaration_type: "completed")
    allow(ParticipantProfile::ECT).to receive(:eligible_to_change_cohort_and_continue_training)
      .and_return(ParticipantProfile::ECT.where(id: participant_profile.id))

    induction_programme = InductionProgramme.find_by(school_cohort: active_registration_school_cohort)
    create(:ecf_participant_validation_data, participant_profile:,
           full_name: @participant_data[:full_name], trn: @participant_data[:trn], date_of_birth: Date.new(1990, 10, 24))

    set_dqt_validation_result

    Induction::Enrol.call(participant_profile:, induction_programme:)
  end

  def active_registration_cohort
    Cohort.active_registration_cohort
  end

  def active_registration_school_cohort
    SchoolCohort.find_by(cohort: Cohort.active_registration_cohort)
  end

  def and_there_is_a_mentor_in_the_earliest_cohort
    mentor_name = "Sally Mentor"
    mentor_email = "sally.mentor@example.com"
    mentor_trn = "1001000"

    user = create(:user, full_name: mentor_name, email: mentor_email)
    teacher_profile = create(:teacher_profile, user:, trn: "1001000")
    schedule = create(:ecf_schedule, cohort: earliest_cohort)
    participant_identity = create(:participant_identity, user:)
    participant_profile = create(:mentor_participant_profile, teacher_profile:,
                                 participant_identity:,
                                 schedule:, school_cohort: @school_cohort,
                                 induction_start_date: Date.new(earliest_cohort.start_year, 9, 1))

    # FIXME: This factory fails validation on participant_id, despite this being present on participant identity.
    # Stubbing the eligibility check to return the participant_profile for now.
    # create(:ect_participant_declaration, participant_profile:, declaration_type: "completed")
    allow(ParticipantProfile::Mentor).to receive(:eligible_to_change_cohort_and_continue_training)
      .and_return(ParticipantProfile::Mentor.where(id: participant_profile.id))

    induction_programme = InductionProgramme.find_by(school_cohort: @school_cohort)
    create(:ecf_participant_validation_data, participant_profile:,
           full_name: mentor_name, trn: mentor_trn, date_of_birth: Date.new(1990, 10, 24))

    set_dqt_validation_result

    Induction::Enrol.call(participant_profile:, induction_programme:)
  end

  def and_i_assign_the_ect_a_mentor
    click_on "Mentors"
    click_on "Sally Mentor"
    click_on "Assign an ECT to this mentor"
    choose @participant_data[:full_name]
    click_on "Continue"
  end

  def then_i_see_confirmation_that_the_mentor_has_been_assigned
    expect(page).to have_content("Currently mentoring\n#{@participant_data[:full_name]}")
  end

  def and_the_mentor_has_been_assigned_to_the_active_registration_cohort
    mentor_profile = ParticipantProfile::Mentor.last
    expect(mentor_profile.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
  end
end
