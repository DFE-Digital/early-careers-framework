# frozen_string_literal: true

module ManageTrainingSteps
  include Capybara::DSL

  # Given_steps

  def given_there_is_a_school_that_has_chosen_fip_and_partnered
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort, partnership: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    @partnership = create(:partnership, school: @school, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort, challenge_deadline: 2.weeks.ago)
    @induction_programme.update!(partnership: @partnership)
  end

  def given_there_is_a_sit
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school])
    create(:participant_identity, user: @induction_coordinator_profile.user)
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
  end

  def given_there_is_a_sit_and_mentor_in_difference_schools
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school], user: create(:user, full_name: @participant_data[:full_name], email: @participant_data[:email]))
    create(:participant_identity, user: @induction_coordinator_profile.user)
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    @mentor = create(:mentor)
    @mentor.user.teacher_profile.update!(trn: @participant_data[:trn])
    ECFParticipantValidationData.create!(
      participant_profile: @mentor,
      trn: @participant_data[:trn],
      date_of_birth: @participant_data[:date_of_birth],
    )
  end

  def given_there_is_a_mentor_in_another_school
    @mentor = create(:mentor)
    @mentor.user.teacher_profile.update!(trn: @participant_data[:trn])
    ECFParticipantValidationData.create!(
      participant_profile: @mentor,
      trn: @participant_data[:trn],
      date_of_birth: @participant_data[:date_of_birth],
    )
  end

  def given_there_is_a_school_that_has_chosen_fip
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort, partnership: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_previous_cohort
    @cohort = Cohort.previous || create(:cohort, :previous)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort, partnership: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_two_consecutive_years_and_partnered
    given_there_is_a_school_that_has_chosen_fip_and_partnered
    @cohort2 = Cohort.previous || create(:cohort, :previous)
    @partnership2 = @partnership.dup
    @partnership2.cohort = @cohort2
    @partnership2.save!
    @school_cohort2 = create(:school_cohort, :fip, school: @school, cohort: @cohort2)
    @induction_programme2 = create(:induction_programme, :fip, school_cohort: @school_cohort2, partnership: @partnership2)
    @school_cohort2.update!(default_induction_programme: @induction_programme2)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_previous_and_current_cohort_and_partnered
    given_there_is_a_school_that_has_chosen_fip_for_previous_cohort_and_partnered
    @cohort_current = Cohort.current || create(:cohort, :current)
    @partnership_current = @partnership.dup
    @partnership_current.cohort = @cohort_current
    @partnership_current.save!
    @school_cohort_current = create(:school_cohort, :fip, school: @school, cohort: @cohort_current)
    @induction_programme_current = create(:induction_programme, :fip, school_cohort: @school_cohort_current, partnership: @partnership_current)
    @school_cohort_current.update!(default_induction_programme: @induction_programme_current)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_previous_cohort_and_partnered
    given_there_is_a_school_that_has_chosen_fip_for_previous_cohort
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    @partnership = create(:partnership, school: @school, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort, challenge_deadline: 2.weeks.ago)
    @induction_programme.update!(partnership: @partnership)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_current_and_next_cohorts_and_partnered
    given_there_is_a_school_that_has_chosen_fip_for_previous_and_current_cohort_and_partnered
    @cohort_next = Cohort.next || create(:cohort, :next)
    @school_cohort_next = create(:school_cohort, :fip, school: @school, cohort: @cohort_next)
    @induction_programme_next = create(:induction_programme, :fip, school_cohort: @school_cohort_next, partnership: @partnership_current)
    @school_cohort_next.update!(default_induction_programme: @induction_programme_next)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_previous_cohort_and_partnered_but_challenged
    given_there_is_a_school_that_has_chosen_fip_for_previous_cohort
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    @partnership = create(:partnership, school: @school, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort, challenge_deadline: 1.week.from_now, challenged_at: 1.day.ago, challenge_reason: "mistake")
    @induction_programme.update!(partnership: @partnership)
  end

  def given_there_is_a_school_that_has_chosen_cip
    @cip = create(:core_induction_programme, name: "CIP Programme 1")
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "CIP School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "core_induction_programme")
    @induction_programme = create(:induction_programme, :cip, school_cohort: @school_cohort, core_induction_programme: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen_cip_for_previous_cohort
    @cip = create(:core_induction_programme, name: "CIP Programme 1")
    @cohort = Cohort.previous || create(:cohort, :previous)
    @school = create(:school, name: "CIP School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "core_induction_programme")
    @induction_programme = create(:induction_programme, :cip, school_cohort: @school_cohort, core_induction_programme: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen_cip_for_the_current_year
    @cip = create(:core_induction_programme, name: "CIP Programme 1")
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "CIP School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "core_induction_programme")
    @induction_programme = create(:induction_programme, :cip, school_cohort: @school_cohort, core_induction_programme: nil)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen(induction_programme_choice:)
    @school_cohort = create(:school_cohort, induction_programme_choice:, school: create(:school, name: "Test School"))
    create(:school_cohort,
           school: @school_cohort.school,
           cohort: Cohort.previous || create(:cohort, :previous),
           induction_programme_choice: :design_our_own)
  end

  def given_there_is_a_school_with_participants_in_every_cohort_since_2021
    @school = create(:school, :cip_only)
    @sit = create(:induction_coordinator_profile, schools: [@school])

    Cohort.where(start_year: 2021..).find_each do |cohort|
      school_cohort = create(:school_cohort, :cip, school: @school, cohort:)
      induction_programme = create(:induction_programme, :cip, school_cohort:)

      user = create(:user)
      ect = create(:ect_participant_profile, user:, school_cohort:)

      Induction::Enrol.call(participant_profile: ect, induction_programme:)
    end
  end

  def given_there_are_multiple_schools_and_an_induction_coordinator
    cohort = create :cohort, :current

    first_school = create :school, name: "Test School 1", slug: "111111-test-school-1", urn: "111111"
    create(:school_cohort, :cip, school: first_school, cohort:)

    second_school = create :school, name: "Test School 2", slug: "111112-test-school-2", urn: "111112"
    create(:school_cohort, :cip, school: second_school, cohort:)

    user = create :user, full_name: "School Leader", email: "school-leader@example.com"
    create :induction_coordinator_profile, user:, schools: [first_school, second_school]

    third_school = FactoryBot.create(:school, name: "Test School 3", slug: "111113-test-school-3", urn: "111113")
    create :school_cohort, :cip, school: third_school, cohort:
  end

  def given_there_is_a_school_that_has_chosen_design_our_own
    @cohort = Cohort.current || create(:cohort, :current)
    @school = create(:school, name: "Design Our Own Programme School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "design_our_own")
  end

  def given_there_is_a_school_that_has_chosen_design_our_own_for_previous_cohort
    @cohort = Cohort.previous || create(:cohort, :previous)
    @school = create(:school, name: "Design Our Own Programme School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "design_our_own")
  end

  def given_there_is_a_school_that_has_chosen_no_ect_for_previous_cohort
    @cohort = Cohort.previous || create(:cohort, previous)
    @school = create(:school, name: "No ECT Programme School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "no_early_career_teachers")
    create(:school_cohort, school: @school, cohort: Cohort.find_by(start_year: 2020) || create(:cohort, start_year: 2020))
  end

  def given_i_am_on_the_cip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Programme materials")
  end

  def given_i_am_taken_to_fip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_summary_row("Lead provider", @school_cohort.lead_provider.name)
    expect(page).to have_summary_row("Delivery partner", @school_cohort.delivery_partner.name)
  end
  alias_method :given_i_am_taken_to_the_induction_dashboard, :given_i_am_taken_to_fip_induction_dashboard

  def given_the_ect_has_been_validated
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect)
  end

  def given_an_ect_has_been_withdrawn_by_the_provider
    @participant_profile_ect.training_status_withdrawn!
    @participant_profile_ect.induction_records.latest.training_status_withdrawn!
  end

  alias_method :and_an_ect_has_been_withdrawn_by_the_provider, :given_an_ect_has_been_withdrawn_by_the_provider

  # And_steps

  def and_i_dont_see_appropriate_body
    expect(page).to_not have_summary_row("Appropriate body", "")
  end

  def and_i_see_no_appropriate_body_selected
    expect(page).to have_summary_row("Appropriate body", "")
  end

  def and_i_can_change_the_appropriate_body
    expect(page).to have_summary_row_action("Appropriate body", "Change Appropriate body")
  end

  def and_i_can_manage_ects_and_mentors
    expect(page).to have_link("Early career teachers")
    expect(page).to have_link("Mentors")
  end

  alias_method :then_i_can_manage_ects_and_mentors, :and_i_can_manage_ects_and_mentors

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort.school], user: create(:user, full_name: "Carl Coordinator"))
    create(:participant_identity, user: @induction_coordinator_profile.user)
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
    set_participant_data
    set_updated_participant_data
  end

  alias_method :when_i_am_signed_in_as_an_induction_coordinator, :and_i_am_signed_in_as_an_induction_coordinator

  def and_i_have_added_an_ect
    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user:)
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile:, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ect_with_email(email)
    user = create(:user, full_name: "Sally Teacher", email:)
    teacher_profile = create(:teacher_profile, user:)
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile:, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_mentor
    user = create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com")
    teacher_profile = create(:teacher_profile, user:)
    @participant_profile_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @participant_profile_mentor, school: @school)
  end

  def and_i_have_added_a_mentor_who_completed_training
    and_i_have_added_a_mentor
    @participant_profile_mentor.complete_training! completion_date: Time.zone.today, completion_reason: "completed_declaration_received"
  end

  def and_i_see_the_status_training_completed
    expect(page).to have_summary_row("Status", "Training completed")
  end

  def and_i_dont_see_the_status_training
    expect(page).to_not have_summary_row("Status", "Training completed")
  end

  def and_i_have_added_an_eligible_ect_with_mentor
    user = create(:user, full_name: "Eligible With-mentor")
    teacher_profile = create(:teacher_profile, user:)
    @eligible_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @eligible_ect_with_mentor, induction_programme: @induction_programme, mentor_profile: @contacted_for_info_mentor)
  end

  def and_i_have_added_an_eligible_ect_without_mentor
    user = create(:user, full_name: "Eligible Without-mentor")
    teacher_profile = create(:teacher_profile, user:)
    @eligible_ect_without_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @eligible_ect_without_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_eligible_ect
    @eligible_ect = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Eligible ect"), school_cohort: @school_cohort)
    @induction_record = Induction::Enrol.call(participant_profile: @eligible_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ineligible_ect
    @ineligible_ect = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible ect"), school_cohort: @school_cohort)
    @ineligible_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ineligible_ect_without_mentor
    @ineligible_ect_without_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible Without-mentor"), school_cohort: @school_cohort)
    @ineligible_ect_without_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_ect_without_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_eligible_mentor
    @eligible_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Eligible mentor"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @eligible_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @eligible_mentor, school: @school)
  end

  def and_i_have_added_an_ineligible_ect_with_mentor
    @ineligible_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible With-mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    @ineligible_ect_with_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_ect_with_mentor, induction_programme: @induction_programme, mentor_profile: @contacted_for_info_mentor)
  end

  def and_i_have_added_an_ineligible_mentor
    @ineligible_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible mentor"), school_cohort: @school_cohort)
    @ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @ineligible_mentor, school: @school)
  end

  def and_i_have_added_a_contacted_for_info_ect_with_mentor
    @contacted_for_info_ect_with_mentor = create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, user: create(:user, full_name: "CFI With-mentor"), mentor_profile_id: @participant_profile_mentor.id, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @contacted_for_info_ect_with_mentor, induction_programme: @induction_programme, mentor_profile: @participant_profile_mentor)
  end

  def and_i_have_added_a_training_ect_with_mentor
    @training_ect_with_mentor = create(:ect_participant_profile, user: create(:user, full_name: "Training ECT With-mentor"), mentor_profile_id: @participant_profile_mentor.id, school_cohort: @school_cohort, induction_start_date: 2.years.ago)
    Induction::Enrol.call(participant_profile: @training_ect_with_mentor, induction_programme: @induction_programme, mentor_profile: @participant_profile_mentor)
  end

  def and_i_have_added_another_training_ect_with_mentor
    user = create(:user, full_name: "Another training With-mentor")
    teacher_profile = create(:teacher_profile, user:)
    @another_training_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort, induction_start_date: 1.year.ago)
    Induction::Enrol.call(participant_profile: @another_training_ect_with_mentor, induction_programme: @induction_programme, mentor_profile: @contacted_for_info_mentor)
  end

  def and_i_have_added_an_ero_mentor
    @ero_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "ero mentor"), school_cohort: @school_cohort)
    @ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    Induction::Enrol.call(participant_profile: @ero_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @ero_mentor, school: @school)
  end

  def and_i_have_added_a_contacted_for_info_ect_without_mentor
    @contacted_for_info_ect_without_mentor = create(:ect_participant_profile, :email_bounced, request_for_details_sent_at: 5.days.ago, user: create(:user, full_name: "CFI Without-mentor"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @contacted_for_info_ect_without_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ect_contacted_for_info
    @contacted_for_info_ect = create(:ect_participant_profile, request_for_details_sent_at: 5.days.ago, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @contacted_for_info_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ect_whose_details_are_being_checked
    @details_being_checked_ect = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, school_cohort: @school_cohort)
    @details_being_checked_ect.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    Induction::Enrol.call(participant_profile: @details_being_checked_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_transferring_in_participant
    user = create(:user, full_name: "Transferring in participant")
    teacher_profile = create(:teacher_profile, user:)
    @transferring_in_participant = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort)
    @induction_record = Induction::Enrol.call(participant_profile: @transferring_in_participant,
                                              induction_programme: @induction_programme,
                                              start_date: 2.months.from_now)
  end

  def and_i_have_added_a_deferred_ect
    user = create(:user, full_name: "Deferred participant")
    teacher_profile = create(:teacher_profile, user:)
    @deferred_participant = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort, training_status: :deferred)
    @induction_record = Induction::Enrol.call(participant_profile: @deferred_participant,
                                              induction_programme: @induction_programme,
                                              start_date: 2.months.from_now)
    @induction_record.update!(training_status: :deferred)
  end

  def and_i_have_added_an_ect_with_withdrawn_training
    user = create(:user, full_name: "Withdrawn training participant")
    teacher_profile = create(:teacher_profile, user:)
    @withdrawn_training_participant = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort, training_status: :withdrawn)
    @induction_record = Induction::Enrol.call(participant_profile: @withdrawn_training_participant,
                                              induction_programme: @induction_programme,
                                              start_date: 2.months.from_now)
    @induction_record.update!(training_status: :withdrawn)
  end

  def and_i_have_added_an_ect_with_withdrawn_induction_status
    user = create(:user, full_name: "Withdrawn training participant")
    teacher_profile = create(:teacher_profile, user:)
    @withdrawn_induction_status_participant = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile:, school_cohort: @school_cohort, status: :withdrawn)
    @induction_record = Induction::Enrol.call(participant_profile: @withdrawn_induction_status_participant,
                                              induction_programme: @induction_programme,
                                              start_date: 2.months.from_now)
    @induction_record.update!(induction_status: :withdrawn)
  end

  def and_my_ects_have_completed_their_induction
    Induction::Complete.call(participant_profile: @contacted_for_info_ect_without_mentor, completion_date: 1.week.ago)
    Induction::Complete.call(participant_profile: @eligible_ect_without_mentor, completion_date: 2.days.ago)
  end

  def and_the_ect_has_multiple_identities
    @ect_alternative_identity = create(:participant_identity, :secondary, user: @participant_profile_ect.user)
  end

  def given_a_participant_from_the_same_school_is_already_on_ecf
    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user:, trn: "1234567")
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile:, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1234567", date_of_birth: Date.new(1998, 3, 22))
  end

  def given_a_participant_from_a_different_school_is_already_on_ecf
    @school_three = create(:school, name: "Fip School 3")
    @school_cohort_three = create(:school_cohort, school: @school_three, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme_three = create(:induction_programme, :fip, school_cohort: @school_cohort_three)

    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user:, trn: "1234567")
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile:, school_cohort: @school_cohort_three)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme_three)
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1234567", date_of_birth: Date.new(1998, 3, 22))
  end

  def given_there_is_a_mentor_with_the_same_trn
    @mentor = create(:mentor)
    @mentor.user.teacher_profile.update!(trn: @participant_data[:trn])
    ECFParticipantValidationData.create!(
      participant_profile: @mentor,
      trn: @participant_data[:trn],
      date_of_birth: @participant_data[:date_of_birth],
    )
  end

  def and_i_have_a_transferring_out_participant
    and_i_have_added_an_eligible_ect
    @induction_record.leaving!(2.months.from_now)
  end

  def and_i_have_a_transferred_out_participant
    and_i_have_added_an_eligible_ect
    @induction_record.leaving!(1.day.ago)
  end

  def and_the_participant_is_displayed_unpartnered
    expect(page).to have_summary_row("Lead provider", "")
  end

  def and_the_participant_is_displayed_mentored_by(name)
    puts page.html
    expect(page).to have_summary_row("Mentor", name)
  end

  def then_i_am_taken_to_add_mentor_page
    expect(page).to have_selector("h1", text: "Who will")
  end

  def when_i_select_a_mentor
    choose(@participant_profile_mentor.full_name.to_s, allow_label_click: true)
  end

  def then_i_am_on_schools_page
    visit "/schools"
  end

  def then_i_should_see_the_add_your_ect_and_mentor_link
    expect(page).to have_text("Add your early career teacher and mentor details")
  end

  def then_i_am_taken_to_only_mentor_ects_at_your_school_page
    expect(page).to have_text("Will #{@participant_data[:full_name]} only mentor ECTs at your school?")
  end

  def then_i_should_see_the_participant_from_the_2021_cohort
    user_name = @school.school_cohorts.for_year(2021).last.ecf_participant_profiles.last.user.full_name
    expect(page).to have_text(user_name)
  end

  def then_i_am_taken_to_when_is_participant_moving_to_school_page
    expect(page).to have_text("When is #{@participant_data[:full_name]} moving to your school?")
  end

  def then_i_see_the_existing_mentor_name
    expect(page).to have_text(@mentor.user.full_name)
  end

  def then_i_see_induction_tutor_name
    expect(page).to have_summary_row("Induction tutor", @induction_coordinator_profile.user.full_name)
  end

  def then_i_should_be_on_the_who_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
  end

  def then_i_should_see_the_view_your_ect_and_mentor_link
    expect(page).to have_text("View your early career teacher and mentor details")
  end

  def then_i_should_see_the_program_and_click_to_change_it(program_label:)
    expect(page).to have_text(program_label)
    click_on "Change induction programme choice"
  end

  def then_i_can_change_the_programme_to_design_your_own
    expect(page).to have_text("Your school has told us you do not expect any ECTs")
    click_on "Tell us if this has changed"
    click_on "Continue"
    choose "Yes"
    click_on "Continue"
    choose("Design and deliver your own programme based on the early career framework (ECF)")
    click_on "Continue"
    click_on("Confirm")
    choose("No")
    click_on "Continue"
    click_on("Return to manage your training")
    expect(page).to have_content("Manage your training")
    expect(page).to have_summary_row("Programme", "Design and deliver your own programme based on the Early Career Framework (ECF)")
  end

  def and_i_click_on(string)
    page.click_on(string)
  end

  alias_method :when_i_click_on, :and_i_click_on

  def and_i_should_see_multiple_schools
    expect(page).to have_text("Test School 1")
    expect(page).to have_text("Test School 2")
    expect(page).not_to have_text("Test School 3")
  end

  def given_i_click_on_test_school_1
    click_on "Test School 1"
  end

  def given_i_click_on_test_school_2
    click_on "Test School 2"
  end

  def given_i_click_on_manage_your_schools
    click_on "Manage your schools"
  end

  def then_i_should_be_on_school_cohorts_page
    expect(current_path).to eq("/schools/#{@school_cohort.school.slug}")
  end

  def then_i_should_be_on_school_cohorts_1_page
    expect(current_path).to eq("/schools/111111-test-school-1")
  end

  def then_i_should_be_on_school_cohorts_2_page
    expect(current_path).to eq("/schools/111112-test-school-2")
  end

  def and_i_should_see_school_1_data
    expect(page).to have_text("Test School 1")
    expect(page).not_to have_text("Test School 2")
  end

  def and_i_should_see_school_2_data
    expect(page).to have_text("Test School 2")
    expect(page).not_to have_text("Test School 1")
  end

  def and_i_have_added_ects_and_mentors
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_added_an_eligible_ect
    and_i_have_added_an_ineligible_ect
    and_i_have_added_an_eligible_mentor
    and_i_have_added_an_ineligible_mentor
    and_i_have_added_an_ero_mentor
    and_i_have_added_an_ect_contacted_for_info
    and_i_have_added_an_ect_whose_details_are_being_checked
  end

  def and_i_have_added_a_contacted_for_info_mentor
    @contacted_for_info_mentor = create(:mentor_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, user: create(:user, full_name: "CFI Mentor"), school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @contacted_for_info_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @contacted_for_info_mentor, school: @school)
  end

  def and_i_am_signed_in_as_an_induction_coordinator_for_multiple_schools
    induction_coordinator = User.find_by(email: "school-leader@example.com")
    sign_in_as induction_coordinator
  end

  def and_see_the_other_programs_before_choosing(labels:, choice:)
    expect(page).to have_text "How do you want to run your training"
    labels.each { |label| expect(page).to have_selector(:label, text: label) }
    expect(page).to be_accessible

    choose choice
    click_on "Continue"

    expect(page).to have_text "Confirm your training programme"
    click_on "Confirm"

    unless choice == "We do not expect any early career teachers to join"
      choose "No"
      click_on "Continue"
    end
  end

  def and_i_have_added_a_details_being_checked_ect_with_mentor
    @details_being_checked_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "DBC With-Mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    @details_being_checked_ect_with_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    Induction::Enrol.call(participant_profile: @details_being_checked_ect_with_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_details_being_checked_ect_without_mentor
    @details_being_checked_ect_without_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "DBC Without-Mentor"), school_cohort: @school_cohort)
    @details_being_checked_ect_without_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    Induction::Enrol.call(participant_profile: @details_being_checked_ect_without_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_details_being_checked_mentor
    @details_being_checked_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "DBC Mentor"), school_cohort: @school_cohort)
    @details_being_checked_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "different_trn")
    Induction::Enrol.call(participant_profile: @details_being_checked_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @details_being_checked_mentor, school: @school)
  end

  def and_i_have_added_a_no_qts_ect_with_mentor
    @no_qts_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "No-qts With-Mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    @no_qts_ect_with_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    Induction::Enrol.call(participant_profile: @no_qts_ect_with_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_no_qts_ect_without_mentor
    @no_qts_ect_without_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "No-qts Without-Mentor"), school_cohort: @school_cohort)
    @no_qts_ect_without_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    Induction::Enrol.call(participant_profile: @no_qts_ect_without_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_no_qts_mentor
    @no_qts_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "No-qts Mentor"), school_cohort: @school_cohort)
    @no_qts_mentor.ecf_participant_eligibility.update!(status: "manual_check", reason: "no_qts")
    Induction::Enrol.call(participant_profile: @no_qts_mentor, induction_programme: @induction_programme)
    Mentors::AddToSchool.call(mentor_profile: @no_qts_mentor, school: @school)
  end

  def and_i_see_the_completion_status_tag
    expect(page).to have_text("Your appropriate body confirmed that this person completed their induction and training on #{@eligible_ect_without_mentor.induction_completion_date.to_fs(:govuk)}")
  end

  def and_it_should_not_allow_a_sit_to_edit_the_participant_details
    expect(page).not_to have_link("//a[text()='Change']")
  end

  alias_method :then_it_should_not_allow_a_sit_to_edit_the_participant_details, :and_it_should_not_allow_a_sit_to_edit_the_participant_details

  def and_i_click_on_view_your_early_career_teacher_and_mentor_details
    click_on("View your early career teacher and mentor details")
  end

  def and_they_have_an_end_date
    expect(page).to have_text(@induction_record.end_date.to_date.to_fs(:govuk))
  end

  def and_the_action_required_is_remove
    expect(page).to have_text("Remove")
  end

  def and_cohort_current_is_created
    Cohort.current || create(:cohort, :current)
  end

  def and_the_current_cohort_tab_is_selected
    expect(page).to have_text("Tell us if any new ECTs or mentors will start training at your school in the #{Cohort.previous.start_year} to Cohort.current.start_year} academic year")
  end

  # When_steps

  def when_i_choose_current_providers
    choose option: "current_providers"
  end

  def when_i_choose_previous_providers
    choose option: "previous_providers"
  end

  def when_i_choose_other_providers
    choose option: "other_providers"
  end

  def when_i_choose_yes
    choose("Yes")
  end

  def when_i_click_on_back
    click_on("Back")
  end

  def when_i_choose_to_cancel
    choose "Cancel and return to the list of ECTs and mentors"
  end

  def when_i_choose_to_add_myself_as_mentor
    choose "Add myself as a mentor instead"
  end

  def when_i_click_on_confirm
    click_on("Confirm")
  end

  alias_method :and_i_click_on_confirm, :when_i_click_on_confirm

  def when_i_filter_by(option)
    when_i_select(option)
    click_on("Apply")
  end

  def when_i_click_on_view_ects
    click_on "View your ECTs"
  end

  def when_i_click_on_view_mentors
    click_on "View your mentors"
  end

  def when_i_submit_an_empty_form
    when_i_click_on_continue
  end

  def when_i_click_on_continue
    click_on("Continue")
  end

  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def when_i_click_on_change
    click_on("Change")
  end

  def when_i_click_on_change_programme
    click_on("Change induction programme choice", visible: false)
  end

  def when_i_click_on_choose_materials
    click_on("Choose materials", visible: false)
  end

  def when_i_click_on_tell_us_if_this_has_changed
    click_on("Tell us if this has changed")
  end

  def when_i_click_on_add
    click_on("Add")
  end

  def when_i_click_confirm_and_add
    click_on("Confirm and add")
  end

  def when_i_click_on_view_details
    click_on("View details")
  end

  def when_i_click_on_add_ect
    click_on("Add a new ECT")
  end

  def when_i_click_on_add_mentor
    click_on("Add a new mentor")
  end

  def when_i_choose_to_add_yourself_as_a_mentor
    choose("Yourself as a mentor", allow_label_click: true)
  end

  def when_i_click_to_add_a_new_ect
    click_on "Add ECT"
  end
  alias_method :and_i_click_to_add_a_new_ect, :when_i_click_to_add_a_new_ect

  def when_i_click_to_add_a_new_mentor
    click_on "Add Mentor"
  end
  alias_method :and_i_click_to_add_a_new_mentor, :when_i_click_to_add_a_new_mentor

  def when_i_select_to_add_a(participant_type)
    choose(participant_type, allow_label_click: true)
  end

  def when_i_click_on_add_your_early_career_teacher_and_mentor_details
    click_on("Add your early career teacher and mentor details")
  end

  def when_i_click_on_check_what_each_role_needs_to_do
    click_on("Check what each role needs to do")
  end

  def when_i_decide_i_want_to_add_an_ect
    choose("ECT")
  end

  def when_i_click_on_sign_up
    click_on("Sign up")
  end

  def when_i_sign_back_in
    sign_in_as @induction_coordinator_profile.user
  end

  alias_method :when_i_sign_in_as_sit, :when_i_sign_back_in

  def when_i_click_on_change_name
    click_on("Change name", visible: false)
  end

  def when_i_click_on_change_email
    click_on("Change email", visible: false)
  end

  def when_i_click_on_change_mentor
    click_on("Change mentor", visible: false)
  end

  def when_i_click_on_change_term
    click_on("Change start term", visible: false)
  end

  def when_i_click_on_change_trn
    click_on("Change TRN", visible: false)
  end

  def when_i_choose_a_mentor
    choose(@participant_profile_mentor.full_name.to_s, allow_label_click: true)
  end

  def when_i_add_ect_name(full_name: @participant_data[:full_name])
    fill_in "What’s this ECT’s full name?", with: full_name
  end

  def when_i_add_mentor_name(full_name: @participant_data[:full_name])
    fill_in "What’s this mentor’s full name?", with: full_name
  end

  def when_i_add_ect_or_mentor_email(full_name: @participant_data[:full_name], email: @participant_data[:email])
    fill_in "What’s #{full_name}’s email address?", with: email
  end

  def when_i_add_sits_email
    when_i_add_ect_or_mentor_email(full_name: @induction_coordinator_profile.user.full_name, email: @induction_coordinator_profile.user.email)
  end

  def when_i_add_ect_or_mentor_nino_for(name)
    fill_in "What’s #{name}’s National Insurance number?", with: @participant_data[:nino]
  end

  def when_i_add_ect_or_mentor_email_that_already_exists
    fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: @participant_profile_ect.user.email
  end

  def when_i_choose_assign_mentor_later
    choose("Add or assign mentor later", allow_label_click: true)
  end

  def when_i_add_ect_or_mentor_updated_name
    fill_in "What’s this ECT’s full name?", with: @updated_participant_data[:full_name]
  end

  def when_i_add_ect_or_mentor_updated_email
    fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: @updated_participant_data[:email]
  end

  def when_i_choose_an_appropriate_body
    choose "National organisation"
    click_on "Continue"
    choose appropriate_body.name
    click_on "Continue"
  end

  def when_i_add_the_trn(full_name: @participant_data[:full_name], trn: @participant_data[:trn])
    fill_in "What’s #{full_name}’s teacher reference number (TRN)?", with: trn
  end

  def when_i_add_my_trn
    fill_in "What’s your teacher reference number (TRN)?", with: @sit_data[:trn]
  end

  def when_i_add_a_date_of_birth(full_name: @participant_data[:full_name])
    legend = "What’s #{full_name}’s date of birth?"
    date = @participant_data[:date_of_birth]

    fill_in_date(legend, with: date)
  end

  def when_i_add_sits_date_of_birth
    legend = "What’s #{@induction_coordinator_profile.user.full_name}’s date of birth?"
    date = @participant_data[:date_of_birth]

    fill_in_date(legend, with: date)
  end

  def when_i_add_my_date_of_birth
    date = @sit_data[:date_of_birth]
    legend = "What’s your date of birth?"

    fill_in_date(legend, with: date)
  end

  def when_i_add_a_start_date
    date = @participant_data[:start_date]

    # this method is used in several contexts (start at school, induction
    # start) so checking for the exact text is problematic. Just make sure
    # it contains 'start' (or 'moving' for transfers)
    legend = /start|moving/

    fill_in_date(legend, with: date)
  end

  def when_i_choose_materials
    click_on("Continue")
    choose("CIP Programme 1", allow_label_click: true)
    click_on("Continue")
  end

  def when_i_visit_manage_training_dashboard
    visit schools_dashboard_path(@school)
  end

  def when_i_click_on_the_participants_name(name)
    click_on name
  end

  def when_i_click_change_induction_start_date
    click_on "Change induction start date"
  end

  def when_i_go_to_manage_the_participant_named(name)
    click_on "Manage #{name}"
  end

  def when_i_navigate_to_ect_dashboard
    click_on("Early career teachers")
    then_i_am_taken_to_manage_ects_page
  end

  def when_i_navigate_to_mentors_dashboard
    click_on("Mentors")
    then_i_am_taken_to_manage_mentors_page
  end

  def when_i_change_ect_email
    fill_in "Change ECT’s email", with: @updated_participant_data[:email]
  end

  def when_i_change_ect_email_to_blank
    fill_in "Change ECT’s email", with: ""
  end

  def when_i_add_the_wrong_trn
    fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?", with: "1111111"
  end

  def when_i_select(option)
    choose(option)
  end

  def when_i_sort_participants_by_induction_start_date
    click_link("Induction start date")
  end

  def and_i_choose_induction_coordinator_and_mentor_role
    choose("Induction tutor and mentor")
    click_on("Continue")
  end

  # Then_steps

  def then_i_am_taken_to_check_answers_page
    expect(page).to have_text("Check your answers")
  end

  def then_i_am_taken_to_mentor_added_confirmation_page
    expect(page).to have_text("#{@participant_data[:full_name]} has been added as a mentor")
  end

  def then_i_am_taken_to_continue_current_training_page
    expect(page).to have_text("Will they continue with these training providers?")
  end

  def then_i_am_taken_to_sit_mentor_added_confirmation_page
    expect(page).to have_text("You’ve been added as a mentor")
  end

  def then_i_see_the_mentor_name
    expect(page).to have_text(@participant_data[:full_name])
  end

  def then_i_see_the_transferred_mentor_name
    expect(page).to have_text(@mentor.full_name)
  end

  def then_i_see_the_ects_filter_with_counts(currently_training: 0, completed_induction: 0, no_longer_training: 0)
    return unless [currently_training, completed_induction, no_longer_training].map(&:positive?).many?

    expect(page).to have_content("Currently training (#{currently_training})") if currently_training.positive?
    expect(page).to have_content("Completed induction (#{completed_induction})") if completed_induction.positive?
    expect(page).to have_content("No longer training (#{no_longer_training})") if no_longer_training.positive?
  end

  def then_i_see_the_mentors_filter_with_counts(currently_mentoring: 1, not_mentoring: 0)
    return unless [currently_mentoring, not_mentoring].map(&:positive?).many?

    expect(page).to have_content("Currently mentoring (#{currently_mentoring})") if currently_mentoring.positive?
    expect(page).to have_content("Not mentoring (#{not_mentoring})") if not_mentoring.positive?
  end

  def then_i_see_the_participants_filtered_by(selected_option)
    expect(page).to have_field("filtered-by-#{selected_option.downcase.parameterize}-field", checked: true, visible: false, type: :radio)
  end
  alias_method :and_i_see_the_participants_filtered_by, :then_i_see_the_participants_filtered_by

  def and_i_see_ects_not_being_trained
    expect(page).to have_content("Not mentoring or being mentored\nDeferred participant Training deferred")
  end

  def and_i_see_ects_with_induction_completed_sorted_by_decreasing_completion_date
    expect(page).to have_content("Teachers who have completed their induction\nEligible Without-mentor\nCompleted #{2.days.ago.to_date.to_fs(:govuk)}\nCFI Without-mentor\nCompleted #{1.week.ago.to_date.to_fs(:govuk)}")
  end

  def and_i_see_mentors_not_mentoring
    expect(page).to have_content("CFI Mentor\nMentoring Not currently mentoring")
  end

  def and_i_see_mentors_currently_mentoring
    expect(page).to have_content("Billy Mentor\nMentoring\nTraining ECT With-mentor\nInduction started #{2.years.ago.to_date.to_fs(:govuk)}")
  end

  def then_i_see_the_participant_name(full_name: @participant_data[:full_name])
    expect(page).to have_text(full_name)
  end

  def then_i_am_taken_to_manage_your_training_page
    expect(page).to have_selector("h1", text: "Manage your training")
  end

  def then_i_am_taken_to_add_yourself_as_mentor_confirmation_page
    expect(page).to have_text("Are you sure you want to add yourself as a mentor?")
  end

  def then_i_am_taken_to_sit_added_as_mentor_page
    expect(page).to have_text("#{@induction_coordinator_profile.user.full_name} has been added as a mentor")
  end

  def then_i_am_taken_to_roles_page
    expect(page).to have_selector("h1", text: "Check what each person needs to do in the early career teacher training programme")
    expect(page).to have_text("An induction tutor should only assign themself as a mentor in exceptional circumstances")
  end

  def then_i_am_taken_to_the_what_we_need_from_you_page
    expect(page).to have_text("What we need to know about this ECT")
  end

  def then_i_am_taken_to_the_what_we_need_from_mentor_page
    expect(page).to have_text("What we need to know about this mentor")
  end

  def then_i_am_taken_to_manage_ects_page
    expect(page).to have_selector("h1", text: "Early career teachers (ECTs)")
    expect(page).to have_text("Add ECT")
  end

  def then_i_am_taken_to_manage_mentors_page
    expect(page).to have_selector("h1", text: "Mentors")
    expect(page).to have_text("Add Mentor")
  end

  def then_i_am_taken_to_are_you_sure_page
    expect(page).to have_selector("h1", text: "Are you sure you want to add yourself as a mentor?")
    expect(page).to have_text("The induction tutor and mentor roles are separate")
  end

  def then_i_am_taken_to_the_ect_already_started_page
    expect(page).to have_selector("h1", text: "Has this ECT already started their induction at another school?")
  end

  def then_i_am_taken_to_the_mentor_already_started_page
    expect(page).to have_selector("h1", text: "Has this person already started mentoring ECTs at another school?")
  end

  def then_i_am_taken_to_the_who_do_you_want_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
  end

  def then_i_should_be_on_the_what_we_need_from_you_page
    expect(page).to have_selector("h1", text: "What we need to know about this ECT")
  end

  def then_i_am_taken_to_add_ect_name_page
    expect(page).to have_selector("h1", text: "What’s this ECT’s full name?")
  end

  def then_i_am_taken_to_add_mentor_name_page
    expect(page).to have_selector("h1", text: "What’s the full name of this mentor?")
  end

  def then_i_am_taken_to_add_mentor_full_name_page
    expect(page).to have_selector("h1", text: "What’s this mentor’s full name?")
  end

  def then_i_am_taken_to_choose_term_page_as_ect
    expect(page).to have_selector("h1", text: "When do you expect #{@participant_data[:full_name]} to start their induction programme?")
  end

  def then_i_am_taken_to_choose_term_page_as_mentor
    expect(page).to have_selector("h1", text: "When do you expect #{@participant_data[:full_name]} to begin mentoring ECTs?")
  end

  def then_i_am_taken_to_choose_mentor_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s mentor be?")
  end

  def then_i_am_taken_to_add_ect_or_mentor_nino_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s National Insurance number?")
  end

  def then_i_am_taken_to_add_ect_or_mentor_email_page(full_name: @participant_data[:full_name])
    expect(page).to have_selector("h1", text: "What’s #{full_name}’s email address?")
  end

  def then_i_am_taken_to_add_sits_email_page
    expect(page).to have_selector("h1", text: "What’s #{@induction_coordinator_profile.user.full_name}’s email address?")
  end

  def then_i_am_taken_to_change_mentor_name_page
    expect(page).to have_selector("h1", text: "What should we edit #{@participant_profile_mentor.full_name}’s name to?")
  end

  def then_i_am_taken_to_change_how_you_run_programme_page
    expect(page).to have_selector("h1", text: "Change how you run your training programme")
    expect(page).to have_text("Check the other options available for your school if this changes")
  end

  def then_i_am_taken_to_setup_my_programme
    expect(page).to have_content(@school.name)
    expect(page).to have_content("Tell us if any new ECTs or mentors will start training at your school in the")
  end

  def then_i_am_taken_to_check_details_page
    expect(page).to have_selector("h1", text: "Check your answers")
  end

  def then_i_am_taken_to_still_cannot_find_their_details_page
    expect(page).to have_selector("h1", text: "We still cannot find #{@participant_data[:full_name]}’s record")
  end

  def then_i_am_taken_to_ect_confirmation_page
    expect(page).to have_selector("h1", text: "#{@participant_data[:full_name]} has been added as an ECT")
    expect(page).to have_text("What happens next")
  end

  def then_i_am_taken_to_email_already_taken_page
    expect(page).to have_text("This email has already been added")
  end

  def then_i_am_taken_to_mentor_confirmation_page
    expect(page).to have_selector("h1", text: "#{@participant_data[:full_name]} has been added as a mentor")
    expect(page).to have_text("What happens next")
  end

  def then_i_am_taken_to_yourself_as_mentor_confirmation_page
    expect(page).to have_selector("h1", text: "You’ve been added as a mentor")
  end

  def then_i_am_taken_to_add_ect_or_mentor_updated_email_page
    expect(page).to have_selector("h1", text: "What’s #{@updated_participant_data[:full_name]}’s email address?")
  end

  def then_i_am_taken_to_fip_programme_choice_info_page
    expect(page).to have_text("You’ve chosen to: use a training provider, funded by the DfE")
  end

  def then_i_am_taken_to_cip_programme_choice_info_page
    expect(page).to have_text("Your school has chosen to deliver your own programme using DfE-accredited materials")
  end

  def then_i_am_taken_to_the_support_form_for_changing_an_induction_programme
    expect(page).to have_text("Complete this form to tell us that you want to use a different training programme option for ECTs and mentors who started their training in the 2022 to 2023 academic year.")
  end

  def then_i_am_taken_to_sign_up_to_training_provider_page
    expect(page).to have_selector("h1", text: "Signing up with a training provider")
    expect(page).to have_text("How you can sign up with a training provider")
  end

  def then_i_am_taken_to_course_choice_page
    expect(page).to have_text("Do you know which accredited materials you want to use?")
  end

  def then_i_am_taken_to_training_materials_confirmed_page
    expect(page).to have_text("Training materials confirmed")
  end

  def then_i_am_taken_to_participant_profile
    expect(page).to have_text("Name")
  end

  def then_i_am_taken_to_do_you_know_your_teachers_trn_page
    expect(page).to have_selector("h1", text: "Do you know #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_am_taken_to_updated_do_you_know_your_teachers_trn_page
    expect(page).to have_selector("h1", text: "Do you know #{@updated_participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_am_taken_to_add_teachers_trn_page(full_name: @participant_data[:full_name])
    expect(page).to have_selector("h1", text: "What’s #{full_name}’s teacher reference number (TRN)?")
    expect(page).to have_text("This unique ID:")
  end

  def then_i_am_taken_to_add_sits_trn_page
    expect(page).to have_selector("h1", text: "What’s #{@induction_coordinator_profile.user.full_name}’s teacher reference number (TRN)?")
    expect(page).to have_text("This unique ID:")
  end

  def then_i_am_taken_to_add_your_trn_page
    expect(page).to have_selector("h1", text: "What’s your teacher reference number (TRN)?")
    expect(page).to have_text("This unique ID:")
  end

  def then_i_am_taken_to_add_your_dob_page
    expect(page).to have_selector("h1", text: "What’s your date of birth?")
  end

  def then_i_am_taken_to_add_date_of_birth_page(full_name: @participant_data[:full_name])
    expect(page).to have_selector("h1", text: "What’s #{full_name}’s date of birth?")
  end

  def then_i_am_taken_to_choose_start_date_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s induction start date?")
  end

  def then_i_am_taken_to_updated_choose_start_date_page
    expect(page).to have_selector("h1", text: "What’s #{@updated_participant_data[:full_name]}’s induction start date?")
  end

  def then_i_am_taken_to_the_cannot_find_their_details
    expect(page).to have_selector("h1", text: "We cannot find #{@participant_data[:full_name]}’s record")
    expect(page).to have_text("Check the information you entered is correct.")
  end

  def then_i_can_view_the_design_our_own_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
  end

  def then_i_can_view_the_no_ect_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Your school has told us you do not expect any ECTs")
  end

  def then_i_can_view_assign_mentor_later_status
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text("Add later")
  end

  def then_i_can_view_the_add_your_ect_and_mentor_link
    expect(page).to have_text("Add your early career teacher and mentor details")
  end

  def then_i_can_view_the_view_your_ect_and_mentor_link
    expect(page).to have_text("View your early career teacher and mentor details")
  end

  def then_i_can_view_mentor_name
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text(@participant_profile_mentor.full_name.to_s)
  end

  def then_i_can_view_updated_name
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text((@updated_participant_data[:full_name]).to_s)
  end

  def then_i_can_view_updated_email
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text((@updated_participant_data[:email]).to_s)
  end

  def then_i_can_view_the_added_materials
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Materials")
    expect(page).to have_text(@cip.name)
  end

  def then_i_can_view_the_updated_participant_email
    expect(page).to have_content @updated_participant_data[:email]
  end

  def then_i_am_taken_to_view_mentor_details_page
    expect(page).to have_title("Mentor details - Manage training for early career teachers")
  end

  def then_i_am_taken_to_view_ect_details_page
    expect(page).to have_title("ECT details - Manage training for early career teachers")
  end

  def then_i_can_view_participant_with_status(status_key)
    label = I18n.t(:label, scope: "status_tags.school_participant_status.#{status_key}")
    description = I18n.t(:description, scope: "status_tags.school_participant_status.#{status_key}")

    expect(page).to have_text(label)
    expect(page).to have_text(Array.wrap(description).first)
  end

  def then_i_am_taken_to_cip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Programme materials")
  end

  def then_the_action_required_is_assign_mentor
    expect(page).to have_text("Assign mentor")
  end

  def then_i_can_view_the_fip_induction_dashboard_without_partnership_details(displayed_value: "Your lead provider needs to confirm this with us")
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_summary_row("Delivery partner", displayed_value)
  end

  alias_method :given_i_can_view_the_fip_induction_dashboard_without_partnership_details,
               :then_i_can_view_the_fip_induction_dashboard_without_partnership_details

  def then_i_can_view_transferring_in_participants
    expect(page).to have_text("Transferring to your school")
    expect(page).to have_text("You’ve told us these people are joining you from another school.")
  end

  def then_i_can_view_transferring_out_participants
    expect(page).to have_text("Transferring from your school")
    expect(page).to have_text("You’ve told us these people are moving to a new school.")
  end

  def then_i_am_taken_to_fip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_summary_row("Programme", "Use a training provider funded by the DfE")
    expect(page).to have_summary_row_action("Programme", "Change induction programme choice")
    expect(page).to have_text("Lead provider")
    expect(page).to have_text(@school_cohort.lead_provider.name)
    expect(page).to have_text("Delivery partner")
    expect(page).to have_text(@school_cohort.delivery_partner.name)
  end

  def then_it_should_show_the_withdrawn_participant
    expect(page).to have_text("No longer being trained")
    expect(page).to have_text("Sally Teacher")
    expect(page).to have_text("Big Provider Ltd")
    expect(page).to have_text("Amazing Delivery Team")
  end

  def then_i_am_taken_to_are_they_a_transfer_page
    expect(page).to have_selector("h1", text: "Confirm #{@participant_profile_ect.full_name} is moving from another school")
    expect(page).to have_link("They’re not moving school")
  end

  def then_i_am_taken_to_teacher_start_date_page
    expect(page).to have_selector("h1", text: "When is Sally Teacher moving to your school?")
  end

  def then_i_am_taken_to_choose_mentor_partnership_page(full_name: @participant_data[:full_name])
    expect(page).to have_selector("h1", text: "Who will #{full_name} do their mentor training with?")
  end

  def then_i_am_taken_to_the_cannot_add_page_same_school
    expect(page).to have_selector("h1", text: "You cannot add Sally Teacher")
    expect(page).to have_text("Our records show this person is already registered on an ECF-based training programme at your school")
  end

  def then_i_am_taken_to_the_cannot_add_page_different_school
    expect(page).to have_selector("h1", text: "You cannot add Sally Teacher")
    expect(page).to have_text("Our records show this person is already registered on an ECF-based training programme at a different school")
  end

  def then_i_am_taken_to_choose_mentor_in_transfer_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s mentor be?")
  end

  def then_i_should_be_taken_to_the_teachers_current_programme_page
    expect(page).to have_selector("h2", text: "Will they continue with these training providers?")
  end

  alias_method :then_i_am_taken_to_the_teachers_current_programme_page, :then_i_should_be_taken_to_the_teachers_current_programme_page

  def then_i_should_be_on_the_complete_page
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("#{@participant_profile_ect.full_name} has been added")
  end

  def then_i_see_the_tab_for_the_cohort(cohort)
    expect(page).to have_css(".govuk-tabs__tab", text: "#{cohort} to #{cohort + 1}")
  end

  def then_i_should_be_asked_to_validate
    expect(page).to have_selector("h1", text: "Have you been given a teacher reference number (TRN)?")
  end

  def then_i_see_the_cohort_tabs
    then_i_see_the_tab_for_the_cohort(Cohort.previous.start_year)
    then_i_see_the_tab_for_the_cohort(Cohort.current.start_year)
  end

  def then_i_am_on_the_what_we_need_to_know_page(previous_year: Cohort.previous.start_year, current_year: Cohort.current.start_year)
    expect(page).to have_text("Tell us if any new ECTs or mentors will start training at your school in the #{previous_year} to #{current_year} academic year")
  end

  def then_i_am_taken_to_the_what_we_need_to_know_about_this_mentor_page
    expect(page).to have_content("What we need to know about this mentor")
  end

  def then_i_am_taken_to_the_what_we_need_to_know_about_this_ect_page
    expect(page).to have_content("What we need to know about this ECT")
  end

  def then_i_am_taken_to_the_appropriate_body_type_page
    expect(page).to have_content("Which type of appropriate body have you appointed?")
  end

  def then_i_see_appropriate_body(appropriate_body)
    expect(page).to have_summary_row("Appropriate body", appropriate_body.name)
  end

  def then_i_am_taken_to_you_cant_add_yourself_as_ect_page
    expect(page).to have_content("You cannot add yourself as an ECT")
  end

  def and_i_see_the_cip_programme
    expect(page).to have_summary_row("Programme", "DfE accredited materials")
  end

  def and_i_dont_see_the_lead_provider
    expect(page).to_not have_content("Lead provider")
  end

  def and_i_dont_see_the_delivery_partner
    expect(page).to_not have_content("Delivery partner")
  end

  # Set_steps

  def set_participant_data
    @participant_data = {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "AB123456A",
      start_date: Date.new(Cohort.current.start_year, 9, 1),
    }
  end

  def set_sit_data
    @sit_data = {
      full_name: "Carl Coordinator",
      trn: "7654321",
      date_of_birth: Date.new(1981, 1, 22),
    }
  end

  def set_sit_dqt_validation_result
    allow(DQTRecordCheck).to receive(:call).and_return(
      DQTRecordCheck::CheckResult.new(
        valid_dqt_response(@sit_data),
        true,
        true,
        true,
        false,
        3,
      ),
    )
  end

  def valid_dqt_response(participant_data)
    DQTRecordPresenter.new({
      "name" => participant_data[:full_name],
                             "trn" => participant_data[:trn],
                             "state_name" => "Active",
                             "dob" => participant_data[:date_of_birth],
                             "qualified_teacher_status" => { "qts_date" => 1.year.ago },
                             "induction" => {
                               "periods" => [{ "startDate" => @participant_data[:start_date] }],
                               "status" => "Active",
                             },
    })
  end

  def set_updated_participant_data
    @updated_participant_data = {
      full_name: "Jane Teacher",
      email: "jane@school.com",
    }
  end

  def set_dqt_blank_validation_result
    allow(DQTRecordCheck).to receive(:call).and_return(
      DQTRecordCheck::CheckResult.new(
        nil,
        true,
        true,
        false,
        false,
        2,
      ),
    )
  end

  def set_dqt_validation_result
    allow(DQTRecordCheck).to receive(:call).and_return(
      DQTRecordCheck::CheckResult.new(
        valid_dqt_response(@participant_data),
        true,
        true,
        true,
        false,
        3,
      ),
    )
  end

  def set_dqt_validation_with_nino
    allow(DQTRecordCheck).to receive(:call) do |args|
      if args[:nino] == @participant_data[:nino]
        DQTRecordCheck::CheckResult.new(
          valid_dqt_response(@participant_data),
          true,
          true,
          true,
          true,
          4,
        )
      else
        DQTRecordCheck::CheckResult.new(
          nil,
          true,
          true,
          false,
          false,
          2,
        )
      end
    end
  end
end
