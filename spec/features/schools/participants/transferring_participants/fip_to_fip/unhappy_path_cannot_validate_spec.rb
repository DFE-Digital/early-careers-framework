# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring participants", type: :feature, js: true do
  context "Attempting to transfer an ECT to a school" do
    context "ECT cannot be validated" do
      before do
        set_participant_data
        set_dqt_validation_result
        given_there_are_two_schools_that_have_chosen_fip_for_2021_and_partnered
        and_there_is_an_ect_who_will_be_transferring
        and_i_am_signed_in_as_an_induction_coordinator
        and_i_have_selected_my_cohort_tab
        when_i_click_to_view_ects_and_mentors
        then_i_am_taken_to_your_ect_and_mentors_page
      end

      scenario "Details are not matched but SIT still tries to add participant" do
        when_i_click_to_add_a_new_ect_or_mentor
        then_i_should_be_on_the_who_to_add_page

        when_i_select_transfer_teacher_option
        click_on "Continue"
        then_i_should_be_on_what_we_need_page

        click_on "Continue"
        then_i_should_be_on_full_name_page

        when_i_update_the_name_with("Stacy Teacher")
        click_on "Continue"
        then_i_should_be_on_trn_page

        when_i_add_a_valid_trn
        click_on "Continue"
        then_i_should_be_on_the_date_of_birth_page

        when_i_add_a_valid_date_of_birth
        click_on "Continue"

        then_i_should_be_taken_to_the_cannot_find_their_details
        then_the_page_should_be_accessible
        click_on "Confirm and continue"

        then_i_should_be_taken_to_the_cannot_add_page
        then_the_page_should_be_accessible
      end

      # given

      def given_there_are_two_schools_that_have_chosen_fip_for_2021_and_partnered
        @cohort = Cohort.find_by(start_year: 2021) || create(:cohort, start_year: 2021)
        @school_one = create(:school, name: "Fip School 1")
        @school_two = create(:school, name: "Fip School 2")
        create(:school_cohort, school: @school_one, cohort: Cohort.find_by(start_year: 2022) || create(:cohort, start_year: 2022), induction_programme_choice: "full_induction_programme")
        @school_cohort_one = create(:school_cohort, school: @school_one, cohort: @cohort, induction_programme_choice: "full_induction_programme")
        @school_cohort_two = create(:school_cohort, school: @school_two, cohort: @cohort, induction_programme_choice: "full_induction_programme")
        @lead_provider = create(:lead_provider, name: "Big Provider Ltd")
        @delivery_partner = create(:delivery_partner, name: "Amazing Delivery Team")
        @other_delivery_partner = create(:delivery_partner, name: "Fantastic Delivery Team")
        @mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_cohort_one)
        @partnership_one = create(:partnership, school: @school_one, lead_provider: @lead_provider, delivery_partner: @delivery_partner, cohort: @cohort)
        @partnership_two = create(:partnership, school: @school_two, lead_provider: @lead_provider, delivery_partner: @other_delivery_partner, cohort: @cohort)
        @induction_programme_one = create(:induction_programme, :fip, school_cohort: @school_cohort_one, partnership: @partnership_one)
        @induction_programme_two = create(:induction_programme, :fip, school_cohort: @school_cohort_two, partnership: @partnership_two)
        @school_cohort_one.update!(default_induction_programme: @induction_programme_one)
        @school_cohort_two.update!(default_induction_programme: @induction_programme_two)
        Induction::Enrol.call(participant_profile: @mentor, induction_programme: @induction_programme_one)
        Mentors::AddToSchool.call(school: @school_one, mentor_profile: @mentor)
      end

      # when

      def when_i_click_to_view_ects_and_mentors
        click_on("Manage participants")
      end

      def when_i_click_to_add_a_new_ect_or_mentor
        click_on "Add an ECT or mentor"
      end

      def when_i_select_transfer_teacher_option
        choose("A teacher transferring from another school where they’ve started ECF-based training or mentoring", allow_label_click: true)
      end

      def when_i_update_the_name_with(name)
        fill_in "What’s this person’s full name?", with: name
      end

      def when_i_update_the_email_with(email)
        fill_in "What’s #{@participant_data[:full_name]}’s email address?", with: email
      end

      def when_i_add_a_valid_trn
        fill_in "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)", with: "2002000"
      end

      def when_i_add_a_valid_date_of_birth
        legend = "What’s #{@participant_data[:full_name]}’s date of birth?"

        fill_in_date(legend, with: "1990-10-24")
      end

      def when_i_assign_a_mentor
        choose(@mentor.user.full_name)
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

      def then_i_should_be_on_what_we_need_page
        expect(page).to have_selector("h1", text: "What we need from you")
        expect(page).to have_text("To do this, you need to tell us their")
      end

      def then_i_should_be_on_full_name_page
        expect(page).to have_selector("h1", text: "What’s this person’s full name?")
      end

      def then_i_should_be_on_trn_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s teacher reference number (TRN)?")
      end

      def then_i_should_be_on_the_date_of_birth_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s date of birth?")
      end

      def then_i_should_be_on_the_who_to_add_page
        expect(page).to have_selector("h1", text: "Who do you want to add?")
      end

      def then_i_should_be_taken_to_the_cannot_find_their_details
        expect(page).to have_selector("h1", text: "We cannot find #{@participant_data[:full_name]}’s record")
        expect(page).to have_text("Check the information you’ve entered is correct.")
      end

      def then_i_should_be_taken_to_the_cannot_add_page
        expect(page).to have_selector("h1", text: "You cannot add #{@participant_data[:full_name]}")
        expect(page).to have_text("Contact us for help to register this person at your school")
      end

      # and

      def and_i_am_signed_in_as_an_induction_coordinator
        @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
        privacy_policy = create(:privacy_policy)
        privacy_policy.accept!(@induction_coordinator_profile.user)
        sign_in_as @induction_coordinator_profile.user
      end

      def and_there_is_an_ect_who_will_be_transferring
        @participant_profile_ect = create(:ect_participant_profile, user: create(:user, full_name: "Sally Teacher"), school_cohort: @school_cohort_two)
        create(:induction_record, induction_programme: @induction_programme_two, participant_profile: @participant_profile_ect)
        create(:ecf_participant_validation_data, participant_profile: @participant_profile_ect, full_name: "Sally Teacher", trn: "1001000", date_of_birth: Date.new(1990, 10, 24))
      end

      def and_it_should_list_the_schools_mentors
        expect(page).to have_text(@mentor.user.full_name)
      end

      def and_i_have_selected_my_cohort_tab
        click_on @cohort.description
      end

      def set_dqt_validation_result
        response = {
          trn: @participant_data[:trn],
          full_name: "Sally Teacher",
          nino: nil,
          dob: @participant_data[:date_of_birth],
          config: {},
        }
        allow_any_instance_of(ParticipantValidationService).to receive(:validate).and_return(response)
      end

      def set_participant_data
        @participant_data = {
          trn: "1001000",
          full_name: "Stacy Teacher",
          date_of_birth: Date.new(1990, 10, 24),
          email: "stacy-teacher@example.com",
        }
      end
    end
  end
end
