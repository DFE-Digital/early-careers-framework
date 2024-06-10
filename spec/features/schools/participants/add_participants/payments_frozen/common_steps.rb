# frozen_string_literal: true

def given_there_is_a_school_that_has_chosen_fip_for_four_cohorts_and_partnered
  (2021..2024).each do |year|
    cohort = Cohort.find_or_create_by!(start_year: year)
    school_cohort = SchoolCohort.create!(cohort:, school:, induction_programme_choice: "full_induction_programme")
    induction_programme = create(:induction_programme, :fip, school_cohort:, partnership: nil)
    school_cohort.update!(default_induction_programme: induction_programme)
    partnership = create(:partnership, school:, lead_provider:, delivery_partner:, cohort:)
    induction_programme.update!(partnership:)

    # Magic instance vars necessary for subsequent steps (!)
    @school_cohort ||= school_cohort
    @induction_programme ||= induction_programme
  end
end

def earliest_cohort
  Cohort.find_by(start_year: 2021)
end

def school
  @school ||= FactoryBot.create(:school, name: "FIP School")
end

def target_school
  @target_school ||= FactoryBot.create(:school, name: "Target Fip School")
end

def cpd_lead_provider
  @cpd_lead_provider ||= FactoryBot.create(:cpd_lead_provider, :with_lead_provider, name: "CPD Provider Ltd")
end

def lead_provider
  @lead_provider ||= LeadProvider.find_by(cpd_lead_provider:)
end

def delivery_partner
  @delivery_partner ||= FactoryBot.create(:delivery_partner, name: "Amazing Delivery Team")
end

def and_the_earliest_cohort_has_payments_frozen
  earliest_cohort.update!(payments_frozen_at: 1.day.ago)
end

def and_there_is_another_school_that_has_chosen_fip_in_the_payments_frozen_cohort_and_partnered
  target_school_cohort = create(:school_cohort, school: target_school,
                                cohort: earliest_cohort, induction_programme_choice: "full_induction_programme")
  induction_programme = create(:induction_programme, :fip, school_cohort: target_school_cohort, partnership: nil)
  target_school_cohort.update!(default_induction_programme: induction_programme)
  partnership = create(:partnership, school: target_school,
                       lead_provider:, delivery_partner:, cohort: earliest_cohort)
  induction_programme.update!(partnership:)

  current_target_school_cohort = create(:school_cohort, school: target_school,
                                        cohort: Cohort.active_registration_cohort, induction_programme_choice: "full_induction_programme")
  current_induction_programme = create(:induction_programme, :fip, school_cohort: current_target_school_cohort, partnership: nil)
  current_partnership = create(:partnership, school: target_school)
  current_induction_programme.update!(partnership: current_partnership)
end

def and_i_am_signed_in_as_an_induction_coordinator_for_the_transfer_school
  induction_coordinator_profile = create(
    :induction_coordinator_profile,
    schools: [target_school],
    user: create(:user, full_name: "Carl Coordinator"),
  )
  create(:participant_identity, user: induction_coordinator_profile.user)
  privacy_policy = create(:privacy_policy)
  privacy_policy.accept!(induction_coordinator_profile.user)
  sign_in_as induction_coordinator_profile.user
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
