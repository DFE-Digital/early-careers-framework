# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring participants", type: :feature, js: true, early_in_cohort: true do
  context "Attempting to transfer an ECT to a school" do
    context "ECT cannot be validated" do
      before do
        set_participant_data
        set_dqt_validation_result
        set_nino_validation_result
        given_there_are_two_schools_that_have_chosen_fip_for_previous_cohort_and_partnered
        and_there_is_an_ect_who_will_be_transferring
        and_i_am_signed_in_as_an_induction_coordinator
        and_i_have_selected_my_cohort_tab
        when_i_click_to_view_ects
        then_i_am_taken_to_manage_ects_page
      end

      scenario "Details are not matched but SIT still tries to add participant" do
        when_i_click_to_add_a_new_ect
        then_i_should_be_on_the_who_to_add_page

        when_i_select_the_ect_option
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
        click_on "find their record using their National Insurance number"

        then_i_should_be_on_the_nino_page
        then_the_page_should_be_accessible
        when_i_enter_a_valid_nino
        click_on "Continue"

        then_i_should_be_taken_to_the_still_cannot_find_their_details_page
        then_the_page_should_be_accessible
      end

      # given

      def given_there_are_two_schools_that_have_chosen_fip_for_previous_cohort_and_partnered
        @cohort = Cohort.previous || create(:cohort, :previous)
        @school_one = create(:school, name: "Fip School 1")
        @school_two = create(:school, name: "Fip School 2")
        create(:school_cohort, school: @school_one, cohort: Cohort.current || create(:cohort, :current), induction_programme_choice: "full_induction_programme")
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
        click_on "Add mentor"
      end

      def when_i_select_the_ect_option
        choose("ECT", allow_label_click: true)
      end

      def when_i_update_the_name_with(name)
        fill_in "What’s this ECT’s full name?", with: name
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

      def when_i_enter_a_valid_nino
        fill_in "What’s #{@participant_data[:full_name]}’s National Insurance number", with: "QQ123456A"
      end

      def when_i_assign_a_mentor
        choose(@mentor.user.full_name)
      end

      def when_i_select(option)
        choose(option)
      end

      # then

      def then_i_am_taken_to_manage_ects_page
        expect(page).to have_selector("h1", text: "Early career teachers")
        expect(page).to have_text("Add ECT")
      end

      def then_i_should_be_on_what_we_need_page
        expect(page).to have_selector("h1", text: "What we need to know about this ECT")
      end

      def then_i_should_be_on_full_name_page
        expect(page).to have_selector("h1", text: "What’s this ECT’s full name?")
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
        expect(page).to have_selector("h1", text: "No results found for #{@participant_data[:full_name]}")
        expect(page).to have_text("Check that you have")
      end

      def then_i_should_be_on_the_nino_page
        expect(page).to have_selector("h1", text: "What’s #{@participant_data[:full_name]}’s National Insurance number?")
      end

      def then_i_should_be_taken_to_the_still_cannot_find_their_details_page
        expect(page).to have_selector("h1", text: "We still cannot find #{@participant_data[:full_name]}’s record")
        expect(page).to have_text("Contact us for help to register this ECT at your school")
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
        @participant_profile_ect.teacher_profile.update!(trn: "1001000")
      end

      def and_it_should_list_the_schools_mentors
        expect(page).to have_text(@mentor.user.full_name)
      end

      def and_i_have_selected_my_cohort_tab
        click_on @cohort.description
      end

      def set_dqt_validation_result
        allow(DQTRecordCheck).to receive(:call).and_return(
          DQTRecordCheck::CheckResult.new(
            nil,
            false,
            false,
            false,
            false,
            0,
            :no_match_found,
          ),
        )
      end

      def set_nino_validation_result
        allow_any_instance_of(NationalInsuranceNumber).to receive(:valid?).and_return(true)
      end

      def valid_dqt_response(participant_data)
        DQTRecordPresenter.new({
          "name" => participant_data[:full_name],
          "trn" => participant_data[:trn],
          "state_name" => "Active",
          "dob" => participant_data[:date_of_birth],
          "qualified_teacher_status" => { "qts_date" => 1.year.ago },
          "induction" => {
            "start_date" => 1.month.ago,
            "status" => "Active",
          },
        })
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
