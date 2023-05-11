# frozen_string_literal: true

require "rails_helper"
require_relative "./choose_programme_steps"

RSpec.feature "Schools should be able to choose their programme", type: :feature, js: true, rutabaga: false, travel_to: Time.zone.local(2022, 6, 5, 16, 15, 0) do
  include ChooseProgrammeSteps

  before do
    given_there_is_a_school_that_has_chosen_fip_for_2021_and_partnered
    and_cohort_for_next_academic_year_is_created
    and_i_am_signed_in_as_an_induction_coordinator
    when_i_start_programme_selection_for_next_cohort
    then_i_am_taken_to_what_we_need_to_know_to_setup_academic_year
    when_i_click_continue
    then_i_am_taken_to_ects_expected_in_next_academic_year_page
  end

  context "school cohort provider relationship for 2022 is invalid" do
    scenario "school continues with different lead provider" do
      when_i_choose_ects_expected
      and_i_click_continue
      then_i_am_taken_to_the_lp_dp_relationship_has_changed_page

      when_i_click_the_confirm_button
      then_i_am_taken_to_what_changes_page

      when_i_choose_to_form_a_new_partnership
      and_i_click_continue
      then_i_am_taken_to_the_form_a_new_partnership_confirmation_page
      when_i_click_the_confirm_button
      then_i_am_taken_to_the_appropriate_body_appointed_page

      when_i_choose_no
      and_i_click_continue
      then_i_am_taken_to_the_complete_page

      when_i_click_on_the_return_to_your_training_link
      then_i_am_taken_to_the_manage_your_training_page
      and_i_see_the_lead_provider
      and_i_see_delivery_partner_to_be_confirmed
    end
  end
end
