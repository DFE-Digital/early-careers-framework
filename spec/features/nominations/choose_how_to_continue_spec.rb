# frozen_string_literal: true

require "rails_helper"
require_relative "./nominate_induction_tutor_steps"

RSpec.feature "ECT nominate SIT journey", type: :feature, js: true do
  include NominateInductionTutorSteps

  before do
    given_a_valid_nomination_email_has_been_created
    when_i_click_the_link_to_nominate_a_sit
    then_i_should_be_taken_to_the_choose_how_to_continue_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Choose how to continue"
  end

  scenario "School expects ECTs to join in the current academic year" do
    when_i_select_yes_to_expecting_ects_to_join
    and_select_continue
    then_i_should_be_taken_to_the_start_nomination_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Start school induction tutor nomination"
  end

  scenario "School does not expect any early career teachers to join in the current academic year" do
    when_i_select_no_to_expecting_ects_to_join
    and_select_continue
    then_i_should_be_redirected_to_the_choice_saved_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Opt out choice saved"
  end

  scenario "School does not know whether they will have an early career teachers join in the current academic year" do
    when_i_select_we_do_not_know_yet_to_expecting_ects_to_join
    and_select_continue
    then_i_should_be_taken_to_the_start_nomination_page
    and_the_page_should_be_accessible
    and_percy_should_be_sent_a_snapshot_named "Start school induction tutor nomination"
  end
end
