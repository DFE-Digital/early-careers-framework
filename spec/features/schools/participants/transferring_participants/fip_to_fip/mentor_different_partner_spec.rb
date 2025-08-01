# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Transferring a mentor with a different provider", type: :feature, js: true, early_in_cohort: true do
  include DQTHelper

  before do
    allow_participant_transfer_mailers
    set_participant_data
    set_dqt_validation_result
    given_there_are_two_schools_that_have_chosen_fip_for_previous_cohort_and_partnered
    and_there_is_a_mentor_who_will_be_transferring
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_have_selected_my_cohort_tab
    when_i_click_to_view_mentors
    then_i_am_taken_to_manage_mentors_page
  end

  scenario "Induction tutor can transfer an Mentor to their schools programme" do
    inside_auto_assignment_window do
      when_i_click_to_add_a_new_mentor
      then_i_should_be_on_the_who_to_add_page

      when_i_select_the_mentor_option
      click_on "Continue"
      then_i_should_be_on_what_we_need_page

      click_on "Continue"
      then_i_should_be_on_full_name_page

      when_i_update_the_name_with(@participant_data[:full_name])
      click_on "Continue"
      then_i_should_be_on_trn_page

      when_i_add_a_valid_trn
      click_on "Continue"
      then_i_should_be_on_the_date_of_birth_page

      when_i_add_a_valid_date_of_birth
      click_on "Continue"

      then_i_should_be_on_the_only_mentor_at_your_school_page
      then_the_page_should_be_accessible
      when_i_select "Yes"
      click_on "Confirm"

      then_i_should_be_on_the_teacher_start_date_page
      then_the_page_should_be_accessible

      when_i_add_a_valid_start_date
      click_on "Continue"

      then_i_should_be_on_the_add_email_page

      when_i_update_the_email_with("sally-mentor@example.com")
      click_on "Continue"

      then_i_should_be_taken_to_the_teachers_current_programme_page
      when_i_select "No"
      click_on "Continue"

      then_i_should_be_taken_to_the_schools_current_programme_page
      when_i_select @lead_provider.name
      click_on "Continue"

      then_i_should_be_taken_to_the_check_your_answers_page

      click_on "Confirm and add"
      then_i_should_be_on_the_complete_page
      and_the_schools_current_provider_is_notified
      and_the_participants_current_provider_is_notified

      click_on "View your mentors"
      then_i_am_taken_to_manage_mentors_page
    end
  end

  scenario "Induction tutor can transfer an Mentor and they can continue their current programme" do
    inside_auto_assignment_window do
      when_i_click_to_add_a_new_mentor
      then_i_should_be_on_the_who_to_add_page

      when_i_select_the_mentor_option
      click_on "Continue"
      then_i_should_be_on_what_we_need_page

      click_on "Continue"
      then_i_should_be_on_full_name_page

      when_i_update_the_name_with(@participant_data[:full_name])
      click_on "Continue"
      then_i_should_be_on_trn_page

      when_i_add_a_valid_trn
      click_on "Continue"
      then_i_should_be_on_the_date_of_birth_page

      when_i_add_a_valid_date_of_birth
      click_on "Continue"
      then_i_should_be_on_the_only_mentor_at_your_school_page

      when_i_select "Yes"
      click_on "Confirm"
      then_i_should_be_on_the_teacher_start_date_page

      when_i_add_a_valid_start_date
      click_on "Continue"
      then_i_should_be_on_the_add_email_page

      when_i_update_the_email_with("sally-mentor@example.com")
      click_on "Continue"

      then_i_should_be_taken_to_the_teachers_current_programme_page
      when_i_select "Yes"
      click_on "Continue"
      then_i_should_be_taken_to_the_check_your_answers_page_for_an_existing_induction

      click_on "Confirm and add"
      then_i_should_be_on_the_complete_page_for_an_existing_induction
      and_the_participants_current_provider_is_notified

      click_on "View your mentors"
      then_i_am_taken_to_manage_mentors_page
    end
  end

  # given
  def given_there_are_two_schools_that_have_chosen_fip_for_previous_cohort_and_partnered
    @cohort = Cohort.previous || create(:cohort, :previous)
    @school_one = create(:school, name: "Fip School 1")
    @school_two = create(:school, name: "Fip School 2")
    create(:school_cohort, school: @school_one, cohort: Cohort.current || create(:cohort, :current), induction_programme_choice: "full_induction_programme")
    @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @school_cohort_two = create(:school_cohort, school: @school_two, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @lead_provider = create(:lead_provider, name: "Lead Provider One Ltd")
    @lead_provider_two = create(:lead_provider, name: "Lead Provider Two Ltd")
    @lead_provider_profile = create(:lead_provider_profile, lead_provider: @lead_provider)
    @lead_provider_two_profile = create(:lead_provider_profile, lead_provider: @lead_provider_two)
    @delivery_partner = create(:delivery_partner, name: "Delivery Partner One")
    @other_delivery_partner = create(:delivery_partner, name: "Delivery Partner Two")
    @mentor = create(:mentor_participant_profile, schedule: create(:ecf_schedule, cohort: @cohort), user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)
    @partnership_one = create(:partnership, school: @school_one, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
    @partnership_two = create(:partnership, school: @school_two, lead_provider: @lead_provider_two, delivery_partner: @other_delivery_partner, cohort: @cohort)
    @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one, partnership: @partnership_one)
    @induction_programme_two = create(:induction_programme, :fip, school_cohort: @school_cohort_two, partnership: @partnership_two)
    @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
    @school_cohort_two.update!(default_induction_programme: @induction_programme_two)
    Induction::Enrol.call(participant_profile: @mentor, start_date: Date.new(Cohort.previous.start_year, 9, 1), induction_programme: @induction_programme_one)
    Mentors::AddToSchool.call(school: @school_one, mentor_profile: @mentor)
  end

  # when

  def when_i_click_to_view_ects
    click_on "Early career teachers"
  end

  def when_i_click_to_view_mentors
    click_on "Mentors"
  end

  def when_i_click_to_add_a_new_ect
    click_on "Add ECT"
  end

  def when_i_click_to_add_a_new_mentor
    click_on "Add Mentor"
  end

  def when_i_select_the_mentor_option
    choose("Mentor", allow_label_click: true)
  end

  def when_i_update_the_name_with(name)
    fill_in "What’s this mentor’s full name?", with: name
  end

  def when_i_update_the_email_with(email)
    fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: email
  end

  def when_i_add_a_valid_trn
    fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)", with: "1001000"
  end

  def when_i_add_a_valid_date_of_birth
    legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

    fill_in_date(legend, with: "1990-10-24")
  end

  def when_i_add_a_valid_start_date
    legend = "When is #{@participant_data[:full_name]} moving to your school?"

    fill_in_date(legend, with: "#{Cohort.next.start_year}-10-24")
  end

  def when_i_select(option)
    choose(option)
  end

  # then

  def then_i_am_taken_to_manage_ects_page
    expect(page).to have_selector("h1", text: "Early career teachers (ECTs)")
    expect(page).to have_text("Add ECT")
  end

  def then_i_am_taken_to_manage_mentors_page
    expect(page).to have_selector("h1", text: "Mentors")
    expect(page).to have_text("Add Mentor")
  end

  def then_i_am_taken_to_a_dashboard_page
    expect(page).to have_selector("h1", text: "Manage your training")
  end

  def then_i_should_be_on_what_we_need_page
    expect(page).to have_selector("h1", text: "What we need to know about this mentor")
  end

  def then_i_should_be_on_full_name_page
    expect(page).to have_selector("h1", text: "What’s this mentor’s full name?")
  end

  def then_i_should_be_on_trn_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_should_be_on_the_date_of_birth_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth?")
  end

  def then_i_should_be_on_the_only_mentor_at_your_school_page
    expect(page).to have_selector("h1", text: "Will #{@participant_data[:full_name]} only mentor ECTs at your school?")
  end

  def then_i_should_be_on_the_teacher_start_date_page
    expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} moving to your school?")
  end

  def then_i_should_be_on_the_who_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
  end

  def then_i_should_be_on_the_add_email_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s email address?")
  end

  def then_i_should_be_taken_to_the_teachers_current_programme_page
    expect(page).to have_selector("h2", text: "Will they continue with these training providers?")
    expect(page).to have_text(@lead_provider_two.name)
    expect(page).to have_text(@other_delivery_partner.name)
  end

  def then_i_should_be_taken_to_the_schools_current_programme_page
    expect(page).to have_selector("h1", text: "Who will #{@participant_data[:full_name]}’s new training providers be?")
    expect(page).to have_text(@lead_provider.name)
    expect(page).to have_text(@delivery_partner.name)
  end

  def then_i_should_be_taken_to_the_check_your_answers_page
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_selector("dd", text: @lead_provider.name)
    expect(page).to have_selector("dd", text: @delivery_partner.name)
  end

  def then_i_should_be_taken_to_the_check_your_answers_page_for_an_existing_induction
    expect(page).to have_selector("h1", text: "Check your answers")
    expect(page).to have_selector("dd", text: @lead_provider_two.name)
    expect(page).to have_selector("dd", text: @other_delivery_partner.name)
  end

  def then_i_should_be_on_the_complete_page
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We’ll let this person know you’ve registered them for early career training at your school")
  end

  def then_i_should_be_on_the_complete_page_for_an_existing_induction
    expect(page).to have_selector("h2", text: "What happens next")
    expect(page).to have_text("We’ll let this person know you’ve registered them for early career training at your school.")
    expect(page).to have_text("We’ll contact their training lead provider, #{@lead_provider_two.name}, to let them know that you’ve reported their transfer too.")
  end

  def then_i_should_see_the_transferring_participant
    expect(page).to have_selector("h2", text: "Transferring to your school")
    within(:xpath, "//table[@data-test='transferring_in']/tbody/tr[1]") do
      expect(page).to have_xpath(".//td[1]", text: @participant_data[:full_name])
      expect(page).to have_xpath(".//td[2]", text: @lead_provider.name)
      expect(page).to have_xpath(".//td[3]", text: @delivery_partner.name)
    end
  end

  def then_i_should_see_the_transferring_participant_for_an_existing_induction
    expect(page).to have_selector("h2", text: "Transferring to your school")
    within(:xpath, "//table[@data-test='transferring_in']/tbody/tr[1]") do
      expect(page).to have_xpath(".//td[1]", text: @participant_data[:full_name])
      expect(page).to have_xpath(".//td[2]", text: @lead_provider_two.name)
      expect(page).to have_xpath(".//td[3]", text: @other_delivery_partner.name)
    end
  end

  # and

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def and_there_is_a_mentor_who_will_be_transferring
    @participant_profile_mentor = create(:mentor_participant_profile, schedule: create(:ecf_schedule, cohort: @cohort), user: create(:user, full_name: "Sally Mentor"), school_cohort: @school_cohort_two)
    Induction::Enrol.call(participant_profile: @participant_profile_mentor, start_date: Date.new(Cohort.previous.start_year, 9, 1), induction_programme: @induction_programme_two)

    create(:ecf_participant_validation_data, participant_profile: @participant_profile_mentor, full_name: "Sally Mentor", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
    @participant_profile_mentor.teacher_profile.update!(trn: "1001000")
  end

  def and_the_participants_current_provider_is_notified
    induction_record = @participant_profile_mentor.induction_records.latest
    expect(ParticipantTransferMailer).to have_received(:with)
      .with(
        induction_record:,
        lead_provider_profile: @lead_provider_two_profile,
      )
  end

  def and_the_schools_current_provider_is_notified
    induction_record = @participant_profile_mentor.induction_records.latest
    expect(ParticipantTransferMailer).to have_received(:with)
      .with(
        induction_record:,
        lead_provider_profile: @lead_provider_profile,
      )
  end

  def and_i_have_selected_my_cohort_tab
    click_on @cohort.description
  end

  def allow_participant_transfer_mailers
    allow(ParticipantTransferMailer).to receive(:with).and_call_original
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

  def set_participant_data
    @participant_data = {
      trn: "1001000",
      full_name: "Sally Mentor",
      date_of_birth: Date.new(1990, 10, 24),
      email: "sally-mentor@example.com",
    }
  end
end
