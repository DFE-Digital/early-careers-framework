# frozen_string_literal: true

require "rails_helper"

RSpec.describe "old and new SIT transferring the same participant", type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2021, 10, 21) do
  context "Transfer out an ECT that has already been transferred in" do
    before do
      set_participant_data
      allow_participant_transfer_mailers
      given_two_schools_have_chosen_fip_for_2021
      and_a_participant_has_been_transferred_in_to_another_school
      and_i_am_signed_in_as_an_induction_coordinator
      and_select_the_most_recent_cohort
    end

    scenario "Induction tutor only sees the transfer once they’ve done it themselves" do
      when_i_click_to_view_ects_and_mentors
      then_i_am_taken_to_manage_mentors_and_ects_page

      when_i_click_on_an_ect
      then_i_should_be_on_the_ect_details_page

      when_i_click_to_transfer_out_a_participant
      then_i_should_be_on_the_check_transfer_page

      click_on "Confirm"
      then_i_should_be_on_the_teacher_end_date_page

      when_i_add_a_valid_end_date
      click_on "Continue"

      then_i_should_be_on_the_check_your_answers_page

      click_on "Confirm and continue"
      then_i_should_be_on_the_complete_page
      and_the_participant_should_be_notified_that_theyre_transferred_out

      click_on "View your ECTs and mentors"
      then_i_am_taken_to_manage_mentors_and_ects_page

      when_i_click_on_an_ect
      then_i_should_still_see_the_transferring_participant
    end

    # given

    def given_two_schools_have_chosen_fip_for_2021
      @cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
      @school_one = create(:school, name: "Fip School 1")
      @school_two = create(:school, name: "Fip School 2")
      @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
      @school_cohort_two = create(:school_cohort, school: @school_two, cohort: @cohort, induction_programme_choice: "full_induction_programme")
      @ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_one)
      @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one, partnership: @partnership_1)
      @induction_programme_two = create(:induction_programme, :fip, school_cohort: @school_cohort_two, partnership: @partnership_2)
      @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
      @induction_record = Induction::Enrol.call(participant_profile: @ect, induction_programme: @induction_programme_one)
    end

    def and_a_participant_has_been_transferred_in_to_another_school
      Induction::TransferAndContinueExistingFip.call(
        school_cohort: @school_cohort_two,
        participant_profile: @ect,
        email: @ect.user.email,
        end_date: Time.zone.now.next_month,
      )
    end

    # when

    def when_i_click_to_view_ects_and_mentors
      click_on("Manage mentors and ECTs")
    end

    def when_i_click_on_an_ect
      click_on @participant_data[:full_name]
    end

    def when_i_click_to_transfer_out_a_participant
      click_on "#{@participant_data[:full_name]} is transferring to another school"
    end

    def when_i_add_a_valid_end_date
      legend = "When is #{@participant_data[:full_name]} leaving your school?"

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

    def then_i_should_still_see_the_participant_in_my_active_participants
      expect(page).to have_summary_row(@ect.full_name, "LEAVING YOUR SCHOOL")
      expect(page).to have_selector("h2", text: "Contacted for information")
      within(:xpath, "//table[@data-test='checked_ects']/tbody/tr[1]") do
        expect(page).to have_xpath(".//td[1]", text: @ect.user.full_name)
      end
    end

    def then_i_should_be_on_the_ect_details_page
      expect(page).to have_text(@participant_data[:full_name])
      expect(page).to have_text("Tell us if #{@participant_data[:full_name]} is transferring to another school")
    end

    def then_i_should_be_on_the_check_transfer_page
      expect(page).to have_selector("h1", text: "Is #{@participant_data[:full_name]} transferring to another school to continue training?")
    end

    def then_i_should_be_on_the_teacher_end_date_page
      expect(page).to have_selector("h1", text: "When is #{@participant_data[:full_name]} leaving your school?")
    end

    def then_i_should_be_on_the_check_your_answers_page
      date = @participant_data[:end_date]
      expect(page).to have_selector("h1", text: "Check your answers")
      expect(page).to have_selector("dd", text: @participant_data[:full_name])
      expect(page).to have_selector("dd", text: date.to_date.to_fs(:govuk))
    end

    def then_i_should_be_on_the_complete_page
      expect(page).to have_selector("h2", text: "What happens next")
      expect(page).to have_text("We’ll tell #{@participant_data[:full_name]} that you’ve reported their transfer")
    end

    def then_i_should_still_see_the_transferring_participant
      expect(page).to have_text(@participant_data[:full_name])
      expect(page).to have_link("Remove #{@participant_data[:full_name]}")
    end

    def then_i_should_see_the_participants_as_having_transferred
      date = @participant_data[:end_date]
      expect(page).to have_selector("h2", text: "Transferred from your school")
      within(:xpath, "//table[@data-test='transferred']/tbody/tr[1]") do
        expect(page).to have_xpath(".//td[1]", text: @participant_data[:full_name])
        expect(page).to have_xpath(".//td[2]", text: date.to_date.to_fs(:govuk))
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

    def and_i_should_not_see_any_transferring_participants
      expect(page).not_to have_selector("h2", text: "Transferring from your school")
    end

    def and_they_should_not_be_under_their_previous_heading
      expect(page).not_to have_selector("h2", text: "Contacted for information")
    end

    def and_the_participant_should_be_notified_that_theyre_transferred_out
      expect(ParticipantTransferMailer).to have_received(:with)
                                             .with(induction_record: @induction_record)
    end

    def allow_participant_transfer_mailers
      allow(ParticipantTransferMailer).to receive(:with).and_call_original
    end

    def set_participant_data
      @participant_data = {
        trn: "1001000",
        full_name: "Sally Teacher",
        start_date: Time.zone.today.prev_month,
        end_date: Date.new(2022, 10, 24),
        email: "sally-teacher@example.com",
      }
    end
  end
end
