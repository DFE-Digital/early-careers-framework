# frozen_string_literal: true

require "rails_helper"
require_relative "./manage_training_steps"

RSpec.describe "Manage CIP training", js: true do
  include ManageTrainingSteps

  %w[active inactive].each do |flag_state|
    context "when the programme chagnes for 2025 are #{flag_state}", with_feature_flags: { programme_type_changes_2025: flag_state } do
      scenario "CIP Induction Mentor without materials chosen" do
        given_there_is_a_school_that_has_chosen_cip_for_previous_cohort

        inside_auto_assignment_window(cohort: Cohort.previous) do
          and_i_am_signed_in_as_an_induction_coordinator
          then_i_am_taken_to_cip_induction_dashboard
          then_the_page_should_be_accessible

          when_i_click_on_change_programme
          then_i_am_taken_to_the_support_form_for_changing_an_induction_programme
          then_the_page_should_be_accessible
        end
      end

      scenario "CIP Induction Mentor with materials chosen" do
        if flag_state == "inactive"
          given_there_is_a_school_that_has_chosen_cip_for_previous_cohort

          inside_auto_assignment_window(cohort: Cohort.previous) do
            and_i_am_signed_in_as_an_induction_coordinator
            then_i_am_taken_to_cip_induction_dashboard

            when_i_click_on_choose_materials
            then_i_am_taken_to_course_choice_page
            then_the_page_should_be_accessible

            when_i_choose_materials
            then_i_am_taken_to_training_materials_confirmed_page
            when_i_visit_manage_training_dashboard
            then_i_can_view_the_added_materials
            then_the_page_should_be_accessible
          end
        end
      end

      scenario "CIP Induction Mentor who has not added ECT or mentors" do
        given_there_is_a_school_that_has_chosen_cip_for_previous_cohort
        inside_auto_assignment_window(cohort: Cohort.previous) do
          and_i_am_signed_in_as_an_induction_coordinator
          then_i_can_manage_ects_and_mentors
        end
      end

      scenario "CIP Induction Mentor who has added ECT or mentors" do
        given_there_is_a_school_that_has_chosen_cip_for_previous_cohort
        inside_auto_assignment_window(cohort: Cohort.previous) do
          and_i_have_added_an_ect
          and_i_am_signed_in_as_an_induction_coordinator
          then_i_can_manage_ects_and_mentors
        end
      end

      scenario "Change induction programme to CIP" do
        given_there_is_a_school_that_has_chosen(induction_programme_choice: "design_our_own")
        inside_auto_assignment_window(cohort: Cohort.previous) do
          and_i_am_signed_in_as_an_induction_coordinator

          if FeatureFlag.active?(:programme_type_changes_2025)
            then_i_should_see_the_program_and_click_to_change_it(program_label: "School-led training")
            and_see_the_other_programs_before_choosing(labels: ["Provider-led",
                                                                "School-led",
                                                                "We do not expect any early career teachers to join"],
                                                       choice: "School-led")
          else
            then_i_should_see_the_program_and_click_to_change_it(program_label: "Design and deliver your own programme")
            and_see_the_other_programs_before_choosing(labels: ["Use a training provider, funded by the DfE",
                                                                "Deliver your own programme using DfE-accredited materials",
                                                                "We do not expect any early career teachers to join"],
                                                       choice: "Deliver your own programme using DfE-accredited materials")

          end
          expect(page).to have_text "You’ve submitted your training information"
        end
      end
    end
  end
end
