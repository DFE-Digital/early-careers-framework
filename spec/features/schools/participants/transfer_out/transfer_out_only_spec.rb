# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transfer out participants", with_feature_flags: { change_of_circumstances: "active", multiple_cohorts: "active" }, type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2022, 10, 21) do
  context "Transfer out an ECT" do
    before do
      set_participant_data
      allow_participant_transfer_mailers
      given_a_school_have_chosen_fip_for_2021
      and_i_am_signed_in_as_an_induction_coordinator
      and_select_the_most_recent_cohort
      when_i_click_to_view_ects_and_mentors
      then_i_am_taken_to_your_ect_and_mentors_page
    end

    scenario "Induction tutor can transfer an ECT out of their school" do
      when_i_click_on_an_ect
      then_i_should_be_on_the_ect_details_page

      when_i_click_to_transfer_out_a_participant
      then_i_should_be_on_the_check_transfer_page

      click_on "Continue"
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
      then_i_am_taken_to_your_ect_and_mentors_page
      then_i_should_see_the_transfer_out_participant
    end

    # given

    def given_a_school_have_chosen_fip_for_2021
      @cohort = create(:cohort, start_year: 2021)
      @school_one = create(:school, name: "Fip School 1")
      @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
      @ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_one)
      @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one)
      @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
      @induction_record = Induction::Enrol.call(participant_profile: @ect, induction_programme: @induction_programme_one)
    end

    # when

    def when_i_click_to_view_ects_and_mentors
      click_on "Manage"
    end

    def when_i_click_on_an_ect
      click_on @participant_data[:full_name]
    end

    def when_i_click_to_transfer_out_a_participant
      click_on "#{@participant_data[:full_name]} is transferring to another school"
    end

    def when_i_add_an_invalid_date
      legend = "When is #{@participant_data[:full_name]} leaving your school?"

      fill_in_date(legend, with: "23-10-24")
    end

    def when_i_add_a_valid_end_date
      legend = "When is #{@participant_data[:full_name]} leaving your school?"

      fill_in_date(legend, with: "2022-10-24")
    end

    def when_i_select(option)
      choose(option)
    end

    # then

    def then_i_am_taken_to_your_ect_and_mentors_page
      expect(page).to have_selector("h1", text: "Your ECTs and mentors")
      expect(page).to have_text("Add an ECT or mentor")
      expect(page).to have_text("Add yourself as a mentor")
    end

    def then_i_should_be_on_the_ect_details_page
      expect(page).to have_text(@participant_data[:full_name])
      expect(page).to have_text("Tell us #{@participant_data[:full_name]} is transferring to another school")
    end

    def then_i_should_be_on_the_teacher_end_date_page
      expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} leaving your school?")
    end

    def then_i_should_be_on_the_check_your_answers_page
      date = @participant_data[:end_date]
      expect(page).to have_selector("h1", text: "Check your answers")
      expect(page).to have_selector("dd", text: @participant_data[:full_name])
      expect(page).to have_selector("dd", text: date.to_date.to_s(:govuk))
    end

    def then_i_should_be_on_the_complete_page
      expect(page).to have_selector("h2", text: "What happens next")
      expect(page).to have_text("We’ll tell #{@participant_data[:full_name]} that you’ve reported their transfer")
    end

    def then_i_should_be_on_the_check_transfer_page
      expect(page).to have_selector("h1", text: "Is #{@participant_data[:full_name]} transferring to another school where they’ll continue their induction?")
    end

    def then_i_should_see_enter_end_date_error_message
      expect(page).to have_text("Enter end date")
    end

    def then_i_should_see_invalid_end_date_error_message
      expect(page).to have_text("Invalid end date")
    end

    def then_i_should_see_the_transfer_out_participant
      date = @participant_data[:end_date]
      expect(page).to have_selector("h2", text: "Transferring from your school")
      within(:xpath, "//table[@data-test='transferring_out']/tbody/tr[1]") do
        expect(page).to have_xpath(".//td[1]", text: @participant_data[:full_name])
        expect(page).to have_xpath(".//td[4]", text: date.to_date.to_s(:govuk))
      end
    end

    # and

    def and_i_am_signed_in_as_an_induction_coordinator
      @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
      privacy_policy = create(:privacy_policy)
      privacy_policy.accept!(@induction_coordinator_profile.user)
      sign_in_as @induction_coordinator_profile.user
    end

    def and_select_the_most_recent_cohort
      click_on Cohort.active_registration_cohort.description
    end

    def and_the_participant_should_be_notified_that_theyre_transferred_out
      expect(ParticipantTransferMailer).to have_received(:participant_transfer_out_notification)
                                             .with(hash_including(
                                                     induction_record: @induction_record,
                                                   ))
    end

    def allow_participant_transfer_mailers
      allow(ParticipantTransferMailer).to receive(:participant_transfer_out_notification).and_call_original
    end

    def set_participant_data
      @participant_data = {
        trn: "1001000",
        full_name: "Sally Teacher",
        end_date: Date.new(2022, 10, 24),
        email: "sally-teacher@example.com",
      }
    end
  end
end
