# frozen_string_literal: true

require "rails_helper"

Dir.glob(Rails.root.join("db/new_seeds/scenarios/**/*.rb")).each do |scenario|
  require scenario
end

RSpec.describe "transfer out participants", type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2022, 10, 21) do
  context "Transfer out an ECT" do
    before do
      allow_participant_transfer_mailers
      given_a_school_have_chosen_fip_for_2021
      and_i_am_signed_in_as_an_induction_coordinator
      when_i_click_to_view_ects_and_mentors
      then_i_am_taken_to_manage_mentors_and_ects_page
    end

    scenario "Induction tutor can transfer an ECT out of their school" do
      when_i_click_on_an_ect
      then_i_should_be_on_the_ect_details_page

      when_i_click_to_transfer_out_a_participant
      then_i_should_be_on_the_check_transfer_page

      click_on "Confirm"
      then_i_should_be_on_the_teacher_end_date_page

      click_on "Continue"
      then_i_should_see_enter_end_date_error_message

      when_i_add_an_invalid_date
      click_on "Continue"
      then_i_should_see_invalid_end_date_error_message

      when_i_add_a_valid_end_date
      click_on "Continue"

      then_i_should_be_on_the_check_your_answers_page

      click_on "Confirm and continue"
      then_i_should_be_on_the_complete_page
      and_the_participant_should_be_notified_that_theyre_transferred_out

      click_on "View your ECTs and mentors"
      then_i_am_taken_to_manage_mentors_and_ects_page
      then_i_should_still_see_the_transferring_participant
    end

    # given

    def given_a_school_have_chosen_fip_for_2021
      scenario = NewSeeds::Scenarios::Participants::Mentors::MentoringMultipleEctsWithSameProvider
                   .new
                   .build(number_of_mentees: 1, with_eligibility: false, with_validation_data: false)
      @school = scenario.school
      @ect = scenario.mentees.first
    end

    # when

    def when_i_click_to_view_ects_and_mentors
      click_on "Manage mentors and ECTs"
    end

    def when_i_click_on_an_ect
      click_on @ect.full_name
    end

    def when_i_click_to_transfer_out_a_participant
      click_on "#{@ect.full_name} is transferring to another school"
    end

    def when_i_add_an_invalid_date
      legend = "When is #{@ect.full_name} leaving your school?"

      fill_in_date(legend, with: "23-10-24")
    end

    def when_i_add_a_valid_end_date
      legend = "When is #{@ect.full_name} leaving your school?"

      fill_in_date(legend, with: "2022-10-24")
    end

    def when_i_select(option)
      choose(option)
    end

    # then

    def then_i_am_taken_to_manage_mentors_and_ects_page
      expect(page).to have_selector("h1", text: "Manage mentors and ECTs")
      expect(page).to have_text("Add ECT or mentor")
    end

    def then_i_should_be_on_the_ect_details_page
      expect(page).to have_text(@ect.full_name)
      expect(page).to have_text("Tell us if #{@ect.full_name} is transferring to another school")
    end

    def then_i_should_be_on_the_teacher_end_date_page
      expect(page).to have_selector("h1", text: "When is #{@ect.full_name} leaving your school?")
    end

    def then_i_should_be_on_the_check_your_answers_page
      expect(page).to have_selector("h1", text: "Check your answers")
      expect(page).to have_selector("dd", text: @ect.full_name)
      expect(page).to have_selector("dd", text: Date.new(2022, 10, 24).to_fs(:govuk))
    end

    def then_i_should_be_on_the_complete_page
      expect(page).to have_selector("h2", text: "What happens next")
      expect(page).to have_text("We’ll tell #{@ect.full_name} that you’ve reported their transfer")
    end

    def then_i_should_be_on_the_check_transfer_page
      expect(page).to have_selector("h1", text: "Is #{@ect.full_name} transferring to another school to continue training?")
    end

    def then_i_should_see_enter_end_date_error_message
      expect(page).to have_text("Enter end date")
    end

    def then_i_should_see_invalid_end_date_error_message
      expect(page).to have_text("Invalid end date")
    end

    def then_i_should_still_see_the_transferring_participant
      expect(page).to have_link(@ect.full_name)
    end

    # and

    def and_i_am_signed_in_as_an_induction_coordinator
      @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school], user: create(:user, full_name: "Carl Coordinator"))
      privacy_policy = create(:privacy_policy)
      privacy_policy.accept!(@induction_coordinator_profile.user)
      sign_in_as @induction_coordinator_profile.user
    end

    def and_select_2021_to_2022_cohort
      click_on("2021 to 2022")
    end

    def and_the_participant_should_be_notified_that_theyre_transferred_out
      expect(ParticipantTransferMailer).to have_received(:with)
                                             .with(hash_including(induction_record: @ect.latest_induction_record))
    end

    def allow_participant_transfer_mailers
      allow(ParticipantTransferMailer).to receive(:with).and_call_original
    end
  end
end
