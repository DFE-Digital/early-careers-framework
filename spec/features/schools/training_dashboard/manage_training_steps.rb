# frozen_string_literal: true

module ManageTrainingSteps
  include Capybara::DSL

  # Given_steps

  def given_there_is_a_school_that_has_chosen_fip_for_2021
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "Fip School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme = create(:induction_programme, :fip, school_cohort: @school_cohort)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    given_there_is_a_school_that_has_chosen_fip_for_2021
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    create(:partnership, school: @school, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort, challenge_deadline: 2.weeks.ago)
  end

  def given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered_but_challenged
    given_there_is_a_school_that_has_chosen_fip_for_2021
    @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
    @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
    create(:partnership, school: @school, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort, challenge_deadline: 1.week.from_now, challenged_at: 1.day.ago, challenge_reason: "mistake")
  end

  def given_there_is_a_school_that_has_chosen_cip_for_2021
    @cip = create(:core_induction_programme, name: "CIP Programme 1")
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "CIP School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "core_induction_programme")
    @induction_programme = create(:induction_programme, :cip, school_cohort: @school_cohort)
    @school_cohort.update!(default_induction_programme: @induction_programme)
  end

  def given_there_is_a_school_that_has_chosen(induction_programme_choice:)
    @school_cohort = create :school_cohort, induction_programme_choice: induction_programme_choice, school: create(:school, name: "Test School")
  end

  def given_there_are_multiple_schools_and_an_induction_coordinator
    cohort = create :cohort, :current

    first_school = create :school, name: "Test School 1", slug: "111111-test-school-1", urn: "111111"
    create :school_cohort, :cip, school: first_school, cohort: cohort

    second_school = create :school, name: "Test School 2", slug: "111112-test-school-2", urn: "111112"
    create :school_cohort, :cip, school: second_school, cohort: cohort

    user = create :user, full_name: "School Leader", email: "school-leader@example.com"
    create :induction_coordinator_profile, user: user, schools: [first_school, second_school]

    third_school = FactoryBot.create(:school, name: "Test School 3", slug: "111113-test-school-3", urn: "111113")
    create :school_cohort, :cip, school: third_school, cohort: cohort
  end

  def given_there_is_a_school_that_has_chosen_design_our_own_for_2021
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "Design Our Own Programme School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "design_our_own")
  end

  def given_there_is_a_school_that_has_chosen_no_ect_for_2021
    @cohort = create(:cohort, start_year: 2021)
    @school = create(:school, name: "No ECT Programme School")
    @school_cohort = create(:school_cohort, school: @school, cohort: @cohort, induction_programme_choice: "no_early_career_teachers")
  end

  def given_i_am_on_the_cip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Programme materials")
  end

  def given_i_can_view_the_fip_induction_dashboard_without_partnership_details
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Delivery partner")
  end

  def given_i_am_taken_to_fip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Training provider")
    expect(page).to have_text(@school_cohort.lead_provider.name)
    expect(page).to have_text("Delivery partner")
    expect(page).to have_text(@school_cohort.delivery_partner.name)
  end

  def given_an_ect_has_been_withdrawn_by_the_provider
    @participant_profile_ect.training_status_withdrawn!
    @participant_profile_ect.induction_records.latest.training_status_withdrawn!
  end

  alias_method :and_an_ect_has_been_withdrawn_by_the_provider, :given_an_ect_has_been_withdrawn_by_the_provider

  # And_steps

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort.school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
    set_participant_data
    set_updated_participant_data
  end

  def and_i_have_added_an_ect
    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user: user)
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile: teacher_profile, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_mentor
    user = create(:user, full_name: "Billy Mentor", email: "billy-mentor@example.com")
    teacher_profile = create(:teacher_profile, user: user)
    @participant_profile_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile: teacher_profile, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_eligible_ect_with_mentor
    user = create(:user, full_name: "Eligible With-mentor")
    teacher_profile = create(:teacher_profile, user: user)
    @eligible_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile: teacher_profile, mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @eligible_ect_with_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_eligible_ect_without_mentor
    user = create(:user, full_name: "Eligible Without-mentor")
    teacher_profile = create(:teacher_profile, user: user)
    @eligible_ect_without_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile: teacher_profile, school_cohort: @school_cohort)
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
    @eligible_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Eligible mentor"), school_cohort: @school_cohort, start_term: "summer_2022")
    Induction::Enrol.call(participant_profile: @eligible_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ineligible_ect_with_mentor
    @ineligible_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible With-mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort)
    @ineligible_ect_with_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_ect_with_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ineligible_mentor
    @ineligible_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "Ineligible mentor"), school_cohort: @school_cohort)
    @ineligible_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "active_flags")
    Induction::Enrol.call(participant_profile: @ineligible_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_a_contacted_for_info_ect_with_mentor
    @contacted_for_info_ect_with_mentor = create(:ect_participant_profile, :email_sent, request_for_details_sent_at: 5.days.ago, user: create(:user, full_name: "CFI With-mentor"), mentor_profile_id: @participant_profile_mentor.id, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @contacted_for_info_ect_with_mentor, induction_programme: @induction_programme)
  end

  def and_i_have_added_an_ero_mentor
    @ero_mentor = create(:mentor_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "ero mentor"), school_cohort: @school_cohort)
    @ero_mentor.ecf_participant_eligibility.update!(status: "ineligible", reason: "previous_participation")
    Induction::Enrol.call(participant_profile: @ero_mentor, induction_programme: @induction_programme)
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
    teacher_profile = create(:teacher_profile, user: user)
    @transferring_in_participant = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, teacher_profile: teacher_profile, school_cohort: @school_cohort)
    @induction_record = Induction::Enrol.call(participant_profile: @transferring_in_participant,
                                              induction_programme: @induction_programme,
                                              start_date: 2.months.from_now)
  end

  def and_a_participant_is_already_on_ecf
    @school_two = create(:school, name: "Fip School 2")
    @school_cohort_two = create(:school_cohort, school: @school_two, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @induction_programme_two = create(:induction_programme, :fip, school_cohort: @school_cohort_two)

    user = create(:user, full_name: "Sally Teacher", email: "sally-teacher@example.com")
    teacher_profile = create(:teacher_profile, user: user)
    @participant_profile_ect = create(:ect_participant_profile, teacher_profile: teacher_profile, school_cohort: @school_cohort)
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme_two)
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1234567", date_of_birth: Date.new(1998, 3, 22))
  end

  def and_i_have_a_transferring_out_participant
    and_i_have_added_an_eligible_ect
    @induction_record.leaving!(2.months.from_now)
  end

  def and_i_have_a_transferred_out_participant
    and_i_have_added_an_eligible_ect
    @induction_record.leaving!(1.day.ago)
  end

  def then_i_am_taken_to_add_mentor_page
    expect(page).to have_selector("h1", text: "Who will mentor")
    expect(page).to have_text("You can tell us later if you’re not sure")
  end

  def when_i_select_a_mentor
    choose(@participant_profile_mentor.user.full_name.to_s, allow_label_click: true)
  end

  def then_i_am_on_schools_page
    visit "/schools"
  end

  def then_i_should_see_the_add_your_ect_and_mentor_link
    expect(page).to have_text("Add your early career teacher and mentor details")
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
  end

  def and_i_am_signed_in_as_an_induction_coordinator_for_multiple_schools
    induction_coordinator = User.find_by(email: "school-leader@example.com")
    sign_in_as induction_coordinator
  end

  def and_see_the_other_programs_before_choosing(labels:, choice:, snapshot:)
    expect(page).to have_text "Change how you run your programme"
    expect(page).to be_accessible
    click_on "Check the other options available"

    expect(page).to have_text "How do you want to run your training"
    labels.each { |label| expect(page).to have_selector(:label, text: label) }
    expect(page).to be_accessible
    page.percy_snapshot(snapshot)

    choose choice
    click_on "Continue"

    expect(page).to have_text "Confirm your training programme"
    click_on "Confirm"
  end

  def and_i_have_added_a_details_being_checked_ect_with_mentor
    @details_being_checked_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "DBC With-Mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort, start_term: "Spring 2022")
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
  end

  def and_i_have_added_a_no_qts_ect_with_mentor
    @no_qts_ect_with_mentor = create(:ect_participant_profile, :ecf_participant_eligibility, :ecf_participant_validation_data, user: create(:user, full_name: "No-qts With-Mentor"), mentor_profile_id: @contacted_for_info_mentor.id, school_cohort: @school_cohort, start_term: "Spring 2022")
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
  end

  def and_it_should_not_allow_a_sit_to_edit_the_participant_details
    expect(page).not_to have_link("//a[text()='Change']")
  end

  def and_i_click_on_view_your_early_career_teacher_and_mentor_details
    click_on("View your early career teacher and mentor details")
  end

  def and_the_start_induction_date_is(term_and_year)
    expect(page).to have_text(term_and_year)
  end

  def and_they_have_an_end_date
    expect(page).to have_text(@induction_record.end_date.to_date.to_s(:govuk))
  end

  def and_the_action_required_is_remove
    expect(page).to have_text("Remove")
  end

  def and_cohort_2022_is_created
    create(:cohort, start_year: 2022)
  end

  def and_the_cohort_2022_tab_is_selected
    expect(page).to have_text("Tell us if any new ECTs will start training at your school in the 2022 to 2023 academic year")
  end

  # When_steps

  def when_i_click_on_back
    click_on("Back")
  end

  def when_i_click_on_confirm
    click_on("Confirm")
  end

  def when_i_submit_an_empty_form
    when_i_click_on_continue
  end

  def when_i_click_on_continue
    click_on("Continue")
  end

  def when_i_click_on_change
    click_on("Change")
  end

  def when_i_click_on_change_programme
    click_on("Change induction programme choice", visible: false)
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

  def when_i_click_to_add_a_new_ect_or_mentor
    click_on "Add an ECT or mentor"
  end

  def when_i_click_on_add_myself_as_mentor
    click_on("Add yourself as a mentor")
  end

  def when_i_select_to_add_a(participant_type)
    choose(participant_type, allow_label_click: true)
  end

  def when_i_click_on_add_your_early_career_teacher_and_mentor_details
    click_on("Add your early career teacher and mentor details")
  end

  def when_i_click_on_check_what_each_role_needs_to_do
    click_on("Check what each role needs to do")
  end

  def when_i_click_on_sign_up
    click_on("Sign up")
  end

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
    click_on("Change term", visible: false)
  end

  def when_i_click_on_change_trn
    click_on("Change TRN", visible: false)
  end

  def when_i_choose_a_mentor
    choose(@participant_profile_mentor.user.full_name.to_s, allow_label_click: true)
  end

  def when_i_add_ect_or_mentor_name
    fill_in "Full_name", with: @participant_data[:full_name]
  end

  def when_i_add_ect_or_mentor_email
    fill_in "Email", with: @participant_data[:email]
  end

  def when_i_add_ect_or_mentor_email_that_already_exists
    fill_in "Email", with: @participant_profile_ect.user.email
  end

  def when_i_choose_start_term
    choose(@participant_data[:start_term].humanize, allow_label_click: true)
  end

  def when_i_choose_assign_mentor_later
    choose("Assign mentor later", allow_label_click: true)
  end

  def when_i_add_ect_or_mentor_updated_name
    fill_in "Full_name", with: @updated_participant_data[:full_name]
  end

  def when_i_add_ect_or_mentor_updated_email
    fill_in "Email", with: @updated_participant_data[:email]
  end

  def when_i_add_ect_or_mentor_updated_term
    choose(@updated_participant_data[:start_term].humanize, allow_label_click: true)
  end

  def when_i_add_the_trn
    fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?", with: @participant_data[:trn]
  end

  def when_i_add_a_date_of_birth
    date = @participant_data[:date_of_birth]
    fill_in "Day", with: date.day
    fill_in "Month", with: date.month
    fill_in "Year", with: date.year
  end

  def when_i_add_a_start_date
    date = @participant_data[:start_date]
    fill_in "Day", with: date.day
    fill_in "Month", with: date.month
    fill_in "Year", with: date.year
  end

  def when_i_choose_materials
    choose("CIP Programme 1", allow_label_click: true)
  end

  def when_i_visit_manage_training_dashboard
    visit schools_dashboard_path(@school)
  end

  def when_i_click_on_the_participants_name(name)
    click_on name
  end

  def when_i_navigate_to_participants_dashboard
    when_i_click_on_add_your_early_career_teacher_and_mentor_details
    then_i_am_taken_to_roles_page
    when_i_click_on_continue
    then_i_am_taken_to_your_ect_and_mentors_page
  end

  def when_i_change_ect_name
    fill_in "Change ECT’s name", with: @updated_participant_data[:full_name]
  end

  def when_i_change_ect_name_to_blank
    fill_in "Change ECT’s name", with: ""
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

  # Then_steps

  def then_i_am_taken_to_roles_page
    expect(page).to have_selector("h1", text: "Check what each person needs to do in the early career teacher training programme")
    expect(page).to have_text("An induction tutor should only assign themself as a mentor in exceptional circumstances")
  end

  def then_i_am_taken_to_your_ect_and_mentors_page
    expect(page).to have_selector("h1", text: "Your ECTs and mentors")
    if FeatureFlag.active?(:change_of_circumstances)
      expect(page).to have_link("Add an ECT or mentor")
    else
      expect(page).to have_link("Add a new ECT")
      expect(page).to have_link("Add a new mentor")
    end
    expect(page).to have_link("Add yourself as a mentor")
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

  def then_i_am_taken_to_add_ect_name_page
    expect(page).to have_selector("h1", text: "What’s the full name of this ECT?")
  end

  def then_i_am_taken_to_add_mentor_name_page
    expect(page).to have_selector("h1", text: "What’s the full name of this mentor?")
  end

  def then_i_am_taken_to_choose_term_page_as_ect
    expect(page).to have_selector("h1", text: "When do you expect #{@participant_data[:full_name]} to start their induction programme?")
  end

  def then_i_am_taken_to_choose_term_page_as_mentor
    expect(page).to have_selector("h1", text: "When do you expect #{@participant_data[:full_name]} to begin mentoring ECTs?")
  end

  def then_i_am_taken_to_choose_mentor_page
    expect(page).to have_selector("h1", text: "Who will mentor #{@participant_data[:full_name]}")
  end

  def then_i_am_taken_to_add_ect_or_mentor_email_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s email address?")
  end

  def then_i_am_taken_to_change_ect_name_page
    expect(page).to have_selector("h1", text: "Change ECT’s name")
  end

  def then_i_am_taken_to_change_ect_email_page
    expect(page).to have_selector("h1", text: "Change ECT’s email")
  end

  def then_i_am_taken_to_change_how_you_run_programme_page
    expect(page).to have_selector("h1", text: "Change how you run your programme")
    expect(page).to have_text("Check the other options available for your school if this changes")
  end

  def then_i_am_taken_to_check_details_page
    expect(page).to have_selector("h1", text: "Check your answers")
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
    expect(page).to have_text("You’ve chosen to: deliver your own programme using DfE-accredited materials")
  end

  def then_i_am_taken_to_sign_up_to_training_provider_page
    expect(page).to have_selector("h1", text: "Signing up with a training provider")
    expect(page).to have_text("How you can sign up with a training provider")
  end

  def then_i_am_taken_to_course_choice_page
    expect(page).to have_text("Which training materials do you want to use?")
  end

  def then_i_am_taken_to_participant_profile
    expect(page).to have_selector("h2", text: "Participant details")
  end

  def then_i_am_taken_to_do_you_know_your_teachers_trn_page
    expect(page).to have_selector("h1", text: "Do you know #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_am_taken_to_updated_do_you_know_your_teachers_trn_page
    expect(page).to have_selector("h1", text: "Do you know #{@updated_participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_am_taken_to_add_teachers_trn_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
    expect(page).to have_text("This unique ID:")
  end

  def then_i_am_taken_to_add_date_of_birth_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth?")
  end

  def then_i_am_taken_to_choose_start_date_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s induction start date?")
  end

  def then_i_am_taken_to_updated_choose_start_date_page
    expect(page).to have_selector("h1", text: "What’s #{@updated_participant_data[:full_name]}’s induction start date?")
  end

  def then_i_am_taken_to_the_cannot_find_their_details
    expect(page).to have_selector("h1", text: "We cannot find #{@participant_data[:full_name]}’s record")
    expect(page).to have_text("Check the information you’ve entered is correct.")
  end

  def then_i_can_view_the_design_our_own_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Design and deliver your own programme")
  end

  def then_i_can_view_the_no_ect_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("No early career teachers for this cohort")
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
    expect(page).to have_text(@participant_profile_mentor.user.full_name.to_s)
  end

  def then_i_can_view_updated_name
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text((@updated_participant_data[:full_name]).to_s)
  end

  def then_i_can_view_updated_email
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text((@updated_participant_data[:email]).to_s)
  end

  def then_i_can_view_updated_term
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_text(@updated_participant_data[:start_term].humanize)
  end

  def then_i_can_view_the_added_materials
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Materials")
    expect(page).to have_text(@cip.name)
  end

  def then_i_can_view_the_updated_participant_name
    expect(page).to have_content @updated_participant_data[:full_name]
  end

  def then_i_can_view_the_updated_participant_email
    expect(page).to have_content @updated_participant_data[:email]
  end

  def then_i_am_taken_to_view_details_page
    expect(page).to have_text("Participant details")
  end

  def then_i_can_view_ineligible_participant_status
    expect(page).to have_text("This person is not eligible for this programme.")
  end

  def then_i_can_view_eligible_fip_partnered_ect_status
    expect(page).to have_text("We’ve confirmed this person is eligible for this programme. Your training provider will contact them directly.")
  end

  def then_i_can_view_eligible_fip_unpartnered_status
    expect(page).to have_text("We’ve confirmed this person is eligible for this programme. Once you choose a training provider, they’ll contact this person directly.")
  end

  def then_i_can_view_contacted_for_info_status
    expect(page).to have_text("We’ve asked this person to use our service to provide some information. We need this to check their eligibility with the Teaching Regulation Agency.")
  end

  def then_i_can_view_contacted_for_info_bounced_email_status
    expect(page).to have_text("We could not send an email to this address. Please check it’s correct.")
  end

  def then_i_can_view_details_being_checked_status
    expect(page).to have_text("We’re checking this person’s details with the Teaching Regulation Agency.")
  end

  def then_i_can_view_no_qts_status
    expect(page).to have_text("Our checks show this person does not have qualified teacher status (QTS). Their status should be up to date if they completed their ITT in 2021.")
  end

  def then_i_can_view_details_being_checked_mentor_status
    expect(page).to have_text("We’re checking this person’s details with the Teaching Regulation Agency. We’ll confirm if they’re eligible for this programme soon.")
  end

  def then_i_can_view_eligible_cip_status
    expect(page).to have_text("We’ve confirmed this person is eligible for this programme. They have access to their materials.")
  end

  def then_i_can_see_ero_status
    expect(page).to have_text("This person is ready to mentor ECTs this year. Our checks show they’re already receiving funded mentor training as part of the early roll-out of the early career framework (ECF) reforms.")
  end

  def then_i_am_taken_to_cip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Programme materials")
  end

  def then_i_can_view_ineligible_participants
    expect(page).to have_text("Not eligible for funded training")
    expect(page).to have_text("We’ve checked these people’s details and found they’re not eligible for this programme.")
  end

  def then_the_action_required_is_none
    expect(page).to have_text("None")
  end

  def then_the_action_required_is_assign_mentor
    expect(page).to have_text("Assign mentor")
  end

  def then_the_action_required_is_check_email_address
    expect(page).to have_text("Check email address")
  end

  def then_the_action_required_is_remind_them
    expect(page).to have_text("Remind them")
  end

  def then_i_can_view_fip_unpartnered_eligible_participants
    expect(page).to have_text("Eligible to start")
    expect(page).to have_text("We’ve confirmed these people are eligible for this programme. Once you choose a training provider, they’ll contact your ECTs and mentors directly.")
  end

  def then_i_can_view_details_being_checked_participants
    expect(page).to have_text("DfE checking eligibility")
    expect(page).to have_text("We’re checking these people’s details with the Teaching Regulation Agency. We’ll confirm if they’re eligible for this programme soon.")
  end

  def then_i_can_view_no_qts_ects
    expect(page).to have_text("Checking QTS")
    expect(page).to have_text("These ECTs do not have qualified teacher status (QTS) yet.")
  end

  def then_i_can_view_no_qts_mentors
    expect(page).to have_text("Checking QTS")
    expect(page).to have_text("These mentors do not have qualified teacher status (QTS) yet.")
  end

  def then_i_can_view_eligible_participants
    expect(page).to have_text("Eligible to start")
    expect(page).to have_text("We’ve confirmed these people are eligible for this programme. Your training provider will contact them directly.")
  end

  def then_i_can_view_cip_eligible_participants
    expect(page).to have_text("Eligible to start")
    expect(page).to have_text("We’ve confirmed these people are eligible for this programme. They have access to their materials.")
  end

  def then_i_can_view_contacted_for_info_participants
    expect(page).to have_text("Contacted for information")
    expect(page).to have_text("We need this to check their eligibility with the Teaching Regulation Agency.")
  end

  def then_i_can_view_the_fip_induction_dashboard_without_partnership_details
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).not_to have_text("Delivery partner")
  end

  def then_i_can_view_transferring_in_participants
    expect(page).to have_text("Transferring to your school")
    expect(page).to have_text("You’ve told us these people are joining you from another school.")
  end

  def then_i_can_view_transferring_out_participants
    expect(page).to have_text("Transferring from your school")
    expect(page).to have_text("You’ve told us these people are moving to a new school.")
  end

  def then_i_can_view_transferred_from_your_school_participants
    expect(page).to have_text("Transferred from your school")
    expect(page).to have_text("You told us these people moved to a new school.")
  end

  def then_i_am_taken_to_fip_induction_dashboard
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Training provider")
    expect(page).to have_text(@school_cohort.lead_provider.name)
    expect(page).to have_text("Delivery partner")
    expect(page).to have_text(@school_cohort.delivery_partner.name)
  end

  def then_i_am_taken_to_fip_induction_dashboard_without_provider
    expect(page).to have_selector("h1", text: "Manage your training")
    expect(page).to have_text("Training provider")
  end

  def then_it_should_show_the_withdrawn_participant
    expect(page).to have_text("No longer being trained")
    expect(page).to have_text("Sally Teacher")
    expect(page).to have_text("Big Provider Ltd")
    expect(page).to have_text("Amazing Delivery Team")
  end

  def then_i_am_taken_to_are_they_a_transfer_page
    expect(page).to have_selector("h1", text: "Is #{@participant_profile_ect.user.full_name} transferring from another school?")
    expect(page).to have_text("Yes")
    expect(page).to have_text("No")
  end

  def then_i_am_taken_to_teacher_start_date_page
    expect(page).to have_selector("h1", text: "What’s Sally Teacher’s start date at your school?")
  end

  def then_i_am_taken_to_the_cannot_add_page
    expect(page).to have_selector("h1", text: "You cannot add Sally Teacher")
    expect(page).to have_text("Our records show this person is already registered on an ECF-based training programme at a different school")
  end

  def then_i_am_taken_choose_mentor_in_transfer_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s mentor be?")
  end

  def then_i_should_be_taken_to_the_teachers_current_programme_page
    expect(page).to have_selector("h1", text: "Will #{@participant_data[:full_name]} continue with their current training programme?")
  end

  def then_i_should_be_on_the_complete_page
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We’ll let #{@participant_profile_ect.user.full_name}")
  end

  def then_i_see_the_tab_for_the_cohort(cohort)
    expect(page).to have_css(".govuk-tabs__tab", text: "#{cohort} to #{cohort + 1}")
  end

  def then_i_see_the_cohort_tabs
    then_i_see_the_tab_for_the_cohort(2021)
    then_i_see_the_tab_for_the_cohort(2022)
  end

  def then_i_am_on_the_expect_any_ects_page
    expect(page).to have_text("Does your school expect any new ECTs in the next academic year?")
  end

  # Set_steps

  def set_participant_data
    @participant_data = {
      trn: "1234567",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1998, 3, 22),
      email: "sally@school.com",
      nino: "",
      start_term: "summer_2022",
      start_date: Date.new(2022, 9, 1),
    }
  end

  def set_updated_participant_data
    @updated_participant_data = {
      full_name: "Jane Teacher",
      email: "jane@school.com",
      start_term: "spring_2022",
    }
  end

  def set_dqt_blank_validation_result
    allow_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(nil)
  end

  def set_dqt_validation_result
    response = {
      trn: @participant_data[:trn],
      full_name: @participant_data[:full_name],
      nino: nil,
      dob: @participant_data[:date_of_birth],
      config: {},
    }
    allow_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(response)
  end
end
