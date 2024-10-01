# frozen_string_literal: true

require "rails_helper"
require_relative "../training_dashboard/manage_training_steps"

RSpec.describe "Manage currently training participants", js: true, early_in_cohort: true do
  include ManageTrainingSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_and_partnered
  end

  it "Induction coordinators can view and manage participants no longer training" do
    and_i_have_added_a_mentor
    and_i_have_added_a_contacted_for_info_mentor
    and_i_have_added_a_training_ect_with_mentor
    and_i_have_added_an_eligible_ect_without_mentor
    and_i_have_added_a_deferred_ect
    and_i_have_added_an_ect_with_withdrawn_training
    and_i_have_added_an_ect_with_withdrawn_induction_status
    and_i_am_signed_in_as_an_induction_coordinator
    and_i_click(Cohort.current.description)
    given_i_am_taken_to_the_induction_dashboard

    when_i_navigate_to_ect_dashboard
    then_i_see_the_ects_filter_with_counts(currently_training: 2, no_longer_training: 2)
    when_i_filter_by("No longer training (2)")
    then_i_see_the_participants_filtered_by("No Longer Training")
    and_i_see_ects_not_being_trained

    when_i_click_on_the_participants_name "Deferred participant"
    then_i_am_taken_to_view_ect_details_page
  end
end
