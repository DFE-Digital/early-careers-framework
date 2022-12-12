# frozen_string_literal: true

require "rails_helper"
require_relative "./new_schools_steps"
require_relative "./choose_programme_steps"

RSpec.feature "New schools should be able to choose their programme", type: :feature, js: true do
  include NewSchoolsSteps
  include ChooseProgrammeSteps

  context "when no ECTs expected" do
    scenario "a new school chooses their programme and get confirmation" do
      given_a_new_school
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_how_you_run_your_training_page

      when_i_choose_no_ects_expected
      and_i_click_on_continue
      then_i_am_on_the_confirm_your_training_page

      when_i_click_on_confirm

      then_i_am_on_the_training_submitted_page
      and_i_dont_see_appropriate_body_reported_title
      and_i_see_appropriate_body_reminder

      when_i_go_to_manage_your_training_page
      then_i_see_no_ects_expected_confirmation
    end
  end

  context "when appropriate body appointed" do
    before do
      @appropriate_body = create(:appropriate_body_national_organisation)
    end

    scenario "a new school chooses their programme and get confirmarion" do
      given_a_new_school
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_how_you_run_your_training_page

      when_i_choose_deliver_own_programme
      and_i_click_on_continue
      then_i_am_on_the_confirm_your_training_page

      when_i_click_on_confirm
      then_i_see_appropriate_body_appointed_page

      when_i_choose_yes
      and_i_click_on_continue

      when_i_choose_national_organisation
      and_i_click_on_continue

      when_i_choose_appropriate_body
      and_i_click_on_continue

      then_i_see_appropriate_body_reported_confirmation
      and_i_dont_see_appropriate_body_reminder

      when_i_go_to_manage_your_training_page
      then_i_am_on_the_manage_your_training_page
      and_i_see_appropriate_body_saved
    end
  end

  context "when no appropriate body appointed" do
    scenario "a new school chooses their programme and get a reminder to tell appropriate body" do
      given_a_new_school
      and_i_am_signed_in_as_an_induction_coordinator
      then_i_am_on_the_how_you_run_your_training_page

      when_i_choose_deliver_own_programme
      and_i_click_on_continue
      then_i_am_on_the_confirm_your_training_page

      when_i_click_on_confirm
      then_i_see_appropriate_body_appointed_page
      when_i_choose_no
      and_i_click_on_continue

      then_i_am_on_the_training_submitted_page
      and_i_dont_see_appropriate_body_reported_title

      when_i_go_to_manage_your_training_page
      then_i_am_on_the_manage_your_training_page
      and_i_see_no_appropriate_body_selected
    end
  end
end
