# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Transferring participants", with_feature_flags: { change_of_circumstances: "active" }, type: :feature, js: true, rutabaga: false do
  context "At transfer journey entry point" do
    context "Participant is already enrolled at the school" do
      before do
        set_participant_data
        set_dqt_validation_result
        given_a_school_has_chosen_fip_for_2021_and_partnered
        and_they_have_already_added_this_ect
        and_i_am_signed_in_as_an_induction_coordinator
        and_i_have_selected_my_cohort_tab
        when_i_click_to_view_ects_and_mentors
        then_i_am_taken_to_your_ect_and_mentors_page
      end

      scenario "Induction tutor is stopped early in the transfer journey" do
        when_i_click_to_add_an_ect_or_mentor
        then_i_should_be_on_the_who_to_add_page

        when_i_select_transfer_teacher_option
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
        then_i_should_be_on_the_already_enrolled_page
      end
    end

    context "At add ECT/add Mentor entry point" do
      context "Participant is already enrolled at the school" do
        before do
          set_participant_data
          set_dqt_validation_result
          given_a_school_has_chosen_fip_for_2021_and_partnered
          and_they_have_already_added_this_ect
          and_i_am_signed_in_as_an_induction_coordinator
          and_i_have_selected_my_cohort_tab
          when_i_click_to_view_ects_and_mentors
          then_i_am_taken_to_your_ect_and_mentors_page
        end

        scenario "Adding an ECT switches to transfer journey" do
          when_i_click_to_add_an_ect_or_mentor
          then_i_should_be_on_the_who_to_add_page

          when_i_select "A new ECT"
          click_on "Continue"
          then_i_should_be_on_what_we_need_for_adding_participant_page

          click_on "Continue"
          then_i_am_taken_to_add_ect_name_page

          when_i_update_the_name_with(@participant_data[:full_name])
          click_on "Continue"
          then_i_should_be_on_trn_page

          when_i_add_the_trn
          click_on "Continue"
          then_i_should_be_on_the_date_of_birth_page

          when_i_add_a_valid_date_of_birth
          click_on "Continue"
          then_i_am_should_be_on_are_they_a_transfer_page

          when_i_select "Yes"
          click_on "Continue"
          then_i_should_be_on_the_already_enrolled_page
        end
      end
    end
  end

  # given

  def given_a_school_has_chosen_fip_for_2021_and_partnered
    @cohort = Cohort[2021] || create(:cohort, start_year: 2021)
    @school_one = create(:school, name: "Fip School 1")
    create(:school_cohort, school: @school_one, cohort: Cohort[2022] || create(:cohort, start_year: 2022), induction_programme_choice: "full_induction_programme")
    @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
    @mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)
    @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one, partnership: @partnership_one)
    @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
    Induction::Enrol.call(participant_profile: @mentor, induction_programme: @induction_programme_one)
    Mentors::AddToSchool.call(school: @school_one, mentor_profile: @mentor)
  end

  # when

  def when_i_click_to_view_ects_and_mentors
    click_on "Manage participants"
  end

  def when_i_click_to_add_an_ect_or_mentor
    click_on "Add an ECT or mentor"
  end

  def when_i_select_transfer_teacher_option
    choose("A teacher transferring from another school where they’ve started ECF-based training or mentoring", allow_label_click: true)
  end

  def when_i_update_the_name_with(name)
    fill_in "Full_name", with: name
  end

  def when_i_add_a_valid_trn
    fill_in "Teacher reference number (TRN)", with: "1001000"
  end

  def when_i_add_a_valid_date_of_birth
    legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

    fill_in_date(legend, with: "1990-10-24")
  end

  def when_i_select(option)
    choose option, allow_label_click: true
  end

  def when_i_add_the_trn
    fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?", with: @participant_data[:trn]
  end

  # then

  def then_i_am_taken_to_your_ect_and_mentors_page
    expect(page).to have_selector("h1", text: "Your ECTs and mentors")
    expect(page).to have_text("Add an ECT or mentor")
    expect(page).to have_text("Add yourself as a mentor")
  end

  def then_i_should_be_on_check_transfer_page
    expect(page).to have_selector("h1", text: "Check you’re reporting this for the correct academic year")
  end

  def then_i_should_be_on_the_who_to_add_page
    expect(page).to have_selector("h1", text: "Who do you want to add?")
  end

  def then_i_should_be_on_what_we_need_page
    expect(page).to have_selector("h1", text: "What we need from you")
    expect(page).to have_text("To do this, you need to tell us their")
  end

  def then_i_should_be_on_what_we_need_for_adding_participant_page
    expect(page).to have_selector("h1", text: "What we need from you")
  end

  def then_i_am_taken_to_add_ect_name_page
    expect(page).to have_selector("h1", text: "What’s this person’s full name?")
  end

  def then_i_should_be_on_full_name_page
    expect(page).to have_selector("h1", text: "What’s this person’s full name?")
  end

  def then_i_should_be_on_trn_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)")
  end

  def then_i_should_be_on_the_date_of_birth_page
    expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth")
  end

  def then_i_am_taken_to_do_you_know_your_teachers_trn_page
    expect(page).to have_selector("h1", text: "Do you know #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
  end

  def then_i_should_be_on_the_already_enrolled_page
    expect(page).to have_text("Our records show this person is already registered on an ECF-based training programme at your school")
  end

  def then_i_am_should_be_on_are_they_a_transfer_page
    expect(page).to have_selector("h1", text: "Is #{@participant_profile_ect.user.full_name} transferring from another school?")
    expect(page).to have_text("Yes")
    expect(page).to have_text("No")
  end

  # and

  def and_i_am_signed_in_as_an_induction_coordinator
    @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
    privacy_policy = create(:privacy_policy)
    privacy_policy.accept!(@induction_coordinator_profile.user)
    sign_in_as @induction_coordinator_profile.user
  end

  def and_they_have_already_added_this_ect
    @participant_profile_ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_one)
    create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
    Induction::Enrol.call(participant_profile: @participant_profile_ect, induction_programme: @induction_programme_one)
  end

  def and_i_have_selected_my_cohort_tab
    click_on @cohort.description
  end

  # data setup

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

  def set_participant_data
    @participant_data = {
      trn: "1001000",
      full_name: "Sally Teacher",
      date_of_birth: Date.new(1990, 10, 24),
      email: "sally-teacher@example.com",
    }
  end
end
