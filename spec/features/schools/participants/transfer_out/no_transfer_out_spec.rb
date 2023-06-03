# frozen_string_literal: true

require "rails_helper"

RSpec.describe "transfer out participants", :with_default_schedules, type: :feature, js: true, rutabaga: false do
  context "An ECT has been transferred in to another school" do
    before do
      set_participant_data
      given_two_schools_have_chosen_fip_for_2021
      and_a_participant_has_been_transferred_in_to_another_school
      travel_to(@participant_data[:end_date] - 1.day)
      and_i_am_signed_in_as_an_induction_coordinator
      and_select_the_most_recent_cohort
    end

    scenario "Old induction tutor only sees the transfer once the end date has passed" do
      when_i_click_to_view_ects_and_mentors
      then_i_am_taken_to_manage_mentors_and_ects_page
      when_i_visit_the_participant_page
      then_i_should_still_see_the_participant_is_leaving_my_school

      travel_to(@participant_data[:end_date] + 1.day)
      visit current_path

      then_i_should_see_the_participants_as_having_transferred
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
      Induction::Enrol.call(participant_profile: @ect, induction_programme: @induction_programme_one)
    end

    # when

    def when_i_click_to_view_ects_and_mentors
      click_on("Manage mentors and ECTs")
    end

    def when_i_visit_the_participant_page
      click_on(@ect.full_name)
    end

    def when_i_select(option)
      choose(option)
    end

    # then

    def then_i_am_taken_to_manage_mentors_and_ects_page
      expect(page).to have_selector("h1", text: "Manage mentors and ECTs")
      expect(page).to have_text("Add ECT or mentor")
    end

    def then_i_should_still_see_the_participant_is_leaving_my_school
      expect(page).to have_summary_row("Name", @ect.user.full_name)
      expect(page).to have_text("LEAVING YOUR SCHOOL")
    end

    def then_i_should_see_the_participants_as_having_transferred
      expect(page).to have_summary_row("Name", @ect.user.full_name)
      expect(page).to have_text("NO LONGER BEING TRAINED")
    end

    # and

    def and_i_am_signed_in_as_an_induction_coordinator
      @induction_coordinator_profile = create(:induction_coordinator_profile, schools: [@school_cohort_one.school], user: create(:user, full_name: "Carl Coordinator"))
      privacy_policy = create(:privacy_policy)
      privacy_policy.accept!(@induction_coordinator_profile.user)
      sign_in_as @induction_coordinator_profile.user
    end

    def and_a_participant_has_been_transferred_in_to_another_school
      Induction::TransferAndContinueExistingFip.call(
        school_cohort: @school_cohort_two,
        participant_profile: @ect,
        email: @ect.user.email,
        end_date: @participant_data[:end_date],
      )
    end

    def and_select_the_most_recent_cohort
      click_on Cohort.active_registration_cohort.description
    end

    def set_participant_data
      @participant_data = {
        trn: "1001000",
        full_name: "Sally Teacher",
        start_date: Time.zone.today.prev_month,
        end_date: Date.new(2022, 3, 24),
        email: "sally-teacher@example.com",
      }
    end
  end
end
