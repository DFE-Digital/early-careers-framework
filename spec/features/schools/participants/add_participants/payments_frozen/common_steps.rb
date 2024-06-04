# frozen_string_literal: true

def given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
  school = create(:school, name: "FIP School")
  delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
  lead_provider = create(:lead_provider, name: "Big Provider Ltd")

  (2021..2024).each do |year|
    cohort = Cohort.find_or_create_by!(start_year: year)
    school_cohort = SchoolCohort.create!(cohort:, school:, induction_programme_choice: "full_induction_programme")
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership: nil)
    school_cohort.update!(default_induction_programme: induction_programme)
    partnership = create(:partnership, school:, lead_provider:, delivery_partner:, cohort:, challenge_deadline: 2.weeks.ago)
    induction_programme.update!(partnership:)

    # Magic instance vars necessary for subsequent steps (!)
    @school ||= school
    @school_cohort ||= school_cohort
    @induction_programme ||= induction_programme
  end
end

def earliest_cohort
  Cohort.find_by(start_year: 2021)
end

def and_the_earliest_cohort_has_payments_frozen
  earliest_cohort.update!(payments_frozen_at: 1.day.ago)
end

def when_i_complete_all_the_wizard_steps
  when_i_click_on_continue
  then_i_am_taken_to_add_mentor_full_name_page

  when_i_add_mentor_name
  and_i_click_on_continue
  then_i_am_taken_to_add_teachers_trn_page

  when_i_add_the_trn
  and_i_click_on_continue
  then_i_am_taken_to_add_date_of_birth_page

  when_i_add_a_date_of_birth
  and_i_click_on_continue
  then_i_am_taken_to_add_ect_or_mentor_email_page

  when_i_add_ect_or_mentor_email
  and_i_click_on_continue
  then_i_am_taken_to_choose_mentor_partnership_page

  when_i_choose_current_providers
  and_i_click_on_continue
  then_i_am_taken_to_check_answers_page

  when_i_click_confirm_and_add
end

def and_i_am_adding_a_participant_with_an_induction_start_date_in_the_cohort_with_payments_frozen
  set_participant_data
  @participant_data[:start_date] = Date.new(earliest_cohort.start_year, 9, 1)
  set_dqt_validation_result
end

def then_i_see_confirmation_that_the_participant_has_been_added
  expect(page).to have_content("#{@participant_data[:full_name]} has been added as an ECT")
end

def and_the_participant_has_been_added_to_the_active_registration_cohort
  expect(ParticipantProfile::ECT.last.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
end

def and_the_mentor_has_been_added_to_the_active_registration_cohort
  expect(ParticipantProfile::Mentor.last.school_cohort.cohort).to eq(Cohort.active_registration_cohort)
end
