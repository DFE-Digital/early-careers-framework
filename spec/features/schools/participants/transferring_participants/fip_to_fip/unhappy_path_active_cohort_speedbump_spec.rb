# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transferring participants", with_feature_flags: { change_of_circumstances: "active", multiple_cohorts: "active" }, type: :feature, js: true, rutabaga: false do
  context "Transferring a participant to a school" do
    context "School has not created a programme for the previous cohort" do
      before do
        given_there_are_two_schools_that_have_chosen_fip_for_2022_and_partnered
        and_i_am_signed_in_as_an_induction_coordinator
        and_select_the_most_recent_cohort
        when_i_click_to_view_ects_and_mentors
        then_i_am_taken_to_your_ect_and_mentors_page
      end

      scenario "Induction tutor is redirected to contact support" do
        when_i_click_to_add_an_ect_or_mentor
        then_i_should_be_on_the_who_to_add_page

        when_i_select_transfer_teacher_option
        click_on "Continue"

        then_i_should_be_on_check_transfer_page
        when_i_choose_to_continue_the_transfer_journey
        then_i_should_be_on_the_contact_support_page
      end

      # given

      def given_there_are_two_schools_that_have_chosen_fip_for_2022_and_partnered
        @school_one = create(:school, name: "Fip School 1")
        @school_one_2021_cohort = create(:school_cohort, school: @school_one, cohort: create(:cohort, start_year: 2021), induction_programme_choice: "no_early_career_teachers")
        @school_one_2022_cohort = create(:school_cohort, school: @school_one, cohort: create(:cohort, start_year: 2022), induction_programme_choice: "full_induction_programme")
        @mentor = create(:mentor_participant_profile, user: create(:user, full_name: "Billy Mentor"), school_cohort: @school_one_2022_cohort)
        @school_one_2022_cohort_induction_programme = create(:induction_programme, :fip, school_cohort: @school_one_2022_cohort)
        Induction::Enrol.call(participant_profile: @mentor, induction_programme: @school_one_2022_cohort_induction_programme)
        Mentors::AddToSchool.call(school: @school_one, mentor_profile: @mentor)
      end

      # when

      def when_i_click_to_view_ects_and_mentors
        click_on "Manage"
      end

      def when_i_click_to_add_an_ect_or_mentor
        click_on "Add an ECT or mentor"
      end

      def when_i_select_transfer_teacher_option
        choose("A teacher transferring from another school where they’ve started ECF-based training or mentoring", allow_label_click: true)
      end

      def when_i_choose_to_continue_the_transfer_journey
        click_on "Report a transferring ECT or mentor who started training in the #{Cohort.active_registration_cohort.previous.description} academic year"
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

      def then_i_should_be_on_the_contact_support_page
        expect(page).to have_text("training record needs to be transferred manually")
      end

      def then_i_should_be_on_the_who_to_add_page
        expect(page).to have_selector("h1", text: "Who do you want to add?")
      end

      def then_i_should_be_on_check_transfer_page
        expect(page).to have_selector("h1", text: "Check you’re reporting this for the correct academic year")
      end

      # and

      def and_i_am_signed_in_as_an_induction_coordinator
        @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_one], user: create(:user, full_name: "Carl Coordinator"))
        privacy_policy = create(:privacy_policy)
        privacy_policy.accept!(@induction_coordinator_profile.user)
        sign_in_as @induction_coordinator_profile.user
      end

      def and_select_the_most_recent_cohort
        click_on Cohort.active_registration_cohort.description
      end
    end
  end
end
